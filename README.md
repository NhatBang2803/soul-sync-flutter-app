# 🎵 SoulSync - Music Streaming App

![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)
![Cloudinary](https://img.shields.io/badge/Cloudinary-Storage-3448C5?logo=cloudinary)

Ứng dụng nghe nhạc đa nền tảng được xây dựng bằng **Flutter**, với backend **Supabase** và lưu trữ media trên **Cloudinary**.

---

## 📋 Mục Lục

- [Tính Năng](#-tính-năng)
- [Yêu Cầu Hệ Thống](#-yêu-cầu-hệ-thống)
- [Cài Đặt](#-cài-đặt)
- [Cấu Hình](#️-cấu-hình)
- [Chạy Ứng Dụng](#-chạy-ứng-dụng)
- [Admin Web Portal](#-admin-web-portal)
- [Build cho iOS](#-build-cho-ios)
- [Cấu Trúc Dự Án](#-cấu-trúc-dự-án)
- [Database Schema](#️-database-schema)

---

## ✨ Tính Năng

### 🎧 Người Dùng
- Đăng ký / Đăng nhập (Email hoặc Google OAuth)
- Tìm kiếm bài hát, nghệ sĩ, album, playlist theo thời gian thực
- Phát nhạc với hàng đợi (queue) linh hoạt
- Tạo playlist cá nhân (public/private)
- Like bài hát yêu thích
- Xem lịch sử nghe nhạc
- Theo dõi nghệ sĩ

### 📊 Bảng Xếp Hạng
- Top bài hát theo thể loại (Ballad, Rap, Pop...) theo tuần
- Top nghệ sĩ theo lượt nghe trong tuần
- Bài hát mới ra mắt (7 ngày gần đây)

### 🎮 Player
- Mini player và full-screen player
- Hàng đợi với chức năng shuffle, repeat
- Hẹn giờ tắt nhạc
- Phát nhạc ngẫu nhiên khi hết hàng đợi

---

## 💻 Yêu Cầu Hệ Thống

| Thành phần | Phiên bản |
|------------|-----------|
| Flutter | 3.9.2+ |
| Dart | 3.3+ |
| Node.js (cho admin-web) | 18+ |

### Yêu Cầu Theo Nền Tảng

| Nền tảng | Yêu cầu |
|----------|---------|
| **Android** | Android Studio, Android SDK |
| **iOS** | macOS + Xcode 15+ + CocoaPods |
| **Linux** | `libmpv-dev`, `libwebkit2gtk-4.1-dev` |
| **Windows** | Visual Studio với C++ workload |
| **Web** | Chrome/Edge |

---

## 🚀 Cài Đặt

### 1. Clone Repository

```bash
git clone https://github.com/NhatBang2803/soul-sync-flutter-app.git
cd soul-sync-flutter-app
```

### 2. Cài Đặt Dependencies

```bash
# Flutter dependencies
flutter pub get

# Linux - Cài đặt thư viện audio
# Ubuntu/Debian:
sudo apt install libmpv-dev libwebkit2gtk-4.1-dev

# Fedora:
sudo dnf install mpv-libs-devel webkit2gtk4.1-devel
```

### 3. Kiểm Tra Môi Trường

```bash
flutter doctor
```

Đảm bảo các mục cần thiết hiển thị ✅

---

## ⚙️ Cấu Hình

### Bước 1: Tạo File `.env`

Sao chép file mẫu và điền thông tin:

```bash
cp .example.env .env
```

Nội dung file `.env`:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset
CLOUDINARY_API_KEY=your_api_key

# Google OAuth (tùy chọn)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

### Bước 2: Thiết Lập Supabase

1. Truy cập [supabase.com](https://supabase.com) → **New Project**
2. Tạo project tại region **Southeast Asia (Singapore)**
3. Vào **SQL Editor** → Chạy các file SQL trong thư mục `database/` **theo thứ tự**:

```bash
# Bước 1: Chạy các file schema chính
p1-schema.sql       # Tạo tables, indexes, views
p2-permission.sql   # Cấu hình RLS và permissions
p3-backup.sql       # Import dữ liệu mẫu (tùy chọn)
p4-migrations.sql   # Migrations bổ sung

# Bước 2: Chạy các file fix (quan trọng!)
fix_ranking_rpc.sql   # Fix functions xếp hạng
fix_history_rpc.sql   # Fix functions lịch sử nghe
```

4. Vào **Settings → API** → Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public key** → `SUPABASE_ANON_KEY`

> 📖 Xem chi tiết tại [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)

### Bước 3: Thiết Lập Cloudinary

1. Truy cập [cloudinary.com](https://cloudinary.com) → Đăng ký (Free tier: 25GB)
2. Vào **Dashboard** → Copy **Cloud Name**
3. Vào **Settings → Upload → Add upload preset**:
   - Signing Mode: **Unsigned**
   - Folder: `soulsync`
4. Upload audio và hình ảnh lên Cloudinary

---

## ▶️ Chạy Ứng Dụng

### Linux/Windows/macOS Desktop

```bash
flutter run -d linux   # Linux
flutter run -d windows # Windows
flutter run -d macos   # macOS
```

### Android

```bash
# Kết nối thiết bị hoặc mở Android Emulator
flutter run -d android
```

### Web

```bash
flutter run -d chrome
```

### iOS (yêu cầu macOS)

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

---

## 🌐 Admin Web Portal

Admin portal được xây dựng bằng **React + TypeScript + Vite** để quản lý:
- Người dùng
- Bài hát, Album, Playlist
- Nghệ sĩ
- Podcast
- Backup/Restore database

### Chạy Admin Web

```bash
cd admin-web

# Cài dependencies
npm install

# Tạo file .env
cp .example.env .env
# Điền SUPABASE_URL và SUPABASE_ANON_KEY

# Chạy development server
npm run dev
```

Truy cập: `http://localhost:5173`

---

## 📱 Build cho iOS

> ⚠️ **Lưu ý:** Build iOS **BẮT BUỘC** phải có máy macOS

### Trên macOS

#### 1. Cài đặt Xcode

```bash
# Mở App Store → Tải Xcode
# Sau khi cài xong:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

#### 2. Cài đặt CocoaPods

```bash
sudo gem install cocoapods
# hoặc
brew install cocoapods
```

#### 3. Cài dependencies iOS

```bash
cd ios
pod install
cd ..
```

#### 4. Cấu hình trong `ios/Runner/Info.plist`

Thêm các key sau cho audio background và camera:

```xml
<!-- Audio background -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

<!-- Photo library access -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Ứng dụng cần truy cập thư viện ảnh để chọn avatar</string>

<!-- Camera access -->
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần truy cập camera để chụp ảnh</string>
```

#### 5. Chạy trên Simulator

```bash
open -a Simulator
flutter run -d ios
```

#### 6. Chạy trên iPhone thật

1. Kết nối iPhone qua USB
2. Mở `ios/Runner.xcworkspace` bằng Xcode
3. Vào **Signing & Capabilities** → Chọn Team (Apple Developer Account)
4. Build và Run

### Build iOS từ Linux (CI/CD)

Sử dụng các dịch vụ CI/CD với macOS runner:

| Dịch vụ | Free Tier |
|---------|-----------|
| [Codemagic](https://codemagic.io) | 500 phút/tháng (M1) |
| [GitHub Actions](https://github.com/features/actions) | 2000 phút/tháng |
| [Bitrise](https://bitrise.io) | 300 phút/tháng |

> ⚠️ Cần **Apple Developer Account** ($99/năm) để ký và cài app lên iPhone thật

---

## 📁 Cấu Trúc Dự Án

```
soul-sync-flutter-app/
├── lib/                          # Source code Flutter
│   ├── components/               # UI Components tái sử dụng
│   ├── config/                   # App configuration
│   ├── core/                     # Core utilities
│   ├── models/                   # Data models
│   ├── pages/                    # Các trang UI
│   ├── services/                 # Business logic
│   │   ├── auth_service.dart     # Xác thực
│   │   ├── audio_player_service.dart  # Phát nhạc
│   │   ├── queue_service.dart    # Quản lý hàng đợi
│   │   ├── supabase_service.dart # Gọi API Supabase
│   │   └── cloudinary_service.dart    # Upload media
│   ├── main.dart                 # Entry point
│   ├── home_page.dart            # Trang chủ
│   ├── search_page.dart          # Tìm kiếm
│   ├── library_page.dart         # Thư viện
│   ├── profile_page.dart         # Tài khoản
│   └── now_playing_page.dart     # Player đầy đủ
├── admin-web/                    # Admin portal (React/Vite)
├── database/                     # SQL schema & migrations
│   └── newdatabase/              # Schema files (p01-p08)
├── assets/                       # Hình ảnh, fonts
├── android/                      # Android native config
├── ios/                          # iOS native config
├── linux/                        # Linux native config
├── macos/                        # macOS native config
├── windows/                      # Windows native config
├── web/                          # Web config
├── .env                          # Environment variables
├── pubspec.yaml                  # Flutter dependencies
└── README.md                     # Tài liệu này
```

---

## 🗃️ Database Schema

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
┌─────────────┐     ┌─────────────┐
│    users    │────▶│user_liked_songs│
└─────────────┘     └─────────────┘
```

### Bảng Chính

| Bảng | Mô tả |
|------|-------|
| `users` | Thông tin người dùng |
| `artists` | Nghệ sĩ/Ca sĩ |
| `albums` | Album nhạc |
| `songs` | Bài hát |
| `playlists` | Playlist |
| `playlist_songs` | Bài hát trong playlist |
| `user_liked_songs` | Bài hát đã like |
| `listening_history` | Lịch sử nghe |
| `user_follows_artist` | Theo dõi nghệ sĩ |
| `podcasts` | Podcast |
| `podcast_episodes` | Tập podcast |

> 📖 Xem chi tiết tại [database/README.md](./database/README.md)

---

## 🔧 Troubleshooting

### Lỗi thường gặp

| Lỗi | Giải pháp |
|-----|-----------|
| `flutter pub get` thất bại | Chạy `flutter clean` rồi thử lại |
| Không kết nối được Supabase | Kiểm tra `SUPABASE_URL` và `SUPABASE_ANON_KEY` |
| Audio không phát (Linux) | Cài `libmpv-dev` |
| Pod install thất bại (iOS) | Chạy `pod repo update` |
| Google Sign-In lỗi | Cấu hình OAuth credentials đúng |

### Xóa cache và build lại

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📄 License

Dự án này được phát triển cho mục đích học tập.

---

## 👨‍💻 Tác Giả

**Soul Sync Team** - 2025

---

*Hãy ⭐ repo này nếu bạn thấy hữu ích!*
