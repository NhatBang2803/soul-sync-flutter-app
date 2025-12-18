# SoulSync - Cấu Trúc Database

## Tổng Quan
Database cho ứng dụng nghe nhạc **SoulSync** được thiết kế để lưu trữ thông tin về người dùng, bài hát, nghệ sĩ, album, playlist và lịch sử nghe nhạc.

---

## Sơ Đồ Quan Hệ

```
Users ──┬── Playlists ── PlaylistSongs ── Songs
        │                                   │
        ├── Favorites ─────────────────────┤
        │                                   │
        ├── ListeningHistory ───────────────┤
        │                                   │
        └── FollowedArtists ── Artists ─────┤
                                │           │
                                └── Albums ─┘
```

---

## 1. Bảng `users` - Thông Tin Người Dùng

```sql
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    avatar_url VARCHAR(500),
    date_of_birth DATE,
    country VARCHAR(50),
    premium_status BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Mô tả:**
- Lưu trữ thông tin cơ bản của người dùng
- `premium_status`: 0 = Free, 1 = Premium
- `password_hash`: Mật khẩu đã được mã hóa (bcrypt)

---

## 2. Bảng `artists` - Nghệ Sĩ

```sql
CREATE TABLE artists (
    artist_id INTEGER PRIMARY KEY AUTOINCREMENT,
    artist_name VARCHAR(200) NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(500),
    banner_url VARCHAR(500),
    verified BOOLEAN DEFAULT 0,
    monthly_listeners INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Mô tả:**
- Thông tin về nghệ sĩ/ca sĩ
- `verified`: Tài khoản đã xác thực hay chưa
- `monthly_listeners`: Số lượt nghe hàng tháng

---

## 3. Bảng `albums` - Album

```sql
CREATE TABLE albums (
    album_id INTEGER PRIMARY KEY AUTOINCREMENT,
    album_name VARCHAR(200) NOT NULL,
    artist_id INTEGER NOT NULL,
    cover_url VARCHAR(500),
    release_date DATE,
    album_type VARCHAR(20), -- 'single', 'album', 'compilation'
    total_tracks INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE
);
```

**Mô tả:**
- Thông tin về album/đĩa nhạc
- `album_type`: Loại album (single, album, compilation)

---

## 4. Bảng `songs` - Bài Hát

```sql
CREATE TABLE songs (
    song_id INTEGER PRIMARY KEY AUTOINCREMENT,
    song_name VARCHAR(200) NOT NULL,
    artist_id INTEGER NOT NULL,
    album_id INTEGER,
    duration_ms INTEGER NOT NULL, -- Thời lượng tính bằng milliseconds
    file_url VARCHAR(500) NOT NULL,
    cover_url VARCHAR(500),
    lyrics TEXT,
    genre VARCHAR(50),
    release_date DATE,
    play_count INTEGER DEFAULT 0,
    is_explicit BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    FOREIGN KEY (album_id) REFERENCES albums(album_id) ON DELETE SET NULL
);
```

**Mô tả:**
- Thông tin chi tiết về bài hát
- `duration_ms`: Thời lượng bài hát (milliseconds)
- `is_explicit`: Bài hát có nội dung nhạy cảm hay không
- `play_count`: Tổng số lượt nghe

---

## 5. Bảng `playlists` - Danh Sách Phát

```sql
CREATE TABLE playlists (
    playlist_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    playlist_name VARCHAR(200) NOT NULL,
    description TEXT,
    cover_url VARCHAR(500),
    is_public BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Mô tả:**
- Playlist do người dùng tạo
- `is_public`: Công khai (1) hay riêng tư (0)

---

## 6. Bảng `playlist_songs` - Bài Hát Trong Playlist

```sql
CREATE TABLE playlist_songs (
    playlist_song_id INTEGER PRIMARY KEY AUTOINCREMENT,
    playlist_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    position INTEGER NOT NULL, -- Thứ tự bài hát trong playlist
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE,
    UNIQUE(playlist_id, song_id)
);
```

**Mô tả:**
- Bảng liên kết giữa playlist và bài hát
- `position`: Vị trí của bài hát trong playlist

---

## 7. Bảng `favorites` - Bài Hát Yêu Thích

```sql
CREATE TABLE favorites (
    favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE,
    UNIQUE(user_id, song_id)
);
```

**Mô tả:**
- Danh sách bài hát yêu thích của người dùng

---

## 8. Bảng `listening_history` - Lịch Sử Nghe Nhạc

```sql
CREATE TABLE listening_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration_played_ms INTEGER, -- Thời gian đã nghe (ms)
    completed BOOLEAN DEFAULT 0, -- Nghe hết bài hay chưa
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
);
```

**Mô tả:**
- Ghi lại lịch sử nghe nhạc của người dùng
- `duration_played_ms`: Thời gian thực tế đã nghe
- `completed`: Đã nghe hết bài hay chưa

---

## 9. Bảng `followed_artists` - Nghệ Sĩ Theo Dõi

```sql
CREATE TABLE followed_artists (
    follow_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    artist_id INTEGER NOT NULL,
    followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
    UNIQUE(user_id, artist_id)
);
```

**Mô tả:**
- Danh sách nghệ sĩ mà người dùng theo dõi

---

## 10. Bảng `search_history` - Lịch Sử Tìm Kiếm

```sql
CREATE TABLE search_history (
    search_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    search_query VARCHAR(200) NOT NULL,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Mô tả:**
- Lưu trữ các từ khóa tìm kiếm của người dùng

---

## 11. Bảng `recently_played` - Bài Hát Phát Gần Đây

```sql
CREATE TABLE recently_played (
    recent_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
);
```

**Mô tả:**
- Lưu các bài hát đã phát gần đây (giới hạn 50 bài mới nhất)

---

## Indexes Quan Trọng

```sql
-- Tăng tốc độ tìm kiếm bài hát
CREATE INDEX idx_songs_name ON songs(song_name);
CREATE INDEX idx_songs_artist ON songs(artist_id);
CREATE INDEX idx_songs_album ON songs(album_id);

-- Tăng tốc độ truy vấn playlist
CREATE INDEX idx_playlists_user ON playlists(user_id);
CREATE INDEX idx_playlist_songs_playlist ON playlist_songs(playlist_id);

-- Tăng tốc độ truy vấn lịch sử
CREATE INDEX idx_listening_history_user ON listening_history(user_id);
CREATE INDEX idx_listening_history_date ON listening_history(played_at);

-- Tăng tốc độ tìm kiếm nghệ sĩ
CREATE INDEX idx_artists_name ON artists(artist_name);

-- Tăng tốc độ truy vấn favorites
CREATE INDEX idx_favorites_user ON favorites(user_id);
```

---

## Queries Thường Dùng

### 1. Lấy Top 50 Bài Hát Phổ Biến

```sql
SELECT s.*, a.artist_name
FROM songs s
JOIN artists a ON s.artist_id = a.artist_id
ORDER BY s.play_count DESC
LIMIT 50;
```

### 2. Lấy Playlist Của Người Dùng

```sql
SELECT p.*, COUNT(ps.song_id) as total_songs
FROM playlists p
LEFT JOIN playlist_songs ps ON p.playlist_id = ps.playlist_id
WHERE p.user_id = ?
GROUP BY p.playlist_id;
```

### 3. Lấy Bài Hát Trong Playlist

```sql
SELECT s.*, a.artist_name, ps.position
FROM playlist_songs ps
JOIN songs s ON ps.song_id = s.song_id
JOIN artists a ON s.artist_id = a.artist_id
WHERE ps.playlist_id = ?
ORDER BY ps.position;
```

### 4. Lấy Lịch Sử Nghe Nhạc (30 ngày gần nhất)

```sql
SELECT s.*, a.artist_name, lh.played_at
FROM listening_history lh
JOIN songs s ON lh.song_id = s.song_id
JOIN artists a ON s.artist_id = a.artist_id
WHERE lh.user_id = ?
  AND lh.played_at >= datetime('now', '-30 days')
ORDER BY lh.played_at DESC;
```

### 5. Tìm Kiếm Bài Hát

```sql
SELECT s.*, a.artist_name, al.album_name
FROM songs s
JOIN artists a ON s.artist_id = a.artist_id
LEFT JOIN albums al ON s.album_id = al.album_id
WHERE s.song_name LIKE ?
   OR a.artist_name LIKE ?
LIMIT 20;
```

### 6. Gợi Ý Bài Hát Dựa Trên Lịch Sử

```sql
SELECT s.*, a.artist_name, COUNT(*) as recommendation_score
FROM listening_history lh1
JOIN listening_history lh2 ON lh1.user_id != lh2.user_id 
                            AND lh1.song_id = lh2.song_id
JOIN songs s ON lh2.song_id = s.song_id
JOIN artists a ON s.artist_id = a.artist_id
WHERE lh1.user_id = ?
  AND lh2.song_id NOT IN (
    SELECT song_id FROM listening_history WHERE user_id = ?
  )
GROUP BY s.song_id
ORDER BY recommendation_score DESC
LIMIT 20;
```

---

## Công Nghệ Đề Xuất

- **SQLite**: Cho ứng dụng mobile (offline-first)
- **PostgreSQL**: Cho backend server (nếu cần đồng bộ cloud)
- **Firebase Firestore**: Giải pháp NoSQL nhanh chóng

---

## Migration & Seeding

Xem thêm:
- `migrations/`: Scripts để tạo và cập nhật database schema
- `seeds/`: Dữ liệu mẫu để test

---

## Backup & Security

- **Backup**: Tự động backup database mỗi 24h
- **Encryption**: Mã hóa thông tin nhạy cảm (password, payment info)
- **Access Control**: Phân quyền truy cập theo role (user, admin, artist)

---

**Version:** 1.0  
**Last Updated:** December 18, 2025  
**Maintainer:** SoulSync Development Team
