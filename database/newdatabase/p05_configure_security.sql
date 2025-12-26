-- =====================================================
-- Soul Sync Database - P05: CONFIGURE SECURITY
-- Mục đích: Cấu hình RLS Policies và Security Settings
-- Thứ tự chạy: 5 (sau p04_create_functions.sql)
-- Ngày tạo: 2025-12-27
-- =====================================================

-- =====================
-- PHẦN 1: GRANT PERMISSIONS CHO VIEWS VÀ TABLES
-- =====================

-- Grant permissions for views
GRANT SELECT ON view_songs_with_artists TO anon, authenticated;
GRANT SELECT ON view_albums_with_artists TO anon, authenticated;
GRANT SELECT ON view_weekly_song_rankings TO anon, authenticated;
GRANT SELECT ON view_weekly_artist_rankings TO anon, authenticated;
GRANT SELECT ON view_new_song_releases TO anon, authenticated;
GRANT SELECT ON view_podcast_library TO anon, authenticated;
GRANT SELECT ON view_podcast_new_releases TO anon, authenticated;
GRANT SELECT ON view_podcast_episode_rankings TO anon, authenticated;
GRANT SELECT ON view_podcast_episodes_full TO anon, authenticated;

-- Grant all permissions on tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

-- =====================
-- PHẦN 2: CẤU HÌNH ROW LEVEL SECURITY (RLS)
-- Có 2 mode: DEVELOPMENT (Không RLS) và PRODUCTION (Có RLS)
-- Mặc định: DEVELOPMENT MODE (để phát triển dễ dàng)
-- =====================

-- =========================================
-- MODE A: DEVELOPMENT (Không cần Supabase Auth)
-- Dùng cho: phát triển local, test, custom auth
-- Mặc định: ENABLED
-- =========================================

-- Disable RLS cho tất cả tables (Development mode)
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
ALTER TABLE podcasts DISABLE ROW LEVEL SECURITY;
ALTER TABLE podcast_episodes DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_saved_podcasts DISABLE ROW LEVEL SECURITY;
ALTER TABLE podcast_listening_history DISABLE ROW LEVEL SECURITY;

SELECT 'P05: Security configured (DEVELOPMENT MODE - RLS Disabled)' as status;

-- =========================================
-- MODE B: PRODUCTION (Cần Supabase Auth)
-- Để sử dụng mode này:
-- 1. Comment toàn bộ MODE A ở trên
-- 2. Uncomment toàn bộ code bên dưới
-- =========================================

/*
-- Enable RLS cho tất cả tables (Production mode)
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
ALTER TABLE podcasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE podcast_episodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_saved_podcasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE podcast_listening_history ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (tránh conflict)
DROP POLICY IF EXISTS "policy_users_public_read" ON users;
DROP POLICY IF EXISTS "policy_artists_public_read" ON artists;
DROP POLICY IF EXISTS "policy_albums_public_read" ON albums;
DROP POLICY IF EXISTS "policy_songs_public_read" ON songs;
DROP POLICY IF EXISTS "policy_genres_public_read" ON genres;
DROP POLICY IF EXISTS "policy_song_artists_public_read" ON song_artists;
DROP POLICY IF EXISTS "policy_album_artists_public_read" ON album_artists;
DROP POLICY IF EXISTS "policy_album_songs_public_read" ON album_songs;
DROP POLICY IF EXISTS "policy_song_genres_public_read" ON song_genres;
DROP POLICY IF EXISTS "policy_playlists_read_public" ON playlists;
DROP POLICY IF EXISTS "policy_playlists_owner_manage" ON playlists;
DROP POLICY IF EXISTS "policy_playlist_songs_read" ON playlist_songs;
DROP POLICY IF EXISTS "policy_playlist_songs_owner_manage" ON playlist_songs;
DROP POLICY IF EXISTS "policy_user_follows_user_manage" ON user_follows;
DROP POLICY IF EXISTS "policy_user_liked_songs_user_manage" ON user_liked_songs;
DROP POLICY IF EXISTS "policy_user_liked_albums_user_manage" ON user_liked_albums;
DROP POLICY IF EXISTS "policy_listening_history_user_manage" ON listening_history;
DROP POLICY IF EXISTS "policy_podcasts_public_read" ON podcasts;
DROP POLICY IF EXISTS "policy_podcast_episodes_public_read" ON podcast_episodes;
DROP POLICY IF EXISTS "policy_user_saved_podcasts_user_manage" ON user_saved_podcasts;
DROP POLICY IF EXISTS "policy_podcast_listening_history_user_manage" ON podcast_listening_history;

-- === PUBLIC READ POLICIES ===
CREATE POLICY "policy_users_public_read" ON users FOR SELECT USING (true);
CREATE POLICY "policy_artists_public_read" ON artists FOR SELECT USING (true);
CREATE POLICY "policy_albums_public_read" ON albums FOR SELECT USING (is_public = true);
CREATE POLICY "policy_songs_public_read" ON songs FOR SELECT USING (true);
CREATE POLICY "policy_genres_public_read" ON genres FOR SELECT USING (true);
CREATE POLICY "policy_song_artists_public_read" ON song_artists FOR SELECT USING (true);
CREATE POLICY "policy_album_artists_public_read" ON album_artists FOR SELECT USING (true);
CREATE POLICY "policy_album_songs_public_read" ON album_songs FOR SELECT USING (true);
CREATE POLICY "policy_song_genres_public_read" ON song_genres FOR SELECT USING (true);

-- === PLAYLIST POLICIES ===
CREATE POLICY "policy_playlists_read_public" ON playlists 
    FOR SELECT USING (is_public = true OR owner_id = auth.uid());
CREATE POLICY "policy_playlists_owner_manage" ON playlists 
    FOR ALL USING (owner_id = auth.uid());
CREATE POLICY "policy_playlist_songs_read" ON playlist_songs 
    FOR SELECT USING (true);
CREATE POLICY "policy_playlist_songs_owner_manage" ON playlist_songs 
    FOR ALL USING (playlist_id IN (SELECT id FROM playlists WHERE owner_id = auth.uid()));

-- === USER INTERACTION POLICIES ===
CREATE POLICY "policy_user_follows_user_manage" ON user_follows 
    FOR ALL USING (user_id = auth.uid());
CREATE POLICY "policy_user_liked_songs_user_manage" ON user_liked_songs 
    FOR ALL USING (user_id = auth.uid());
CREATE POLICY "policy_user_liked_albums_user_manage" ON user_liked_albums 
    FOR ALL USING (user_id = auth.uid());
CREATE POLICY "policy_listening_history_user_manage" ON listening_history 
    FOR ALL USING (user_id = auth.uid() OR user_id IS NULL);

-- === PODCAST POLICIES ===
CREATE POLICY "policy_podcasts_public_read" ON podcasts 
    FOR SELECT USING (true);
CREATE POLICY "policy_podcast_episodes_public_read" ON podcast_episodes 
    FOR SELECT USING (true);
CREATE POLICY "policy_user_saved_podcasts_user_manage" ON user_saved_podcasts 
    FOR ALL USING (user_id = auth.uid());
CREATE POLICY "policy_podcast_listening_history_user_manage" ON podcast_listening_history 
    FOR ALL USING (user_id = auth.uid());

SELECT 'P05: Security configured (PRODUCTION MODE - RLS Enabled)' as status;
*/