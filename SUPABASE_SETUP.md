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

Có bảng xếp hạng bài hát ở trang chủ:
- Theo số lượt nghe theo thể loại ballab, rap, pop,.. theo tuần
- Bảng xếp nghệ sĩ/ca sĩ theo tổng lượt nghe trong tuần
- Top những bài hát mới ra gần đây (1 tuần đổ lại)

Chức năng đăng ký:
- Người dùng có thể đăng ký tài khoản, yêu cầu nhập username, email, nhập mật khẩu (mã hóa, có icon con mắt để xem lại mật khẩu đã nhập), xác nhận mật khẩu, khi ấn xác nhận mật khẩu thì lập tức quay về trang đăng nhập.
Chức năng đăng nhập:
- Người dùng đăng nhập tài khoản bằng username hoặc email (nếu chuỗi có @ thì coi là mail, không có @ thì coi là username), mật khẩu, có icon mắt để xem lại mật khẩu đã nhập.
- Có thêm chức năng quên mật khẩu, khi người dùng quên mật khẩu thì người dùng nhập email, sau đó gửi email xác nhận, khi người dùng nhận được email xác nhận thì người dùng có thể thay đổi mật khẩu.
- Người dùng có thể đăng nhập với google oauth.

Bảng user: username, email, password (trống nếu đăng nhập với google), avatar_url, created_at, updated_at (mở rộng nếu cần thiết)
Người dùng có thể tạo được playlist có thể chỉnh private, public.
Bài hát có thể có nhiều ca sĩ (sửa database), một bài hát có thể thuộc nhiều album, một album có nhiều bài. 
Tìm kiếm theo tên bài hát, tên ca sĩ, tên album real time. Ví dụ trên thanh tìm kiếm nhập một chuỗi là "ai cũng phải bắt đầu từ đâu đó", thì sẽ tìm kiếm theo tên bài hát, tên ca sĩ, tên album, tên playlist có chứa chuỗi "ai cũng phải bắt đầu từ đâu đó".
Có mục hàng đợi trong miniplayer và trong player chính, mỗi khi người dùng thêm một bài hát vào hàng đợi thì nó sẽ được thêm vào hàng đợi, mỗi khi người dùng xóa một bài hát khỏi hàng đợi thì nó sẽ được xóa khỏi hàng đợi. Mỗi khi người dùng ấn vào album, playlist và ấn được bài hát hiển thị trong album đó thì toàn bộ bài hát của album playlist đó sẽ được thêm vào hàng đợi và chỉ có những bài hát đó mà thôi, ví dụ hàng đợi của người dùng đang có 5 bài hát trong hàng đợi, khi người dùng đang ở trong album thì khi người dùng ấn vào album thì toàn bộ bài hát của album đó sẽ được thêm vào hàng đợi và chỉ có những bài hát đó mà thôi, không có bài hát nào khác ngoài album đó.

Trang album:
- Hiển thị avatar album, trạng thái album(public, private tất nhiên dòng này chỉ xuất hiện với người dùng có quyền truy cập), tên album, số lượng người nghe, ngày tạo. (Sửa database nếu cần)
bên dưới là các bài hát trong album đó.
- Có một slider bên dưới đề xuất ngẫu nhiên các album khác 

Trang playlist:
- Hiển thị avatar playlist, trạng thái playlist(public, private tất nhiên dòng này chỉ xuất hiện với người dùng có quyền truy cập), tên playlist, số lượng người nghe, ngày tạo. (Sửa database nếu cần)
bên dưới là các bài hát trong playlist đó.

Trang tài khoản:
- Ở icon bánh răng trên header thì xóa bỏ.
- Ở khối thống kê đơn giản đang mockdata playlist, nghệ sĩ và bài hát với tiêu đề chưa rõ ràng, xóa hoàn toàn các khối thông tin và mục bên dưới.
- Sửa lại thành 4 khối thông tin chính nằm xếp chồng lên nhau:
+ Mỗi khối có 2 phần là header và boy nằm xếp chồng, header gồm title bên trái: "Lịch sử nghe gần đây,...", bên phải là nút xem tất cả. Còn với body thì là danh sách tương ứng.
+ 4 khối thông tin gồm Lịch sử nghe gần đây, nghệ sĩ đang theo dõi, playlist đã tạo, album nghe gần đây. Đối với bài hát thì danh sách bảng dọc, nghệ sĩ và album/playlist thì danh sách ngang như các slider.

Có chức năng phát bài hát ngẫu nhiên. Lấy các bài hát có trong hàng đợi:
- Trường hợp không có nhãn lặp: nếu đã phát hết bài hát trong hàng đợi thì gọi một lệnh lấy 10 bài ngẫu nhiên trong cơ sở dữ liệu thêm vào hàng đợi và tiếp tục phát.
- Trường hợp lặp chỉ một bài: chức năng phát ngẫu nhiên sẽ không hoạt động và chỉ phát một bài hát duy nhất.
- Trường hợp lặp theo hàng đợi: sẽ chỉ phát ngẫu nhiên các bài có trong hàng đợi, khi hết bài hát trong hàng đợi thì sẽ quay lại đầu hàng đợi và tiếp tục phát.

- Có thể hẹn giờ tắt.

Trang nghệ sĩ/ca sĩ:
- Hiển thị avatar nghệ sĩ, tên nghệ sĩ, số lượng người nghe trong tháng. (Sửa database nếu cần).
- Kế bên có nút theo dõi.

- Bên dưới trang của nghệ sĩ có 3 khối thông tin được bố trí tương tự profile của người dùng nhưng:
+ Khối bài hát được nghe nhiều nhất, chỉ hiện 5 bài hát được nghe nhiều nhất của nghệ sĩ/ca sĩ đó.
+ Khối album hiện tương tự như cách hiện của user, nhưng ấn vào xem tất cả sẽ liệt kê hết toàn bộ album và từng bài hát của nghệ sĩ và ca sĩ đó và có thể ấn vào một bài bất kì để nghe, nhóm theo từng album.
+ Khối Featering: hiện các bài hát có nghệ sĩ ca sĩ khác tham gia, có thể ấn vào một bài bất kì để nghe.

