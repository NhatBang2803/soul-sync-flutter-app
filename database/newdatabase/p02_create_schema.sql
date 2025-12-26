-- =====================================================
-- Soul Sync Database - P02: CREATE SCHEMA
-- Mục đích: Tạo cấu trúc database (Tables, Indexes)
-- Thứ tự chạy: 2 (sau p01_initialize_database.sql)
-- Ngày tạo: 2025-12-27
-- =====================================================

-- =====================
-- PHẦN 1: TẠO BẢNG CHÍNH (CORE TABLES)
-- =====================

-- Users table
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

-- Artists table
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

-- Genres table
CREATE TABLE genres (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    color VARCHAR(7) DEFAULT '#6366F1',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Albums table
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

-- Songs table
CREATE TABLE songs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    duration INTEGER NOT NULL DEFAULT 0,
    audio_url TEXT,
    cover_url TEXT,
    play_count INTEGER DEFAULT 0,
    album_id UUID REFERENCES albums(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Playlists table
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

-- Podcasts table
CREATE TABLE podcasts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    host_name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    category VARCHAR(100) DEFAULT 'General',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Podcast Episodes table
CREATE TABLE podcast_episodes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    podcast_id UUID NOT NULL REFERENCES podcasts(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    audio_url TEXT NOT NULL,
    duration INTEGER DEFAULT 0,
    play_count INTEGER DEFAULT 0,
    published_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- PHẦN 2: TẠO BẢNG JUNCTION (MANY-TO-MANY RELATIONSHIPS)
-- =====================

-- Song ↔ Artist junction table
CREATE TABLE song_artists (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'main',
    position INTEGER DEFAULT 0,
    UNIQUE(song_id, artist_id)
);

-- Album ↔ Artist junction table
CREATE TABLE album_artists (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
    artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    UNIQUE(album_id, artist_id)
);

-- Album ↔ Song junction table
CREATE TABLE album_songs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    album_id UUID NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
    song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    track_number INTEGER DEFAULT 1,
    UNIQUE(album_id, song_id)
);

-- Song ↔ Genre junction table
CREATE TABLE song_genres (
    song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    genre_id UUID NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (song_id, genre_id)
);

-- Playlist ↔ Song junction table
CREATE TABLE playlist_songs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    playlist_id UUID NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
    song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    position INTEGER DEFAULT 0,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(playlist_id, song_id)
);

-- =====================
-- PHẦN 3: TẠO BẢNG TƯƠNG TÁC NGƯỜI DÙNG (USER INTERACTIONS)
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

-- User saved podcasts
CREATE TABLE user_saved_podcasts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    podcast_id UUID NOT NULL REFERENCES podcasts(id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, podcast_id)
);

-- =====================
-- PHẦN 4: TẠO BẢNG LỊCH SỬ (HISTORY TRACKING)
-- =====================

-- Listening history
CREATE TABLE listening_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    song_id UUID NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    listened_at TIMESTAMPTZ DEFAULT NOW(),
    duration_played INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE
);

-- Podcast listening history
CREATE TABLE podcast_listening_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    episode_id UUID NOT NULL REFERENCES podcast_episodes(id) ON DELETE CASCADE,
    listened_at TIMESTAMPTZ DEFAULT NOW(),
    duration_played INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE
);

-- =====================
-- PHẦN 5: TẠO INDEXES ĐỂ TỐI ƯU PERFORMANCE
-- =====================

-- User indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- Song indexes
CREATE INDEX idx_songs_title ON songs(title);
CREATE INDEX idx_songs_play_count ON songs(play_count DESC);
CREATE INDEX idx_songs_album ON songs(album_id);

-- Artist indexes
CREATE INDEX idx_artists_name ON artists(name);

-- Album indexes
CREATE INDEX idx_albums_name ON albums(name);

-- Junction table indexes
CREATE INDEX idx_song_artists_song ON song_artists(song_id);
CREATE INDEX idx_song_artists_artist ON song_artists(artist_id);
CREATE INDEX idx_album_songs_album ON album_songs(album_id);
CREATE INDEX idx_album_songs_song ON album_songs(song_id);
CREATE INDEX idx_song_genres_song ON song_genres(song_id);
CREATE INDEX idx_song_genres_genre ON song_genres(genre_id);
CREATE INDEX idx_playlist_songs_playlist ON playlist_songs(playlist_id);

-- User interaction indexes
CREATE INDEX idx_user_follows_user ON user_follows(user_id);
CREATE INDEX idx_user_follows_artist ON user_follows(artist_id);
CREATE INDEX idx_user_liked_songs_user ON user_liked_songs(user_id);
CREATE INDEX idx_user_liked_songs_song ON user_liked_songs(song_id);
CREATE INDEX idx_user_liked_albums_user ON user_liked_albums(user_id);
CREATE INDEX idx_user_liked_albums_album ON user_liked_albums(album_id);

-- History indexes
CREATE INDEX idx_listening_history_user ON listening_history(user_id);
CREATE INDEX idx_listening_history_song ON listening_history(song_id);
CREATE INDEX idx_listening_history_time ON listening_history(listened_at DESC);

-- Podcast indexes
CREATE INDEX idx_podcasts_title ON podcasts(title);
CREATE INDEX idx_podcasts_category ON podcasts(category);
CREATE INDEX idx_podcast_episodes_podcast ON podcast_episodes(podcast_id);
CREATE INDEX idx_podcast_episodes_published ON podcast_episodes(published_at DESC);
CREATE INDEX idx_podcast_episodes_play_count ON podcast_episodes(play_count DESC);
CREATE INDEX idx_user_saved_podcasts_user ON user_saved_podcasts(user_id);
CREATE INDEX idx_user_saved_podcasts_podcast ON user_saved_podcasts(podcast_id);
CREATE INDEX idx_podcast_listening_history_user ON podcast_listening_history(user_id);
CREATE INDEX idx_podcast_listening_history_episode ON podcast_listening_history(episode_id);
CREATE INDEX idx_podcast_listening_history_time ON podcast_listening_history(listened_at DESC);

-- =====================
-- PHẦN 6: THÔNG BÁO HOÀN THÀNH
-- =====================
SELECT 'P02: Schema created successfully! Run p03_create_views.sql next.' as status;