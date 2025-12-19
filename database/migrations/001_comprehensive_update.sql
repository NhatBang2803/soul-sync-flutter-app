-- =====================================================
-- Soul Sync Database Migration - Comprehensive Update
-- Run this script in Supabase SQL Editor
-- =====================================================

-- =====================
-- PHASE 0: CREATE BASE TABLES (if not exist)
-- =====================

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  display_name VARCHAR(255),
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Artists table
CREATE TABLE IF NOT EXISTS artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  followers INTEGER DEFAULT 0,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Albums table
CREATE TABLE IF NOT EXISTS albums (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  artist_id UUID REFERENCES artists(id) ON DELETE SET NULL,
  name VARCHAR(255) NOT NULL,
  cover_url TEXT,
  release_year INTEGER,
  song_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Songs table
CREATE TABLE IF NOT EXISTS songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  artist_id UUID REFERENCES artists(id) ON DELETE SET NULL,
  album_id UUID REFERENCES albums(id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  duration INTEGER NOT NULL DEFAULT 0,
  audio_url TEXT,
  cover_url TEXT,
  play_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Playlists table
CREATE TABLE IF NOT EXISTS playlists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id UUID,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  cover_url TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  song_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Playlist Songs junction table
CREATE TABLE IF NOT EXISTS playlist_songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  playlist_id UUID REFERENCES playlists(id) ON DELETE CASCADE,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(playlist_id, song_id)
);

-- User Liked Songs
CREATE TABLE IF NOT EXISTS user_liked_songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  liked_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, song_id)
);

-- =====================
-- PHASE 1: USER TABLE UPDATE
-- =====================
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS username VARCHAR(50) UNIQUE,
ADD COLUMN IF NOT EXISTS password_hash TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- =====================
-- GENRES TABLE
-- =====================
CREATE TABLE IF NOT EXISTS genres (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  display_name VARCHAR(100) NOT NULL,
  color VARCHAR(7), -- hex color
  created_at TIMESTAMPTZ DEFAULT NOW()
);

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

-- =====================
-- SONG_GENRES (Many-to-Many)
-- =====================
CREATE TABLE IF NOT EXISTS song_genres (
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  genre_id UUID REFERENCES genres(id) ON DELETE CASCADE,
  PRIMARY KEY (song_id, genre_id)
);

CREATE INDEX IF NOT EXISTS idx_song_genres_song ON song_genres(song_id);
CREATE INDEX IF NOT EXISTS idx_song_genres_genre ON song_genres(genre_id);

-- =====================
-- SONG_ARTISTS (Many-to-Many) - Cho phép bài hát có nhiều ca sĩ
-- =====================
CREATE TABLE IF NOT EXISTS song_artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  artist_id UUID REFERENCES artists(id) ON DELETE CASCADE,
  role VARCHAR(50) DEFAULT 'main', -- 'main', 'featuring', 'producer'
  position INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(song_id, artist_id)
);

CREATE INDEX IF NOT EXISTS idx_song_artists_song ON song_artists(song_id);
CREATE INDEX IF NOT EXISTS idx_song_artists_artist ON song_artists(artist_id);

-- Migrate existing song-artist relationships to junction table
INSERT INTO song_artists (song_id, artist_id, role, position)
SELECT id, artist_id, 'main', 0 FROM songs WHERE artist_id IS NOT NULL
ON CONFLICT (song_id, artist_id) DO NOTHING;

-- =====================
-- ALBUM_SONGS (Many-to-Many) - Cho phép bài hát thuộc nhiều album
-- =====================
CREATE TABLE IF NOT EXISTS album_songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  album_id UUID REFERENCES albums(id) ON DELETE CASCADE,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  track_number INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(album_id, song_id)
);

CREATE INDEX IF NOT EXISTS idx_album_songs_album ON album_songs(album_id);
CREATE INDEX IF NOT EXISTS idx_album_songs_song ON album_songs(song_id);

-- Migrate existing song-album relationships to junction table
INSERT INTO album_songs (album_id, song_id, track_number)
SELECT album_id, id, ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY created_at)
FROM songs WHERE album_id IS NOT NULL
ON CONFLICT (album_id, song_id) DO NOTHING;

-- =====================
-- USER_FOLLOWS (Theo dõi nghệ sĩ)
-- =====================
CREATE TABLE IF NOT EXISTS user_follows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  artist_id UUID REFERENCES artists(id) ON DELETE CASCADE,
  followed_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, artist_id)
);

CREATE INDEX IF NOT EXISTS idx_user_follows_user ON user_follows(user_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_artist ON user_follows(artist_id);

-- =====================
-- LISTENING_HISTORY (Lịch sử nghe)
-- =====================
CREATE TABLE IF NOT EXISTS listening_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  listened_at TIMESTAMPTZ DEFAULT NOW(),
  duration_played INTEGER DEFAULT 0, -- seconds actually played
  completed BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_listening_history_user ON listening_history(user_id);
CREATE INDEX IF NOT EXISTS idx_listening_history_song ON listening_history(song_id);
CREATE INDEX IF NOT EXISTS idx_listening_history_time ON listening_history(listened_at DESC);

-- =====================
-- ALBUM UPDATES
-- =====================
ALTER TABLE albums 
ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS listen_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- =====================
-- PLAYLIST UPDATES
-- =====================
ALTER TABLE playlists
ADD COLUMN IF NOT EXISTS listen_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Rename column if exists (owner_id -> user_id consistency)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'playlists' AND column_name = 'user_id') THEN
    ALTER TABLE playlists RENAME COLUMN user_id TO owner_id;
  END IF;
EXCEPTION
  WHEN others THEN NULL;
END $$;

-- =====================
-- ARTIST UPDATES
-- =====================
ALTER TABLE artists
ADD COLUMN IF NOT EXISTS monthly_listeners INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- =====================
-- PASSWORD RESET TOKENS
-- =====================
CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_password_reset_email ON password_reset_tokens(email);
CREATE INDEX IF NOT EXISTS idx_password_reset_token ON password_reset_tokens(token);

-- =====================
-- VIEWS FOR RANKINGS
-- =====================

-- Weekly Song Rankings by Genre
CREATE OR REPLACE VIEW weekly_song_rankings AS
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
GROUP BY s.id, s.title, s.cover_url, s.duration, s.audio_url, s.play_count, 
         g.id, g.name, g.display_name, g.color
ORDER BY g.name, rank;

-- Weekly Artist Rankings
CREATE OR REPLACE VIEW weekly_artist_rankings AS
SELECT 
  a.id,
  a.name,
  a.image_url,
  a.bio,
  a.monthly_listeners,
  a.is_verified,
  COALESCE(COUNT(lh.id), 0) as weekly_plays,
  RANK() OVER (ORDER BY COUNT(lh.id) DESC) as rank
FROM artists a
LEFT JOIN song_artists sa ON a.id = sa.artist_id
LEFT JOIN listening_history lh ON sa.song_id = lh.song_id 
  AND lh.listened_at > NOW() - INTERVAL '7 days'
GROUP BY a.id, a.name, a.image_url, a.bio, a.monthly_listeners, a.is_verified
ORDER BY rank;

-- New Releases (last 7 days)
CREATE OR REPLACE VIEW new_releases AS
SELECT 
  s.id,
  s.title,
  s.duration,
  s.audio_url,
  s.cover_url,
  s.play_count,
  s.created_at,
  STRING_AGG(DISTINCT a.name, ', ' ORDER BY a.name) as artist_names,
  STRING_AGG(DISTINCT al.name, ', ' ORDER BY al.name) as album_names
FROM songs s
LEFT JOIN song_artists sa ON s.id = sa.song_id
LEFT JOIN artists a ON sa.artist_id = a.id
LEFT JOIN album_songs als ON s.id = als.song_id
LEFT JOIN albums al ON als.album_id = al.id
WHERE s.created_at > NOW() - INTERVAL '7 days'
GROUP BY s.id, s.title, s.duration, s.audio_url, s.cover_url, s.play_count, s.created_at
ORDER BY s.created_at DESC;

-- Songs with multiple artists (updated view)
CREATE OR REPLACE VIEW songs_with_artists AS
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
  ARRAY_AGG(a.name ORDER BY sa.position) as artist_names_array
FROM songs s
LEFT JOIN song_artists sa ON s.id = sa.song_id
LEFT JOIN artists a ON sa.artist_id = a.id
GROUP BY s.id, s.title, s.duration, s.audio_url, s.cover_url, s.play_count, s.created_at;

-- User Recently Played
CREATE OR REPLACE VIEW user_recently_played AS
SELECT DISTINCT ON (lh.user_id, lh.song_id)
  lh.user_id,
  lh.song_id,
  lh.listened_at,
  s.title,
  s.duration,
  s.audio_url,
  s.cover_url,
  STRING_AGG(a.name, ', ') as artist_name
FROM listening_history lh
JOIN songs s ON lh.song_id = s.id
LEFT JOIN song_artists sa ON s.id = sa.song_id
LEFT JOIN artists a ON sa.artist_id = a.id
GROUP BY lh.id, lh.user_id, lh.song_id, lh.listened_at, s.id, s.title, s.duration, s.audio_url, s.cover_url
ORDER BY lh.user_id, lh.song_id, lh.listened_at DESC;

-- =====================
-- ROW LEVEL SECURITY
-- =====================
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE song_genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE song_artists ENABLE ROW LEVEL SECURITY;
ALTER TABLE album_songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE listening_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE password_reset_tokens ENABLE ROW LEVEL SECURITY;

-- Public read policies (drop first to avoid conflicts)
DROP POLICY IF EXISTS "Anyone can read genres" ON genres;
DROP POLICY IF EXISTS "Anyone can read song_genres" ON song_genres;
DROP POLICY IF EXISTS "Anyone can read song_artists" ON song_artists;
DROP POLICY IF EXISTS "Anyone can read album_songs" ON album_songs;
DROP POLICY IF EXISTS "Users can manage their follows" ON user_follows;
DROP POLICY IF EXISTS "Users can manage their history" ON listening_history;
DROP POLICY IF EXISTS "Users can read their reset tokens" ON password_reset_tokens;

CREATE POLICY "Anyone can read genres" ON genres FOR SELECT USING (true);
CREATE POLICY "Anyone can read song_genres" ON song_genres FOR SELECT USING (true);
CREATE POLICY "Anyone can read song_artists" ON song_artists FOR SELECT USING (true);
CREATE POLICY "Anyone can read album_songs" ON album_songs FOR SELECT USING (true);

-- User-specific policies
CREATE POLICY "Users can manage their follows" ON user_follows 
  FOR ALL USING (auth.uid()::text = user_id::text OR user_id IS NULL);

CREATE POLICY "Users can manage their history" ON listening_history 
  FOR ALL USING (auth.uid()::text = user_id::text OR user_id IS NULL);

CREATE POLICY "Users can read their reset tokens" ON password_reset_tokens 
  FOR SELECT USING (true);

-- =====================
-- HELPER FUNCTIONS
-- =====================

-- Function to increment play count
CREATE OR REPLACE FUNCTION increment_play_count(song_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE songs SET play_count = play_count + 1 WHERE id = song_id;
END;
$$ LANGUAGE plpgsql;

-- Function to record listening history
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
  UPDATE songs SET play_count = play_count + 1 WHERE id = p_song_id;
  
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get random songs
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
  GROUP BY s.id, s.title, s.duration, s.audio_url, s.cover_url
  ORDER BY RANDOM()
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update monthly listeners (can be called by a cron job)
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
$$ LANGUAGE plpgsql;

-- =====================
-- DONE
-- =====================
SELECT 'Migration completed successfully!' as status;
