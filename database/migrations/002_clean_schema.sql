-- =====================================================
-- Soul Sync Database - CLEAN SCHEMA
-- CẢNH BÁO: Script này sẽ XÓA TOÀN BỘ dữ liệu hiện tại!
-- Chạy trong Supabase SQL Editor
-- =====================================================

-- =====================
-- BƯỚC 1: RESET SCHEMA
-- =====================
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
GRANT ALL ON SCHEMA public TO anon;
GRANT ALL ON SCHEMA public TO authenticated;
GRANT ALL ON SCHEMA public TO service_role;

-- =====================
-- BƯỚC 2: TẠO BẢNG CHÍNH
-- =====================

-- Users
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE,
  display_name VARCHAR(255),
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Artists
CREATE TABLE artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  followers INTEGER DEFAULT 0,
  monthly_listeners INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Genres
CREATE TABLE genres (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  color VARCHAR(7) DEFAULT '#6366F1',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Albums
CREATE TABLE albums (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  cover_url TEXT,
  release_year INTEGER,
  song_count INTEGER DEFAULT 0,
  listen_count INTEGER DEFAULT 0,
  is_public BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Songs (KHÔNG có artist_id, album_id trực tiếp - dùng junction tables)
CREATE TABLE songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  duration INTEGER NOT NULL DEFAULT 0,
  audio_url TEXT,
  cover_url TEXT,
  play_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Playlists
CREATE TABLE playlists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  cover_url TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  song_count INTEGER DEFAULT 0,
  listen_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- BƯỚC 3: JUNCTION TABLES (Many-to-Many)
-- =====================

-- Song ↔ Artist (một bài có thể có nhiều ca sĩ)
CREATE TABLE song_artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  role VARCHAR(50) DEFAULT 'main', -- 'main', 'featuring', 'producer'
  position INTEGER DEFAULT 0,
  UNIQUE(song_id, artist_id)
);

-- Album ↔ Artist (album thuộc về artist nào)
CREATE TABLE album_artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  UNIQUE(album_id, artist_id)
);

-- Album ↔ Song (một album có nhiều bài, một bài có thể trong nhiều album)
CREATE TABLE album_songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  track_number INTEGER DEFAULT 1,
  UNIQUE(album_id, song_id)
);

-- Song ↔ Genre (một bài có thể thuộc nhiều thể loại)
CREATE TABLE song_genres (
  song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  genre_id UUID NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
  PRIMARY KEY (song_id, genre_id)
);

-- Playlist ↔ Song
CREATE TABLE playlist_songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  playlist_id UUID NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
  song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  position INTEGER DEFAULT 0,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(playlist_id, song_id)
);

-- =====================
-- BƯỚC 4: USER INTERACTION TABLES
-- =====================

-- User follows artist
CREATE TABLE user_follows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  followed_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, artist_id)
);

-- User liked songs
CREATE TABLE user_liked_songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  liked_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, song_id)
);

-- Listening history
CREATE TABLE listening_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  listened_at TIMESTAMPTZ DEFAULT NOW(),
  duration_played INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT FALSE
);

-- Password reset tokens
CREATE TABLE password_reset_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- BƯỚC 5: INDEXES
-- =====================
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_songs_title ON songs(title);
CREATE INDEX idx_songs_play_count ON songs(play_count DESC);
CREATE INDEX idx_artists_name ON artists(name);
CREATE INDEX idx_albums_name ON albums(name);
CREATE INDEX idx_song_artists_song ON song_artists(song_id);
CREATE INDEX idx_song_artists_artist ON song_artists(artist_id);
CREATE INDEX idx_album_songs_album ON album_songs(album_id);
CREATE INDEX idx_album_songs_song ON album_songs(song_id);
CREATE INDEX idx_song_genres_song ON song_genres(song_id);
CREATE INDEX idx_song_genres_genre ON song_genres(genre_id);
CREATE INDEX idx_playlist_songs_playlist ON playlist_songs(playlist_id);
CREATE INDEX idx_user_follows_user ON user_follows(user_id);
CREATE INDEX idx_user_follows_artist ON user_follows(artist_id);
CREATE INDEX idx_listening_history_user ON listening_history(user_id);
CREATE INDEX idx_listening_history_song ON listening_history(song_id);
CREATE INDEX idx_listening_history_time ON listening_history(listened_at DESC);

-- =====================
-- BƯỚC 6: VIEWS
-- =====================

-- Songs with artists aggregated
CREATE VIEW songs_with_artists AS
SELECT 
  s.id,
  s.title,
  s.duration,
  s.audio_url,
  s.cover_url,
  s.play_count,
  s.created_at,
  STRING_AGG(a.name, ', ' ORDER BY sa.position) as artist_name,
  ARRAY_AGG(a.id ORDER BY sa.position) as artist_ids,
  ARRAY_AGG(a.name ORDER BY sa.position) as artist_names
FROM songs s
LEFT JOIN song_artists sa ON s.id = sa.song_id
LEFT JOIN artists a ON sa.artist_id = a.id
GROUP BY s.id;

-- Albums with artists aggregated
CREATE VIEW albums_with_artists AS
SELECT 
  al.id,
  al.name,
  al.cover_url,
  al.release_year,
  al.song_count,
  al.listen_count,
  al.is_public,
  al.created_at,
  al.updated_at,
  STRING_AGG(a.name, ', ') as artist_name,
  ARRAY_AGG(a.id) as artist_ids,
  ARRAY_AGG(a.name) as artist_names
FROM albums al
LEFT JOIN album_artists aa ON al.id = aa.album_id
LEFT JOIN artists a ON aa.artist_id = a.id
GROUP BY al.id;

-- Weekly song rankings by genre
CREATE VIEW weekly_song_rankings AS
SELECT 
  s.id,
  s.title,
  s.cover_url,
  s.duration,
  s.audio_url,
  s.play_count,
  g.id as genre_id,
  g.name as genre_name,
  g.display_name as genre_display_name,
  g.color as genre_color,
  COALESCE(COUNT(lh.id), 0) as weekly_plays,
  RANK() OVER (PARTITION BY g.id ORDER BY COUNT(lh.id) DESC) as rank
FROM songs s
JOIN song_genres sg ON s.id = sg.song_id
JOIN genres g ON sg.genre_id = g.id
LEFT JOIN listening_history lh ON s.id = lh.song_id 
  AND lh.listened_at > NOW() - INTERVAL '7 days'
GROUP BY s.id, g.id;

-- Weekly artist rankings
CREATE VIEW weekly_artist_rankings AS
SELECT 
  a.id,
  a.name,
  a.image_url,
  a.bio,
  a.followers,
  a.monthly_listeners,
  a.is_verified,
  COALESCE(COUNT(lh.id), 0) as weekly_plays,
  RANK() OVER (ORDER BY COUNT(lh.id) DESC) as rank
FROM artists a
LEFT JOIN song_artists sa ON a.id = sa.artist_id
LEFT JOIN listening_history lh ON sa.song_id = lh.song_id 
  AND lh.listened_at > NOW() - INTERVAL '7 days'
GROUP BY a.id;

-- New releases (last 7 days)
CREATE VIEW new_releases AS
SELECT 
  s.id,
  s.title,
  s.duration,
  s.audio_url,
  s.cover_url,
  s.play_count,
  s.created_at,
  STRING_AGG(DISTINCT a.name, ', ') as artist_name
FROM songs s
LEFT JOIN song_artists sa ON s.id = sa.song_id
LEFT JOIN artists a ON sa.artist_id = a.id
WHERE s.created_at > NOW() - INTERVAL '7 days'
GROUP BY s.id
ORDER BY s.created_at DESC;

-- =====================
-- BƯỚC 7: ROW LEVEL SECURITY
-- =====================
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
ALTER TABLE listening_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE password_reset_tokens ENABLE ROW LEVEL SECURITY;

-- Public read policies (ai cũng đọc được)
CREATE POLICY "Public read" ON users FOR SELECT USING (true);
CREATE POLICY "Public read" ON artists FOR SELECT USING (true);
CREATE POLICY "Public read" ON albums FOR SELECT USING (is_public = true);
CREATE POLICY "Public read" ON songs FOR SELECT USING (true);
CREATE POLICY "Public read" ON genres FOR SELECT USING (true);
CREATE POLICY "Public read" ON song_artists FOR SELECT USING (true);
CREATE POLICY "Public read" ON album_artists FOR SELECT USING (true);
CREATE POLICY "Public read" ON album_songs FOR SELECT USING (true);
CREATE POLICY "Public read" ON song_genres FOR SELECT USING (true);

-- Playlist policies
CREATE POLICY "Read public playlists" ON playlists FOR SELECT USING (is_public = true OR owner_id = auth.uid());
CREATE POLICY "Owner manages playlist" ON playlists FOR ALL USING (owner_id = auth.uid());
CREATE POLICY "Read playlist songs" ON playlist_songs FOR SELECT USING (true);
CREATE POLICY "Owner manages playlist songs" ON playlist_songs FOR ALL 
  USING (playlist_id IN (SELECT id FROM playlists WHERE owner_id = auth.uid()));

-- User interaction policies
CREATE POLICY "User manages follows" ON user_follows FOR ALL USING (user_id = auth.uid());
CREATE POLICY "User manages likes" ON user_liked_songs FOR ALL USING (user_id = auth.uid());
CREATE POLICY "User manages history" ON listening_history FOR ALL USING (user_id = auth.uid() OR user_id IS NULL);
CREATE POLICY "Read reset tokens" ON password_reset_tokens FOR SELECT USING (true);

-- =====================
-- BƯỚC 8: HELPER FUNCTIONS
-- =====================

-- Increment play count
CREATE OR REPLACE FUNCTION increment_play_count(p_song_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE songs SET play_count = play_count + 1 WHERE id = p_song_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Record listening history
CREATE OR REPLACE FUNCTION record_listening(
  p_user_id UUID,
  p_song_id UUID,
  p_duration INTEGER DEFAULT 0,
  p_completed BOOLEAN DEFAULT FALSE
)
RETURNS UUID AS $$
DECLARE
  new_id UUID;
BEGIN
  INSERT INTO listening_history (user_id, song_id, duration_played, completed)
  VALUES (p_user_id, p_song_id, p_duration, p_completed)
  RETURNING id INTO new_id;
  
  -- Also increment play count
  PERFORM increment_play_count(p_song_id);
  
  RETURN new_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get random songs
CREATE OR REPLACE FUNCTION get_random_songs(limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
  id UUID,
  title VARCHAR,
  duration INTEGER,
  audio_url TEXT,
  cover_url TEXT,
  artist_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.title,
    s.duration,
    s.audio_url,
    s.cover_url,
    STRING_AGG(a.name, ', ' ORDER BY sa.position) as artist_name
  FROM songs s
  LEFT JOIN song_artists sa ON s.id = sa.song_id
  LEFT JOIN artists a ON sa.artist_id = a.id
  WHERE s.audio_url IS NOT NULL
  GROUP BY s.id
  ORDER BY RANDOM()
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update monthly listeners (for cron job)
CREATE OR REPLACE FUNCTION update_monthly_listeners()
RETURNS void AS $$
BEGIN
  UPDATE artists a
  SET monthly_listeners = (
    SELECT COUNT(DISTINCT lh.user_id)
    FROM song_artists sa
    JOIN listening_history lh ON sa.song_id = lh.song_id
    WHERE sa.artist_id = a.id
    AND lh.listened_at > NOW() - INTERVAL '30 days'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================
-- BƯỚC 9: SEED DATA (Dữ liệu mẫu)
-- =====================

-- Insert genres
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
  ('classical', 'Classical', '#0EA5E9');

-- Insert sample artists
INSERT INTO artists (id, name, image_url, followers, monthly_listeners, is_verified) VALUES
  ('a1111111-1111-1111-1111-111111111111', 'HIEUTHUHAI', 'https://i.scdn.co/image/ab67616d0000b273a8f2d9a8ef2a6ab9e6b8f0e1', 2400000, 1800000, true),
  ('a2222222-2222-2222-2222-222222222222', 'Sơn Tùng M-TP', 'https://i.scdn.co/image/ab67616d0000b273b8f2e9a8ef2a6ab9e6b8f0e2', 5500000, 3200000, true),
  ('a3333333-3333-3333-3333-333333333333', 'Phương Mỹ Chi', 'https://i.scdn.co/image/ab67616d0000b273c8f2e9a8ef2a6ab9e6b8f0e3', 1200000, 800000, true),
  ('a4444444-4444-4444-4444-444444444444', 'Đen Vâu', 'https://i.scdn.co/image/ab67616d0000b273d8f2e9a8ef2a6ab9e6b8f0e4', 3200000, 2100000, true),
  ('a5555555-5555-5555-5555-555555555555', 'Hoàng Thùy Linh', 'https://i.scdn.co/image/ab67616d0000b273e8f2e9a8ef2a6ab9e6b8f0e5', 1800000, 950000, true);

-- Insert sample albums
INSERT INTO albums (id, name, cover_url, release_year, song_count) VALUES
  ('b1111111-1111-1111-1111-111111111111', 'Ai Cũng Phải Bắt Đầu', 'https://i.scdn.co/image/ab67616d0000b273a1', 2024, 10),
  ('b2222222-2222-2222-2222-222222222222', 'M-TP Collection', 'https://i.scdn.co/image/ab67616d0000b273a2', 2023, 12),
  ('b3333333-3333-3333-3333-333333333333', 'Lộng Lẫy Việt Nam', 'https://i.scdn.co/image/ab67616d0000b273a3', 2024, 8);

-- Album artists
INSERT INTO album_artists (album_id, artist_id) VALUES
  ('b1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111'),
  ('b2222222-2222-2222-2222-222222222222', 'a2222222-2222-2222-2222-222222222222'),
  ('b3333333-3333-3333-3333-333333333333', 'a5555555-5555-5555-5555-555555555555');

-- Insert sample songs
INSERT INTO songs (id, title, duration, cover_url, play_count, created_at) VALUES
  ('c1111111-1111-1111-1111-111111111111', 'Ngủ Một Mình', 215, 'https://i.scdn.co/image/ab67616d0000b273s1', 5420000, NOW() - INTERVAL '2 days'),
  ('c2222222-2222-2222-2222-222222222222', 'Lạc Trôi', 289, 'https://i.scdn.co/image/ab67616d0000b273s2', 89000000, NOW() - INTERVAL '30 days'),
  ('c3333333-3333-3333-3333-333333333333', 'Đừng Làm Trái Tim Anh Đau', 245, 'https://i.scdn.co/image/ab67616d0000b273s3', 120000000, NOW() - INTERVAL '60 days'),
  ('c4444444-4444-4444-4444-444444444444', 'Bước Qua Mùa Cô Đơn', 267, 'https://i.scdn.co/image/ab67616d0000b273s4', 35000000, NOW() - INTERVAL '15 days'),
  ('c5555555-5555-5555-5555-555555555555', 'See Tình', 198, 'https://i.scdn.co/image/ab67616d0000b273s5', 250000000, NOW() - INTERVAL '5 days'),
  ('c6666666-6666-6666-6666-666666666666', 'Waiting For You', 312, 'https://i.scdn.co/image/ab67616d0000b273s6', 78000000, NOW() - INTERVAL '45 days');

-- Song artists relationships
INSERT INTO song_artists (song_id, artist_id, role, position) VALUES
  ('c1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'main', 0),
  ('c2222222-2222-2222-2222-222222222222', 'a2222222-2222-2222-2222-222222222222', 'main', 0),
  ('c3333333-3333-3333-3333-333333333333', 'a2222222-2222-2222-2222-222222222222', 'main', 0),
  ('c4444444-4444-4444-4444-444444444444', 'a4444444-4444-4444-4444-444444444444', 'main', 0),
  ('c5555555-5555-5555-5555-555555555555', 'a5555555-5555-5555-5555-555555555555', 'main', 0),
  ('c6666666-6666-6666-6666-666666666666', 'a2222222-2222-2222-2222-222222222222', 'main', 0),
  -- Featuring example
  ('c4444444-4444-4444-4444-444444444444', 'a1111111-1111-1111-1111-111111111111', 'featuring', 1);

-- Song genres
INSERT INTO song_genres (song_id, genre_id) 
SELECT 'c1111111-1111-1111-1111-111111111111', id FROM genres WHERE name = 'rap';
INSERT INTO song_genres (song_id, genre_id) 
SELECT 'c2222222-2222-2222-2222-222222222222', id FROM genres WHERE name = 'pop';
INSERT INTO song_genres (song_id, genre_id) 
SELECT 'c3333333-3333-3333-3333-333333333333', id FROM genres WHERE name = 'ballad';
INSERT INTO song_genres (song_id, genre_id) 
SELECT 'c4444444-4444-4444-4444-444444444444', id FROM genres WHERE name = 'rap';
INSERT INTO song_genres (song_id, genre_id) 
SELECT 'c5555555-5555-5555-5555-555555555555', id FROM genres WHERE name = 'pop';
INSERT INTO song_genres (song_id, genre_id) 
SELECT 'c6666666-6666-6666-6666-666666666666', id FROM genres WHERE name = 'ballad';

-- Album songs
INSERT INTO album_songs (album_id, song_id, track_number) VALUES
  ('b1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111', 1),
  ('b2222222-2222-2222-2222-222222222222', 'c2222222-2222-2222-2222-222222222222', 1),
  ('b2222222-2222-2222-2222-222222222222', 'c3333333-3333-3333-3333-333333333333', 2),
  ('b2222222-2222-2222-2222-222222222222', 'c6666666-6666-6666-6666-666666666666', 3),
  ('b3333333-3333-3333-3333-333333333333', 'c5555555-5555-5555-5555-555555555555', 1);

-- =====================
-- DONE!
-- =====================
-- Grant permissions for views
GRANT SELECT ON songs_with_artists TO anon, authenticated;
GRANT SELECT ON albums_with_artists TO anon, authenticated;
GRANT SELECT ON weekly_song_rankings TO anon, authenticated;
GRANT SELECT ON weekly_artist_rankings TO anon, authenticated;
GRANT SELECT ON new_releases TO anon, authenticated;

-- Disable RLS temporarily to test (hoặc tạo proper policies)
ALTER TABLE genres DISABLE ROW LEVEL SECURITY;
ALTER TABLE songs DISABLE ROW LEVEL SECURITY;
ALTER TABLE artists DISABLE ROW LEVEL SECURITY;
ALTER TABLE albums DISABLE ROW LEVEL SECURITY;
ALTER TABLE playlists DISABLE ROW LEVEL SECURITY;
ALTER TABLE song_artists DISABLE ROW LEVEL SECURITY;
ALTER TABLE album_artists DISABLE ROW LEVEL SECURITY;
ALTER TABLE album_songs DISABLE ROW LEVEL SECURITY;
ALTER TABLE song_genres DISABLE ROW LEVEL SECURITY;
ALTER TABLE playlist_songs DISABLE ROW LEVEL SECURITY;

SELECT 'Database initialized successfully!' as status;
