# 🚀 Hướng Dẫn Setup Firebase cho SoulSync

## 📋 Tổng Quan

Hướng dẫn này giúp bạn cấu hình Firebase cho ứng dụng **SoulSync** - một ứng dụng nghe nhạc hiện đại.

---

## ✅ Prerequisites

1. **Node.js** đã cài đặt (để dùng Firebase CLI)
2. **Tài khoản Google** (để tạo Firebase project)
3. **Flutter SDK** đã cài đặt

---

## 🔧 Các Bước Setup

### Bước 1: Cài đặt Firebase CLI

```powershell
# Cho phép chạy scripts
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# Cài Firebase CLI
npm install -g firebase-tools

# Đăng nhập Firebase
firebase login
```

### Bước 2: Cài đặt FlutterFire CLI

```powershell
# Cài FlutterFire CLI
dart pub global activate flutterfire_cli

# Thêm vào PATH (chỉ cho session hiện tại)
$env:Path += ";C:\Users\admin\AppData\Local\Pub\Cache\bin"

# Hoặc thêm vĩnh viễn vào System Environment Variables:
# C:\Users\admin\AppData\Local\Pub\Cache\bin
```

### Bước 3: Cấu hình Firebase cho Flutter Project

```powershell
# Di chuyển vào thư mục project
cd music_app

# Cấu hình Firebase (chọn project hoặc tạo mới)
flutterfire configure

# Chọn platforms: Android, iOS, Web (nhấn Space để chọn)
# File firebase_options.dart sẽ được tạo tự động
```

### Bước 4: Uncomment Firebase Initialization trong main.dart

Mở file `lib/main.dart` và uncomment các dòng sau:

```dart
import 'firebase_options.dart';

// Trong hàm main():
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Bước 5: Cài đặt Dependencies

```powershell
flutter pub get
```

---

## 🗂️ Cấu Trúc Firebase

### Firebase Console Setup

1. **Truy cập:** [Firebase Console](https://console.firebase.google.com/)
2. **Chọn project:** `music-app-70368` hoặc project bạn vừa tạo
3. **Cấu hình các services:**

#### 🔐 Authentication
- Vào **Authentication** > **Sign-in method**
- Enable: **Email/Password**, **Google**, **Facebook** (tùy chọn)

#### 🗄️ Firestore Database
- Vào **Firestore Database** > **Create database**
- Chọn mode: **Start in test mode** (cho development)
- Region: **asia-southeast1** (Singapore) hoặc gần nhất

#### 📁 Storage
- Vào **Storage** > **Get started**
- Chọn region: **asia-southeast1**

---

## 🔒 Firestore Security Rules

Copy & paste vào **Firestore Database** > **Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      // User's sub-collections
      match /{subCollection}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Public read for songs, artists, albums
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
  }
}
```

---

## 📦 Storage Rules

Copy & paste vào **Storage** > **Rules**:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Public read for songs and covers
    match /songs/{songId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /covers/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User avatars
    match /avatars/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🔍 Tạo Firestore Indexes

Vào **Firestore Database** > **Indexes** > **Create Index**:

### 1. Search songs by name and playCount
- Collection: `songs`
- Fields:
  - `songName` (Ascending)
  - `playCount` (Descending)

### 2. Get listening history by date
- Collection Group: `listeningHistory`
- Fields:
  - `playedAt` (Descending)

### 3. Get songs by genre and popularity
- Collection: `songs`
- Fields:
  - `genre` (Ascending)
  - `playCount` (Descending)

### 4. Get artist's songs by date
- Collection: `songs`
- Fields:
  - `artistId` (Ascending)
  - `releaseDate` (Descending)

---

## 🧪 Test với Mock Data

### Thêm Sample Songs

```dart
// lib/scripts/seed_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedSongs() async {
  final db = FirebaseFirestore.instance;
  
  final songs = [
    {
      'songName': 'Blinding Lights',
      'artistId': 'artist1',
      'artistName': 'The Weeknd',
      'albumId': 'album1',
      'albumName': 'After Hours',
      'durationMs': 200040,
      'fileUrl': 'https://example.com/song1.mp3',
      'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273...',
      'genre': 'Pop',
      'releaseDate': Timestamp.fromDate(DateTime(2020, 11, 29)),
      'playCount': 3500000,
      'isExplicit': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    // Thêm các bài hát khác...
  ];

  for (var song in songs) {
    await db.collection('songs').add(song);
  }
  
  print('✅ Seeded ${songs.length} songs');
}
```

### Chạy Script

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Uncomment để seed data (chỉ chạy 1 lần)
  // await seedSongs();
  
  runApp(const MyApp());
}
```

---

## 💻 Sử Dụng FirestoreService

### Example: Get Songs & Display

```dart
import 'package:flutter/material.dart';
import 'services/firestore_service.dart';

class SongsListPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Songs')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final songs = snapshot.data ?? [];

          if (songs.isEmpty) {
            return Center(child: Text('No songs available'));
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: Image.network(
                  song['coverUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.music_note),
                ),
                title: Text(song['songName']),
                subtitle: Text(song['artistName']),
                trailing: Text('${song['playCount']} plays'),
                onTap: () {
                  // Play song
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

### Example: Add to Favorites

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firestore_service.dart';

Future<void> toggleFavorite(Map<String, dynamic> song) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final firestoreService = FirestoreService();
  final isFav = await firestoreService.isFavorite(userId, song['id']);

  if (isFav) {
    await firestoreService.removeFromFavorites(userId, song['id']);
  } else {
    await firestoreService.addToFavorites(userId, song);
  }
}
```

---

## 🐛 Troubleshooting

### 1. Lỗi: "flutterfire command not found"

**Giải pháp:**
```powershell
# Thêm vào PATH
$env:Path += ";C:\Users\admin\AppData\Local\Pub\Cache\bin"

# Hoặc thêm vĩnh viễn:
# System Properties > Environment Variables > Path > Edit
# Thêm: C:\Users\admin\AppData\Local\Pub\Cache\bin
```

### 2. Lỗi: "PERMISSION_DENIED"

**Giải pháp:** Kiểm tra Firestore Security Rules, đảm bảo user đã đăng nhập.

### 3. Lỗi: "Index required"

**Giải pháp:** Firestore sẽ đưa ra link để tạo index tự động. Click vào link và chờ index được tạo.

### 4. Lỗi: "No Firebase App"

**Giải pháp:** Đảm bảo đã uncomment và gọi `Firebase.initializeApp()` trong `main()`.

---

## 📚 Tài Liệu Tham Khảo

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [Firebase Storage](https://firebase.google.com/docs/storage)

---

## 🎯 Next Steps

1. ✅ Setup Firebase Authentication
2. ✅ Tạo cấu trúc Firestore Collections
3. ✅ Upload mock data
4. ⬜ Tích hợp audio player
5. ⬜ Implement offline caching
6. ⬜ Deploy lên Firebase Hosting

---

**Version:** 1.0  
**Last Updated:** December 18, 2025  
**Maintainer:** SoulSync Development Team
