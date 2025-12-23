-- =====================================================
-- Soul Sync Database - FILE 3: MIGRATIONS & PATCHES
-- Mục đích: Các thay đổi incremental, hotfixes
-- Thứ tự chạy: 3 (sau file2.sql, hoặc khi cần patch)
-- An toàn để chạy nhiều lần (sử dụng IF NOT EXISTS/IF EXISTS)
-- =====================================================

-- =====================
-- MIGRATION 001: Add auth columns to users
-- Ngày: 2025-12-20
-- Mục đích: Hỗ trợ local auth với password hash
-- =====================
DO $$
BEGIN
  -- Thêm cột password_hash nếu chưa có
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'password_hash'
  ) THEN
    ALTER TABLE users ADD COLUMN password_hash TEXT;
    RAISE NOTICE 'MIGRATION 001: Added password_hash column';
  END IF;

  -- Thêm cột auth_method nếu chưa có
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'auth_method'
  ) THEN
    ALTER TABLE users ADD COLUMN auth_method VARCHAR(20) DEFAULT 'local' NOT NULL;
    RAISE NOTICE 'MIGRATION 001: Added auth_method column';
  END IF;
END $$;

-- Cập nhật users không có auth_method
UPDATE users SET auth_method = 'local' WHERE auth_method IS NULL;

-- =====================
-- MIGRATION 002: Add missing indexes
-- Ngày: 2025-12-21
-- Mục đích: Tối ưu performance cho queries
-- =====================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_user_liked_songs_song') THEN
    CREATE INDEX idx_user_liked_songs_song ON user_liked_songs(song_id);
    RAISE NOTICE 'MIGRATION 002: Created idx_user_liked_songs_song';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_user_liked_songs_user') THEN
    CREATE INDEX idx_user_liked_songs_user ON user_liked_songs(user_id);
    RAISE NOTICE 'MIGRATION 002: Created idx_user_liked_songs_user';
  END IF;
END $$;

-- =====================
-- MIGRATION 003: Seed default genres (NẾU CẦN)
-- Ngày: 2025-12-21
-- Mục đích: Đảm bảo có genres mặc định
-- LƯU Ý: Nếu dùng backup.sql để seed data, KHÔNG cần chạy phần này
-- =====================
-- Uncomment nếu cần seed genres mà không dùng backup.sql:
/*
INSERT INTO genres (name, display_name, color) VALUES
  ('ballad', 'Ballad', '#3B82F6'),
  ('rap', 'Rap/Hip-hop', '#EF4444'),
  ('pop', 'Pop', '#EC4899'),
  ('rock', 'Rock', '#8B5CF6'),
  ('edm', 'EDM', '#10B981'),
  ('rnb', 'R&B', '#F59E0B'),
  ('indie', 'Indie', '#6366F1'),
  ('acoustic', 'Acoustic', '#84CC16'),
  ('jazz', 'Jazz', '#F97316'),
  ('classical', 'Classical', '#0EA5E9')
ON CONFLICT (name) DO NOTHING;
*/

-- =====================
-- FUTURE MIGRATIONS: Thêm vào đây
-- =====================

-- MIGRATION 004: [Mô tả]
-- Ngày: YYYY-MM-DD
-- DO $$ BEGIN ... END $$;

-- =====================
-- UTILITY: Kiểm tra trạng thái database
-- =====================
SELECT 
  'Tables' as type,
  COUNT(*) as count 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
UNION ALL
SELECT 
  'Views' as type,
  COUNT(*) as count 
FROM information_schema.views 
WHERE table_schema = 'public'
UNION ALL
SELECT 
  'Indexes' as type,
  COUNT(*) as count 
FROM pg_indexes 
WHERE schemaname = 'public'
UNION ALL
SELECT 
  'Functions' as type,
  COUNT(*) as count 
FROM information_schema.routines 
WHERE routine_schema = 'public';

-- =====================
-- Lấy 5 bài hát không trùng nhau từ db
-- =====================
DROP FUNCTION IF EXISTS get_recently_played_unique_songs(UUID, INTEGER);
CREATE FUNCTION get_recently_played_unique_songs(
  p_user_id UUID,
  p_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
  id UUID,
  title VARCHAR,
  duration INTEGER,
  audio_url TEXT,
  cover_url TEXT,
  play_count INTEGER,
  artist_name TEXT,
  artist_ids UUID[],
  artist_names VARCHAR[]
) AS $$
BEGIN
  RETURN QUERY
  WITH ranked_songs AS (
    SELECT 
      s.id,
      s.title,
      s.duration,
      s.audio_url,
      s.cover_url,
      s.play_count,
      s.artist_name,
      s.artist_ids,
      s.artist_names,
      ROW_NUMBER() OVER (PARTITION BY s.id ORDER BY lh.listened_at DESC) as rn
    FROM listening_history lh
    INNER JOIN songs_with_artists s ON lh.song_id = s.id
    WHERE lh.user_id = p_user_id
  )
  SELECT 
    ranked_songs.id,
    ranked_songs.title,
    ranked_songs.duration,
    ranked_songs.audio_url,
    ranked_songs.cover_url,
    ranked_songs.play_count,
    ranked_songs.artist_name,
    ranked_songs.artist_ids,
    ranked_songs.artist_names
  FROM ranked_songs
  WHERE rn = 1
  ORDER BY (
    SELECT MAX(listened_at) 
    FROM listening_history 
    WHERE song_id = ranked_songs.id AND user_id = p_user_id
  ) DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_recently_played_unique_songs(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_recently_played_unique_songs(UUID, INTEGER) TO anon;


-- =====================
-- HOÀN TẤT
-- =====================
SELECT 'FILE 3: Migrations applied successfully!' as status;
