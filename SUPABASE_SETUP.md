# Supabase + Cloudinary Setup Guide

## 📊 Database Schema

### Tables Overview
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   artists   │────▶│   albums    │────▶│    songs    │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
┌─────────────┐     ┌─────────────┐           │
│  playlists  │────▶│playlist_songs│◀─────────┘
└─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐
│    users    │
└─────────────┘
```

---

## 🔧 Step 1: Create Supabase Project

1. Đi đến https://supabase.com
2. Đăng ký/Đăng nhập
3. Click "New Project"
4. Điền thông tin:
   - Project name: `soulsync-music`
   - Database password: (lưu lại!)
   - Region: Southeast Asia (Singapore)
5. Click "Create Project" và đợi ~2 phút

---

## 🗃️ Step 2: Create Database Tables

Vào **SQL Editor** trong Supabase Dashboard và chạy:

```sql
-- =====================
-- ARTISTS TABLE
-- =====================
CREATE TABLE artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  followers INTEGER DEFAULT 0,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================
-- ALBUMS TABLE
-- =====================
CREATE TABLE albums (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  artist_id UUID REFERENCES artists(id) ON DELETE CASCADE,
  cover_url TEXT,
  release_year INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================
-- SONGS TABLE
-- =====================
CREATE TABLE songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  artist_id UUID REFERENCES artists(id) ON DELETE CASCADE,
  album_id UUID REFERENCES albums(id) ON DELETE SET NULL,
  duration INTEGER NOT NULL, -- seconds
  audio_url TEXT NOT NULL,
  cover_url TEXT,
  cloudinary_public_id VARCHAR(255),
  play_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================
-- PLAYLISTS TABLE
-- =====================
CREATE TABLE playlists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  cover_url TEXT,
  user_id UUID, -- Optional: for user-specific playlists
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================
-- PLAYLIST_SONGS (Junction Table)
-- =====================
CREATE TABLE playlist_songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  playlist_id UUID REFERENCES playlists(id) ON DELETE CASCADE,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  position INTEGER,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(playlist_id, song_id)
);

-- =====================
-- USER_LIKED_SONGS
-- =====================
CREATE TABLE user_liked_songs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  song_id UUID REFERENCES songs(id) ON DELETE CASCADE,
  liked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, song_id)
);

-- =====================
-- INDEXES for Performance
-- =====================
CREATE INDEX idx_songs_artist ON songs(artist_id);
CREATE INDEX idx_songs_album ON songs(album_id);
CREATE INDEX idx_albums_artist ON albums(artist_id);
CREATE INDEX idx_playlist_songs_playlist ON playlist_songs(playlist_id);
CREATE INDEX idx_playlist_songs_song ON playlist_songs(song_id);

-- =====================
-- VIEWS for Easy Queries
-- =====================
CREATE OR REPLACE VIEW songs_with_details AS
SELECT 
  s.id,
  s.title,
  s.duration,
  s.audio_url,
  s.cover_url,
  s.play_count,
  s.created_at,
  a.name as artist_name,
  a.id as artist_id,
  al.name as album_name,
  al.id as album_id
FROM songs s
LEFT JOIN artists a ON s.artist_id = a.id
LEFT JOIN albums al ON s.album_id = al.id;
```

---

## 🔐 Step 3: Set Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE artists ENABLE ROW LEVEL SECURITY;
ALTER TABLE albums ENABLE ROW LEVEL SECURITY;
ALTER TABLE songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE playlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE playlist_songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_liked_songs ENABLE ROW LEVEL SECURITY;

-- Public read access for music data
CREATE POLICY "Anyone can read artists" ON artists FOR SELECT USING (true);
CREATE POLICY "Anyone can read albums" ON albums FOR SELECT USING (true);
CREATE POLICY "Anyone can read songs" ON songs FOR SELECT USING (true);
CREATE POLICY "Anyone can read public playlists" ON playlists FOR SELECT USING (is_public = true);
CREATE POLICY "Anyone can read playlist_songs" ON playlist_songs FOR SELECT USING (true);

-- Authenticated users can like songs
CREATE POLICY "Users can manage their likes" ON user_liked_songs 
  FOR ALL USING (auth.uid() = user_id);
```

---

## 📦 Step 4: Seed Initial Data

```sql
-- Insert Artists
INSERT INTO artists (id, name, image_url, followers) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'HIEUTHUHAI', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/artists/hieuthuhai.jpg', 2400000),
  ('a1000000-0000-0000-0000-000000000002', 'Sơn Tùng M-TP', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/artists/sontung.jpg', 1800000),
  ('a1000000-0000-0000-0000-000000000003', 'Phương Mỹ Chi', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/artists/phuongmychi.jpg', 3200000);

-- Insert Albums
INSERT INTO albums (id, name, artist_id, cover_url, release_year) VALUES
  ('b1000000-0000-0000-0000-000000000001', 'Trại sáng tác 2024', 'a1000000-0000-0000-0000-000000000001', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/albums/traisangtac.jpg', 2024),
  ('b1000000-0000-0000-0000-000000000002', 'M-TP Collection', 'a1000000-0000-0000-0000-000000000002', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/albums/mtp.jpg', 2023);

-- Insert Songs (Replace audio_url with your Cloudinary URLs)
INSERT INTO songs (title, artist_id, album_id, duration, audio_url, cover_url) VALUES
  ('Ai cũng phải bắt đầu từ đâu đó', 'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 245, 'https://res.cloudinary.com/YOUR_CLOUD/video/upload/songs/song1.mp3', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/covers/song1.jpg'),
  ('Ngân nga', 'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 312, 'https://res.cloudinary.com/YOUR_CLOUD/video/upload/songs/song2.mp3', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/covers/song2.jpg'),
  ('ẾCH NGOÀI ĐÁY GIẾNG', 'a1000000-0000-0000-0000-000000000003', NULL, 198, 'https://res.cloudinary.com/YOUR_CLOUD/video/upload/songs/song3.mp3', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/covers/song3.jpg'),
  ('Mưa tháng sáu', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000002', 267, 'https://res.cloudinary.com/YOUR_CLOUD/video/upload/songs/song4.mp3', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/covers/song4.jpg'),
  ('Em của ngày hôm qua', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000002', 289, 'https://res.cloudinary.com/YOUR_CLOUD/video/upload/songs/song5.mp3', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/covers/song5.jpg'),
  ('Lạc trôi', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000002', 215, 'https://res.cloudinary.com/YOUR_CLOUD/video/upload/songs/song6.mp3', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/covers/song6.jpg');

-- Insert Playlists
INSERT INTO playlists (id, name, description, cover_url) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'EM XINH SAY HI 2025', 'Những ca khúc hot nhất từ chương trình', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/playlists/emxinh.jpg'),
  ('c1000000-0000-0000-0000-000000000002', 'ANH TRAI SAY HI 2025', 'Playlist chill cho ngày mới', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/playlists/anhtrai.jpg'),
  ('c1000000-0000-0000-0000-000000000003', 'V-Pop Top Hits', 'Top các bài hát V-Pop hot nhất', 'https://res.cloudinary.com/YOUR_CLOUD/image/upload/playlists/vpop.jpg');
```

---

## ☁️ Step 5: Setup Cloudinary

1. Đi đến https://cloudinary.com
2. Đăng ký tài khoản (Free tier: 25GB)
3. Vào **Dashboard** → Copy:
   - Cloud Name
   - API Key
   - API Secret

4. Tạo **Upload Preset** (cho unsigned uploads):
   - Settings → Upload → Add upload preset
   - Signing Mode: **Unsigned**
   - Folder: `soulsync`
   - Save

---

## 🔑 Step 6: Get Supabase Credentials

Trong Supabase Dashboard → Settings → API:
- **Project URL**: `https://xxxxx.supabase.co`
- **anon public key**: `eyJhbGc...`

---

## 📱 Flutter Configuration

Tạo file `.env` hoặc config:

```dart
// lib/config/app_config.dart
class AppConfig {
  // Supabase
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  
  // Cloudinary
  static const String cloudinaryCloudName = 'YOUR_CLOUD_NAME';
  static const String cloudinaryUploadPreset = 'soulsync';
}
```

---

## 🎵 Upload Audio to Cloudinary

### Via Dashboard:
1. Media Library → Upload
2. Chọn file MP3
3. Copy URL từ "Delivery URL"

### Via API (curl):
```bash
curl -X POST "https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/raw/upload" \
  -F "file=@/path/to/song.mp3" \
  -F "upload_preset=soulsync" \
  -F "resource_type=raw"
```

Response chứa `secure_url` → Dùng làm `audio_url` trong Supabase.

---

## ✅ Checklist

- [ ] Tạo Supabase project
- [ ] Chạy SQL tạo tables
- [ ] Setup RLS policies
- [ ] Seed initial data
- [ ] Tạo Cloudinary account
- [ ] Upload test audio files
- [ ] Copy credentials vào Flutter app
- [ ] Test connection từ app

Có bảng xếp hạng bài hát:
- Theo số lượt nghe theo thể loại ballab, rap, pop,.. theo tuần
- Bảng xếp nghệ sĩ/ca sĩ theo tổng lượt nghe trong tuần
- Top những bài hát mới ra gần đây (1 tuần đổ lại)

Người dùng tự tạo được playlist có thể chỉnh private, public, lưu được bài hát yêu thích
Bài hát có thể có nhiều ca sĩ một list ca sĩ
Tìm kiếm chỉ tìm tuyệt đối real time.
Có thể phát ngẫu nhiên
Có thể hẹn giờ tắt.
Ấn vào nghệ sĩ/ca sĩ, có thể xem top 5 nhạc được nghe nhiều nhất, có nút xem được tất cả album,
Đăng nhập với google oauth.