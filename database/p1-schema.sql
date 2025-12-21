-- =====================================================
-- Soul Sync Database - FILE 1: SCHEMA
-- Mục đích: Tạo cấu trúc database (Tables, Indexes, Views, Functions)
-- Thứ tự chạy: 1 (chạy đầu tiên)
-- CẢNH BÁO: Script này sẽ XÓA TOÀN BỘ schema hiện tại!
-- =====================================================

-- =====================
-- PHẦN 1: RESET SCHEMA
-- =====================
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- Grant basic permissions
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
GRANT ALL ON SCHEMA public TO anon;
GRANT ALL ON SCHEMA public TO authenticated;
GRANT ALL ON SCHEMA public TO service_role;

-- =====================
-- PHẦN 2: TẠO BẢNG CHÍNH
-- =====================

-- Users
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE,
  display_name VARCHAR(255),
  avatar_url TEXT,
  password_hash TEXT,
  auth_method VARCHAR(20) DEFAULT 'local' NOT NULL,
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

-- Songs
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
-- PHẦN 3: JUNCTION TABLES (Many-to-Many)
-- =====================

-- Song ↔ Artist
CREATE TABLE song_artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  role VARCHAR(50) DEFAULT 'main',
  position INTEGER DEFAULT 0,
  UNIQUE(song_id, artist_id)
);

-- Album ↔ Artist
CREATE TABLE album_artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  UNIQUE(album_id, artist_id)
);

-- Album ↔ Song
CREATE TABLE album_songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
  track_number INTEGER DEFAULT 1,
  UNIQUE(album_id, song_id)
);

-- Song ↔ Genre
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
-- PHẦN 4: USER INTERACTION TABLES
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

-- User liked albums
CREATE TABLE user_liked_albums (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  liked_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, album_id)
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
-- PHẦN 5: INDEXES
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
CREATE INDEX idx_user_liked_songs_user ON user_liked_songs(user_id);
CREATE INDEX idx_user_liked_songs_song ON user_liked_songs(song_id);
CREATE INDEX idx_user_liked_albums_user ON user_liked_albums(user_id);
CREATE INDEX idx_user_liked_albums_album ON user_liked_albums(album_id);
CREATE INDEX idx_listening_history_user ON listening_history(user_id);
CREATE INDEX idx_listening_history_song ON listening_history(song_id);
CREATE INDEX idx_listening_history_time ON listening_history(listened_at DESC);

-- =====================
-- PHẦN 6: VIEWS
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
-- PHẦN 7: HELPER FUNCTIONS
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

-- Update monthly listeners
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

-- Increment artist followers
CREATE OR REPLACE FUNCTION increment_artist_followers(p_artist_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE artists SET followers = followers + 1 WHERE id = p_artist_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================
-- HOÀN TẤT FILE 1
-- =====================
SELECT 'FILE 1: Schema created successfully! Run file2.sql next for security policies.' as status;
