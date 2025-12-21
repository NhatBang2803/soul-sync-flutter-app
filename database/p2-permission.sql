-- =====================================================
-- Soul Sync Database - FILE 2: SECURITY & PERMISSIONS
-- Mục đích: Cấu hình RLS Policies và Grants
-- Thứ tự chạy: 2 (sau file1.sql)
-- Có thể chạy lại nhiều lần mà không gây lỗi
-- =====================================================

-- =====================
-- PHẦN 1: GRANT PERMISSIONS CHO VIEWS
-- =====================
GRANT SELECT ON songs_with_artists TO anon, authenticated;
GRANT SELECT ON albums_with_artists TO anon, authenticated;
GRANT SELECT ON weekly_song_rankings TO anon, authenticated;
GRANT SELECT ON weekly_artist_rankings TO anon, authenticated;
GRANT SELECT ON new_releases TO anon, authenticated;

-- Grant all on tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;

-- =====================
-- PHẦN 2: CẤU HÌNH ROW LEVEL SECURITY
-- Chọn 1 trong 2 mode bên dưới bằng cách comment/uncomment
-- =====================

-- =========================================
-- MODE A: DEVELOPMENT (Không cần Supabase Auth)
-- Dùng cho phát triển, test local, custom auth
-- Mặc định: BẬT
-- =========================================

-- Disable RLS cho tất cả tables
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE artists DISABLE ROW LEVEL SECURITY;
ALTER TABLE albums DISABLE ROW LEVEL SECURITY;
ALTER TABLE songs DISABLE ROW LEVEL SECURITY;
ALTER TABLE genres DISABLE ROW LEVEL SECURITY;
ALTER TABLE playlists DISABLE ROW LEVEL SECURITY;
ALTER TABLE song_artists DISABLE ROW LEVEL SECURITY;
ALTER TABLE album_artists DISABLE ROW LEVEL SECURITY;
ALTER TABLE album_songs DISABLE ROW LEVEL SECURITY;
ALTER TABLE song_genres DISABLE ROW LEVEL SECURITY;
ALTER TABLE playlist_songs DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_liked_songs DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_liked_albums DISABLE ROW LEVEL SECURITY;
ALTER TABLE listening_history DISABLE ROW LEVEL SECURITY;
ALTER TABLE password_reset_tokens DISABLE ROW LEVEL SECURITY;

SELECT 'FILE 2: Security configured (DEVELOPMENT MODE - RLS Disabled)' as status;

-- =========================================
-- MODE B: PRODUCTION (Cần Supabase Auth)
-- Comment toàn bộ MODE A và uncomment phần này
-- =========================================

/*
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE artists ENABLE ROW LEVEL SECURITY;
ALTER TABLE albums ENABLE ROW LEVEL SECURITY;
ALTER TABLE songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE playlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE song_artists ENABLE ROW LEVEL SECURITY;
ALTER TABLE album_artists ENABLE ROW LEVEL SECURITY;
ALTER TABLE album_songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE song_genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE playlist_songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_liked_songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_liked_albums ENABLE ROW LEVEL SECURITY;
ALTER TABLE listening_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE password_reset_tokens ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (tránh conflict)
DROP POLICY IF EXISTS "Public read" ON users;
DROP POLICY IF EXISTS "Public read" ON artists;
DROP POLICY IF EXISTS "Public read" ON albums;
DROP POLICY IF EXISTS "Public read" ON songs;
DROP POLICY IF EXISTS "Public read" ON genres;
DROP POLICY IF EXISTS "Public read" ON song_artists;
DROP POLICY IF EXISTS "Public read" ON album_artists;
DROP POLICY IF EXISTS "Public read" ON album_songs;
DROP POLICY IF EXISTS "Public read" ON song_genres;
DROP POLICY IF EXISTS "Read public playlists" ON playlists;
DROP POLICY IF EXISTS "Owner manages playlist" ON playlists;
DROP POLICY IF EXISTS "Read playlist songs" ON playlist_songs;
DROP POLICY IF EXISTS "Owner manages playlist songs" ON playlist_songs;
DROP POLICY IF EXISTS "User manages follows" ON user_follows;
DROP POLICY IF EXISTS "User manages likes" ON user_liked_songs;
DROP POLICY IF EXISTS "User manages album likes" ON user_liked_albums;
DROP POLICY IF EXISTS "User manages history" ON listening_history;
DROP POLICY IF EXISTS "Read reset tokens" ON password_reset_tokens;

-- === PUBLIC READ POLICIES ===
CREATE POLICY "Public read" ON users FOR SELECT USING (true);
CREATE POLICY "Public read" ON artists FOR SELECT USING (true);
CREATE POLICY "Public read" ON albums FOR SELECT USING (is_public = true);
CREATE POLICY "Public read" ON songs FOR SELECT USING (true);
CREATE POLICY "Public read" ON genres FOR SELECT USING (true);
CREATE POLICY "Public read" ON song_artists FOR SELECT USING (true);
CREATE POLICY "Public read" ON album_artists FOR SELECT USING (true);
CREATE POLICY "Public read" ON album_songs FOR SELECT USING (true);
CREATE POLICY "Public read" ON song_genres FOR SELECT USING (true);

-- === PLAYLIST POLICIES ===
CREATE POLICY "Read public playlists" ON playlists 
  FOR SELECT USING (is_public = true OR owner_id = auth.uid());
CREATE POLICY "Owner manages playlist" ON playlists 
  FOR ALL USING (owner_id = auth.uid());
CREATE POLICY "Read playlist songs" ON playlist_songs 
  FOR SELECT USING (true);
CREATE POLICY "Owner manages playlist songs" ON playlist_songs 
  FOR ALL USING (playlist_id IN (SELECT id FROM playlists WHERE owner_id = auth.uid()));

-- === USER INTERACTION POLICIES ===
CREATE POLICY "User manages follows" ON user_follows 
  FOR ALL USING (user_id = auth.uid());
CREATE POLICY "User manages likes" ON user_liked_songs 
  FOR ALL USING (user_id = auth.uid());
CREATE POLICY "User manages album likes" ON user_liked_albums 
  FOR ALL USING (user_id = auth.uid());
CREATE POLICY "User manages history" ON listening_history 
  FOR ALL USING (user_id = auth.uid() OR user_id IS NULL);
CREATE POLICY "Read reset tokens" ON password_reset_tokens 
  FOR SELECT USING (true);

SELECT 'FILE 2: Security configured (PRODUCTION MODE - RLS Enabled)' as status;
*/
