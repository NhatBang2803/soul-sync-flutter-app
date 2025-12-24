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

-- =====================
-- MIGRATION 004: Add increment_podcast_play_count function
-- Ngày: 2025-12-24
-- Mục đích: Tăng lượt phát cho podcast episode
-- =====================
DROP FUNCTION IF EXISTS increment_podcast_play_count(UUID);
CREATE OR REPLACE FUNCTION increment_podcast_play_count(episode_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE podcast_episodes 
  SET play_count = COALESCE(play_count, 0) + 1
  WHERE id = episode_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION increment_podcast_play_count(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION increment_podcast_play_count(UUID) TO anon;

-- =====================
-- MIGRATION 005: Update weekly_artist_rankings view
-- Ngày: 2025-12-24
-- Mục đích: Đọc từ listening_history và tính số lần nghe trong 7 ngày
-- =====================

-- Drop and recreate view
DROP VIEW IF EXISTS weekly_artist_rankings;

CREATE VIEW weekly_artist_rankings AS
SELECT 
  a.id,
  a.name,
  a.image_url,
  a.bio,
  a.followers,
  a.monthly_listeners,
  a.is_verified,
  a.created_at,
  COUNT(lh.id) as weekly_plays,
  COUNT(DISTINCT lh.user_id) as weekly_listeners,
  COUNT(DISTINCT lh.song_id) as songs_played,
  RANK() OVER (ORDER BY COUNT(lh.id) DESC) as rank
FROM artists a
INNER JOIN song_artists sa ON a.id = sa.artist_id
INNER JOIN listening_history lh ON sa.song_id = lh.song_id
WHERE lh.listened_at > NOW() - INTERVAL '7 days'
GROUP BY a.id
ORDER BY rank;

-- Grant permissions
GRANT SELECT ON weekly_artist_rankings TO authenticated;
GRANT SELECT ON weekly_artist_rankings TO anon;

-- =====================
-- MIGRATION 006: Add RPC function get_weekly_artist_ranking
-- Ngày: 2025-12-24
-- Mục đích: Query trực tiếp từ listening_history, tính cả monthly_listeners
-- =====================
DROP FUNCTION IF EXISTS get_weekly_artist_ranking(INTEGER);

CREATE OR REPLACE FUNCTION get_weekly_artist_ranking(limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
  id UUID,
  name VARCHAR,
  image_url TEXT,
  bio TEXT,
  followers INTEGER,
  monthly_listeners BIGINT,
  is_verified BOOLEAN,
  weekly_plays BIGINT,
  weekly_listeners BIGINT,
  songs_played BIGINT,
  rank BIGINT
) AS $$
BEGIN
  RETURN QUERY
  WITH weekly_data AS (
    -- Tính weekly plays từ 7 ngày gần đây
    SELECT 
      a.id as artist_id,
      a.name,
      a.image_url,
      a.bio,
      a.followers,
      a.is_verified,
      COUNT(lh.id) as weekly_plays,
      COUNT(DISTINCT lh.user_id) as weekly_listeners,
      COUNT(DISTINCT lh.song_id) as songs_played
    FROM artists a
    INNER JOIN song_artists sa ON a.id = sa.artist_id
    INNER JOIN listening_history lh ON sa.song_id = lh.song_id
    WHERE lh.listened_at > NOW() - INTERVAL '7 days'
    GROUP BY a.id
  ),
  monthly_data AS (
    -- Tính monthly plays từ 30 ngày gần đây
    SELECT 
      sa.artist_id,
      COUNT(lh.id) as monthly_plays
    FROM song_artists sa
    INNER JOIN listening_history lh ON sa.song_id = lh.song_id
    WHERE lh.listened_at > NOW() - INTERVAL '30 days'
    GROUP BY sa.artist_id
  )
  SELECT 
    w.artist_id as id,
    w.name,
    w.image_url,
    w.bio,
    w.followers,
    COALESCE(m.monthly_plays, 0) as monthly_listeners,
    w.is_verified,
    w.weekly_plays,
    w.weekly_listeners,
    w.songs_played,
    RANK() OVER (ORDER BY w.weekly_plays DESC) as rank
  FROM weekly_data w
  LEFT JOIN monthly_data m ON w.artist_id = m.artist_id
  ORDER BY w.weekly_plays DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_weekly_artist_ranking(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_weekly_artist_ranking(INTEGER) TO anon;

-- =====================
-- MIGRATION 007: Add RPC function get_artist_with_stats
-- Ngày: 2025-12-24
-- Mục đích: Tính monthly_listeners từ listening_history cho trang Artist
-- =====================
DROP FUNCTION IF EXISTS get_artist_with_stats(UUID);

CREATE OR REPLACE FUNCTION get_artist_with_stats(artist_id UUID)
RETURNS TABLE (
  id UUID,
  name VARCHAR,
  image_url TEXT,
  bio TEXT,
  followers INTEGER,
  monthly_listeners BIGINT,
  is_verified BOOLEAN,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.name,
    a.image_url,
    a.bio,
    a.followers,
    COALESCE(
      (
        SELECT COUNT(lh.id)
        FROM song_artists sa
        INNER JOIN listening_history lh ON sa.song_id = lh.song_id
        WHERE sa.artist_id = a.id
          AND lh.listened_at > NOW() - INTERVAL '30 days'
      ), 0
    ) as monthly_listeners,
    a.is_verified,
    a.created_at,
    a.updated_at
  FROM artists a
  WHERE a.id = get_artist_with_stats.artist_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_artist_with_stats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_artist_with_stats(UUID) TO anon;

-- =====================
-- MIGRATION 008: Add RPC function get_recommended_songs
-- Ngày: 2025-12-25
-- Mục đích: Lấy bài hát gợi ý từ 5 thể loại đã nghe gần nhất, mỗi thể loại tối đa 2 bài
-- =====================
DROP FUNCTION IF EXISTS get_recommended_songs(UUID, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION get_recommended_songs(
  user_id UUID,
  genre_limit INTEGER DEFAULT 5,
  songs_per_genre INTEGER DEFAULT 2
)
RETURNS TABLE (
  id UUID,
  title VARCHAR,
  duration INTEGER,
  audio_url TEXT,
  cover_url TEXT,
  album_name VARCHAR,
  album_id UUID,
  artist_name TEXT,
  artist_names TEXT[],
  artist_ids UUID[],
  genre_id UUID,
  genre_name VARCHAR,
  play_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  WITH recent_genres AS (
    -- Lấy 5 thể loại đã nghe gần nhất
    SELECT DISTINCT sg.genre_id
    FROM listening_history lh
    INNER JOIN song_genres sg ON lh.song_id = sg.song_id
    WHERE lh.user_id = get_recommended_songs.user_id
      AND lh.listened_at > NOW() - INTERVAL '30 days'
    ORDER BY sg.genre_id
    LIMIT genre_limit
  ),
  ranked_songs AS (
    -- Lấy bài hát theo thể loại, rank theo play_count
    SELECT 
      s.id,
      s.title,
      s.duration,
      s.audio_url,
      s.cover_url,
      a.name as album_name,
      s.album_id,
      sg.genre_id,
      g.name as genre_name,
      s.play_count,
      ROW_NUMBER() OVER (PARTITION BY sg.genre_id ORDER BY s.play_count DESC, RANDOM()) as rn
    FROM songs s
    INNER JOIN song_genres sg ON s.id = sg.song_id
    INNER JOIN genres g ON sg.genre_id = g.id
    LEFT JOIN albums a ON s.album_id = a.id
    WHERE sg.genre_id IN (SELECT genre_id FROM recent_genres)
      -- Loại trừ các bài đã nghe trong 7 ngày gần đây
      AND s.id NOT IN (
        SELECT lh2.song_id 
        FROM listening_history lh2 
        WHERE lh2.user_id = get_recommended_songs.user_id 
          AND lh2.listened_at > NOW() - INTERVAL '7 days'
      )
  )
  SELECT 
    rs.id,
    rs.title,
    rs.duration,
    rs.audio_url,
    rs.cover_url,
    rs.album_name,
    rs.album_id,
    STRING_AGG(DISTINCT art.name, ', ')::TEXT as artist_name,
    ARRAY_AGG(DISTINCT art.name)::TEXT[] as artist_names,
    ARRAY_AGG(DISTINCT art.id)::UUID[] as artist_ids,
    rs.genre_id,
    rs.genre_name,
    rs.play_count
  FROM ranked_songs rs
  LEFT JOIN song_artists sa ON rs.id = sa.song_id
  LEFT JOIN artists art ON sa.artist_id = art.id
  WHERE rs.rn <= songs_per_genre
  GROUP BY rs.id, rs.title, rs.duration, rs.audio_url, rs.cover_url, 
           rs.album_name, rs.album_id, rs.genre_id, rs.genre_name, rs.play_count
  ORDER BY rs.genre_id, rs.rn;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_recommended_songs(UUID, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_recommended_songs(UUID, INTEGER, INTEGER) TO anon;

-- MIGRATION 009: [Mô tả]
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
