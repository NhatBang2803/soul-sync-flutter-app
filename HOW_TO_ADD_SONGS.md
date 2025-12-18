# 🎵 Hướng Dẫn Thêm Bài Hát vào SoulSync

## 📋 Tổng Quan

Hướng dẫn chi tiết để seed mock data và thêm bài hát vào ứng dụng SoulSync.

---

## 🔥 Bước 1: Setup Firebase Console

### 1.1 Tạo Firestore Database

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project **music-app-70368**
3. Vào **Firestore Database** → Click **Create database**
4. Chọn **Start in test mode** (cho development)
5. Location: **asia-southeast1** (Singapore)
6. Click **Enable**

### 1.2 Cấu Hình Security Rules

Sau khi database được tạo, vào tab **Rules** và paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Public read cho songs, artists, albums
    match /songs/{songId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /artists/{artistId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /albums/{albumId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User data - chỉ user đó mới đọc/ghi được
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      match /{subCollection}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

Click **Publish**

### 1.3 Setup Firebase Storage (để lưu file nhạc)

1. Vào **Storage** → Click **Get started**
2. Chọn **Start in test mode**
3. Location: **asia-southeast1**
4. Click **Done**

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Public read for songs and covers
    match /songs/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /covers/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User avatars
    match /avatars/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🚀 Bước 2: Chạy App và Seed Mock Data

### 2.1 Chạy SoulSync App

```powershell
# Đảm bảo đang ở thư mục music_app
cd C:\Users\admin\Documents\MobileApp\MusicApp\music_app

# Chạy app (chọn 1 trong 3 cách):

# Option 1: Windows Desktop (nhanh)
flutter run -d windows

# Option 2: Chrome (test UI nhanh)
flutter run -d chrome

# Option 3: Android Emulator (chính xác nhất)
flutter emulators --launch Pixel_8
flutter run
```

### 2.2 Seed Mock Data từ App

1. **Mở app** và đợi nó load xong
2. **Vào tab Profile** (icon người dùng ở bottom navigation)
3. **Scroll xuống** và tìm mục **"🔧 Admin - Seed Data"** (màu xanh)
4. **Click vào** để mở Admin Panel
5. **Click "Seed Mock Data"**
6. Đợi 5-10 giây để script chạy
7. Khi thấy **"✅ Success!"** → Done!

### 2.3 Kiểm Tra Dữ Liệu Trên Firebase Console

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project → **Firestore Database**
3. Bạn sẽ thấy 3 collections:
   - ✅ **songs** (10 songs)
   - ✅ **artists** (5 artists)
   - ✅ **albums** (5 albums)

---

## 📊 Mock Data Đã Được Seed

### 👨‍🎤 Artists (5)
- The Weeknd
- Billie Eilish
- Ed Sheeran
- Taylor Swift
- Drake

### 💿 Albums (5)
- After Hours (The Weeknd)
- Happier Than Ever (Billie Eilish)
- Divide (Ed Sheeran)
- Midnights (Taylor Swift)
- Certified Lover Boy (Drake)

### 🎵 Songs (10)
1. Blinding Lights - The Weeknd
2. Happier Than Ever - Billie Eilish
3. Shape of You - Ed Sheeran
4. Anti-Hero - Taylor Swift
5. Way 2 Sexy - Drake
6. Save Your Tears - The Weeknd
7. bad guy - Billie Eilish
8. Perfect - Ed Sheeran
9. Lavender Haze - Taylor Swift
10. One Dance - Drake

---

## 🎧 Bước 3: Upload File Nhạc Thật (Optional)

Mock data hiện tại có **placeholder URLs** cho file nhạc. Để upload file MP3 thật:

### 3.1 Tải File Nhạc

Download file MP3 từ nguồn hợp pháp (YouTube Music, Spotify downloader with license, v.v.)

### 3.2 Upload lên Firebase Storage

**Cách 1: Từ Firebase Console (Manual)**

1. Vào **Storage** → Click vào folder **songs/**
2. Click **Upload file**
3. Chọn file MP3 (đặt tên: `song_1.mp3`, `song_2.mp3`, ...)
4. Sau khi upload, click vào file → Copy **Download URL**
5. Vào **Firestore Database** → Collection **songs** → Document `song_1`
6. Edit field `fileUrl` → Paste Download URL

**Cách 2: Từ Code (Programmatically)**

```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

Future<String> uploadSongFile(File file, String songId) async {
  final storage = FirebaseStorage.instance;
  final ref = storage.ref().child('songs/$songId.mp3');
  
  await ref.putFile(file);
  final url = await ref.getDownloadURL();
  
  return url;
}

// Sau đó update Firestore
await FirebaseFirestore.instance
    .collection('songs')
    .doc(songId)
    .update({'fileUrl': url});
```

### 3.3 Update Song với URL mới

Sau khi upload, cập nhật `fileUrl` trong Firestore để app có thể stream nhạc thật.

---

## ➕ Bước 4: Thêm Bài Hát Mới (Manual)

### 4.1 Từ Firebase Console

1. Vào **Firestore Database** → Collection **songs**
2. Click **Add document**
3. Document ID: `song_11` (hoặc auto-generate)
4. Thêm các fields:

```json
{
  "songId": "song_11",
  "songName": "Tên bài hát",
  "artistId": "artist_1",
  "artistName": "Tên nghệ sĩ",
  "albumId": "album_1",
  "albumName": "Tên album",
  "durationMs": 240000,
  "fileUrl": "https://storage.googleapis.com/...",
  "coverUrl": "https://i.scdn.co/image/...",
  "lyrics": "Lời bài hát...",
  "genre": "Pop",
  "releaseDate": "2024-01-01T00:00:00Z",
  "playCount": 0,
  "isExplicit": false,
  "createdAt": "2024-12-18T10:00:00Z"
}
```

### 4.2 Từ Code (Script)

Tạo file `lib/scripts/add_song.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addSong({
  required String songName,
  required String artistId,
  required String artistName,
  required String albumId,
  required String albumName,
  required int durationMs,
  required String fileUrl,
  required String coverUrl,
  String? lyrics,
  required String genre,
  bool isExplicit = false,
}) async {
  final db = FirebaseFirestore.instance;
  
  await db.collection('songs').add({
    'songName': songName,
    'artistId': artistId,
    'artistName': artistName,
    'albumId': albumId,
    'albumName': albumName,
    'durationMs': durationMs,
    'fileUrl': fileUrl,
    'coverUrl': coverUrl,
    'lyrics': lyrics ?? '',
    'genre': genre,
    'releaseDate': FieldValue.serverTimestamp(),
    'playCount': 0,
    'isExplicit': isExplicit,
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  print('✅ Song "$songName" added successfully!');
}

// Usage:
await addSong(
  songName: 'New Song Title',
  artistId: 'artist_1',
  artistName: 'The Weeknd',
  albumId: 'album_1',
  albumName: 'After Hours',
  durationMs: 210000,
  fileUrl: 'https://storage.googleapis.com/...',
  coverUrl: 'https://i.scdn.co/image/...',
  genre: 'Pop',
);
```

---

## 🔄 Clear Data (Reset)

Nếu muốn xóa tất cả data và seed lại:

1. Mở app → Vào **Admin Panel**
2. Click **"Clear All Data"** (button đỏ)
3. Confirm → Tất cả songs, artists, albums sẽ bị xóa
4. Click **"Seed Mock Data"** để thêm lại

---

## 🎨 Customize Mock Data

Edit file `lib/services/firestore_seeder.dart` để:
- Thêm/bớt artists
- Thêm/bớt albums
- Thêm/bớt songs
- Thay đổi thông tin (tên, ảnh, genre, v.v.)

Sau khi edit, chạy lại **Clear All Data** → **Seed Mock Data**

---

## 🐛 Troubleshooting

### Lỗi: "Permission Denied"

**Nguyên nhân:** Security Rules chưa đúng hoặc app chưa được authentication

**Giải pháp:**
1. Kiểm tra Security Rules trong Firebase Console
2. Đảm bảo rules allow read/write như hướng dẫn trên
3. Nếu dùng Authentication, đảm bảo user đã đăng nhập

### Lỗi: "Collection 'songs' not found"

**Nguyên nhân:** Firestore Database chưa được tạo

**Giải pháp:**
1. Vào Firebase Console → Firestore Database
2. Click **Create database**
3. Làm theo Bước 1.1

### Seed thất bại với lỗi timeout

**Nguyên nhân:** Network chậm hoặc quá nhiều data

**Giải pháp:**
1. Kiểm tra internet connection
2. Thử seed từng loại riêng (chỉ artists, chỉ songs, v.v.)
3. Giảm số lượng items trong seeder

### App không hiển thị dữ liệu sau khi seed

**Nguyên nhân:** UI chưa kết nối với Firestore

**Giải pháp:**
1. Restart app
2. Kiểm tra console logs
3. Đảm bảo `FirestoreService` đang được dùng trong UI pages

---

## 📚 Next Steps

1. ✅ Firebase Firestore đã setup
2. ✅ Mock data đã seed
3. ⬜ Tích hợp UI với FirestoreService
4. ⬜ Implement audio player (just_audio)
5. ⬜ Upload file MP3 thật
6. ⬜ Add Firebase Authentication
7. ⬜ Test offline caching

---

## 📞 Support

Nếu gặp vấn đề, check:
- Firebase Console: https://console.firebase.google.com/
- Flutter Docs: https://docs.flutter.dev/
- FirestoreService code: `lib/services/firestore_service.dart`
- Seeder code: `lib/services/firestore_seeder.dart`

---

**App:** SoulSync  
**Version:** 1.0  
**Last Updated:** December 18, 2025
