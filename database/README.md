# Soul Sync Database - Setup Guide

## 📋 Tổng Quan

Thư mục này chứa các file SQL để thiết lập database cho ứng dụng Soul Sync trên Supabase.

## 🗂️ Cấu Trúc Files

| File | Mục đích | Thứ tự |
|------|----------|--------|
| `p1-schema.sql` | Tạo tables, indexes, views | 1️⃣ |
| `p2-permission.sql` | Cấu hình RLS và permissions | 2️⃣ |
| `p3-backup.sql` | Import dữ liệu mẫu (tùy chọn) | 3️⃣ |
| `p4-migrations.sql` | Migrations bổ sung | 4️⃣ |
| `fix_ranking_rpc.sql` | Fix functions xếp hạng | 5️⃣ |
| `fix_history_rpc.sql` | Fix functions lịch sử nghe | 6️⃣ |

---

## 🚀 Hướng Dẫn Setup

### Setup Từ Đầu (Fresh Install)

1. Truy cập [Supabase Dashboard](https://supabase.com) → Tạo project mới
2. Vào **SQL Editor**
3. Chạy tuần tự các file theo thứ tự:

```sql
-- Bước 1: Schema chính
p1-schema.sql

-- Bước 2: Permissions
p2-permission.sql

-- Bước 3: Dữ liệu mẫu (tùy chọn)
p3-backup.sql

-- Bước 4: Migrations
p4-migrations.sql

-- Bước 5: Fix functions
fix_ranking_rpc.sql
fix_history_rpc.sql
```

> ⚠️ **Quan trọng:** Phải chạy đúng thứ tự vì các file phụ thuộc lẫn nhau!

---

## 📊 Database Schema

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
┌─────────────┐     ┌─────────────────┐
│    users    │────▶│ listening_history│
└─────────────┘     └─────────────────┘
```

### Bảng Chính

| Bảng | Mô tả |
|------|-------|
| `users` | Thông tin người dùng |
| `artists` | Nghệ sĩ/Ca sĩ |
| `albums` | Album nhạc |
| `songs` | Bài hát |
| `genres` | Thể loại nhạc |
| `song_genres` | Liên kết bài hát - thể loại |
| `playlists` | Playlist |
| `playlist_songs` | Bài hát trong playlist |
| `user_liked_songs` | Bài hát đã like |
| `user_liked_albums` | Album đã like |
| `user_follows_artist` | Theo dõi nghệ sĩ |
| `listening_history` | Lịch sử nghe |
| `podcasts` | Podcast |
| `podcast_episodes` | Tập podcast |

---

## 🔧 Các Functions Quan Trọng

| Function | Mô tả |
|----------|-------|
| `fn_get_weekly_song_rankings(genre)` | Xếp hạng bài hát theo tuần |
| `fn_get_weekly_artist_rankings()` | Xếp hạng nghệ sĩ theo tuần |
| `fn_get_new_releases(days)` | Bài hát mới ra mắt |
| `fn_get_random_songs(limit)` | Lấy bài hát ngẫu nhiên |
| `fn_get_recommended_songs(user_id)` | Đề xuất bài hát |
| `get_unique_recently_played(user_id)` | Lịch sử nghe (unique) |

---

## ⚙️ Cấu Hình Security Mode

### Development Mode (Mặc định)
- RLS có thể disabled để dễ test
- Phù hợp cho: phát triển local, testing

### Production Mode
- RLS enabled với policies đầy đủ
- Cần Supabase Auth

---

## � Kiểm Tra Database

```sql
-- Kiểm tra tables đã tạo
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Kiểm tra functions
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public';

-- Test function xếp hạng
SELECT * FROM fn_get_weekly_song_rankings('pop');

-- Test function bài hát ngẫu nhiên
SELECT * FROM fn_get_random_songs(5);
```

---

## ⚠️ Troubleshooting

| Lỗi | Giải pháp |
|-----|-----------|
| `relation does not exist` | Chạy lại `p1-schema.sql` |
| `function does not exist` | Chạy lại các file fix |
| `permission denied` | Chạy lại `p2-permission.sql` |
| Dữ liệu rỗng | Chạy `p3-backup.sql` để import data mẫu |

---

## 🔄 Reset Database

Nếu cần reset hoàn toàn:

```sql
-- Xóa tất cả tables (CẢNH BÁO: Mất hết dữ liệu!)
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

-- Sau đó chạy lại từ p1-schema.sql
```

---

## 📞 Hỗ Trợ

- Nếu gặp lỗi, check output của từng file SQL
- Đảm bảo chạy đúng thứ tự
- Kiểm tra Supabase logs để debug