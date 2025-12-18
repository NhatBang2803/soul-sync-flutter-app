import 'package:cloud_firestore/cloud_firestore.dart';

/// Script để seed mock data vào Firestore
/// Chạy một lần để tạo dữ liệu mẫu
class FirestoreSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seed tất cả mock data
  Future<void> seedAll() async {
    print('🌱 Starting to seed mock data...\n');
    
    await seedArtists();
    await seedAlbums();
    await seedSongs();
    
    print('\n✅ All mock data seeded successfully!');
  }

  /// Seed Artists
  Future<void> seedArtists() async {
    print('👨‍🎤 Seeding artists...');
    
    final artists = [
      {
        'artistId': 'artist_1',
        'artistName': 'The Weeknd',
        'bio': 'Canadian singer, songwriter, and record producer',
        'avatarUrl': 'https://i.scdn.co/image/ab6761610000e5eb214f3cf1cbe7139c1e26ffbb',
        'bannerUrl': 'https://i.scdn.co/image/ab6761670000ecd4989ed05e1f0570cc4726c2d3',
        'verified': true,
        'monthlyListeners': 115000000,
        'genres': ['Pop', 'R&B'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'artistId': 'artist_2',
        'artistName': 'Billie Eilish',
        'bio': 'American singer and songwriter',
        'avatarUrl': 'https://i.scdn.co/image/ab6761610000e5eb4a8d3994e5ebfc28eab6e241',
        'bannerUrl': 'https://i.scdn.co/image/ab6761670000ecd469ca98dd3083f1082d740e44',
        'verified': true,
        'monthlyListeners': 98000000,
        'genres': ['Pop', 'Alternative'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'artistId': 'artist_3',
        'artistName': 'Ed Sheeran',
        'bio': 'English singer-songwriter',
        'avatarUrl': 'https://i.scdn.co/image/ab6761610000e5ebc06971e9ff3685e96735f633',
        'bannerUrl': 'https://i.scdn.co/image/ab6761670000ecd4d38394a6e11a1e795ea9f02f',
        'verified': true,
        'monthlyListeners': 92000000,
        'genres': ['Pop', 'Folk'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'artistId': 'artist_4',
        'artistName': 'Taylor Swift',
        'bio': 'American singer-songwriter',
        'avatarUrl': 'https://i.scdn.co/image/ab6761610000e5ebe672b5f553298dcdccb0e676',
        'bannerUrl': 'https://i.scdn.co/image/ab6761670000ecd413b2bfe7e59db2e5cf0a6bb2',
        'verified': true,
        'monthlyListeners': 110000000,
        'genres': ['Pop', 'Country'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'artistId': 'artist_5',
        'artistName': 'Drake',
        'bio': 'Canadian rapper and singer',
        'avatarUrl': 'https://i.scdn.co/image/ab6761610000e5eb4293385d324db8558179afd9',
        'bannerUrl': 'https://i.scdn.co/image/ab6761670000ecd440b5c07ab77585fbef8a8d91',
        'verified': true,
        'monthlyListeners': 89000000,
        'genres': ['Hip-Hop', 'Rap'],
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var artist in artists) {
      await _db.collection('artists').doc(artist['artistId'] as String).set(artist);
      print('  ✓ Added: ${artist['artistName']}');
    }
    
    print('  → ${artists.length} artists seeded\n');
  }

  /// Seed Albums
  Future<void> seedAlbums() async {
    print('💿 Seeding albums...');
    
    final albums = [
      {
        'albumId': 'album_1',
        'albumName': 'After Hours',
        'artistId': 'artist_1',
        'artistName': 'The Weeknd',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36',
        'releaseDate': Timestamp.fromDate(DateTime(2020, 3, 20)),
        'albumType': 'album',
        'totalTracks': 14,
        'genres': ['Pop', 'R&B'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'albumId': 'album_2',
        'albumName': 'Happier Than Ever',
        'artistId': 'artist_2',
        'artistName': 'Billie Eilish',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b2732a038d3bf875d23e4aeaa84e',
        'releaseDate': Timestamp.fromDate(DateTime(2021, 7, 30)),
        'albumType': 'album',
        'totalTracks': 16,
        'genres': ['Pop', 'Alternative'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'albumId': 'album_3',
        'albumName': 'Divide',
        'artistId': 'artist_3',
        'artistName': 'Ed Sheeran',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96',
        'releaseDate': Timestamp.fromDate(DateTime(2017, 3, 3)),
        'albumType': 'album',
        'totalTracks': 16,
        'genres': ['Pop', 'Folk'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'albumId': 'album_4',
        'albumName': 'Midnights',
        'artistId': 'artist_4',
        'artistName': 'Taylor Swift',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'releaseDate': Timestamp.fromDate(DateTime(2022, 10, 21)),
        'albumType': 'album',
        'totalTracks': 13,
        'genres': ['Pop'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'albumId': 'album_5',
        'albumName': 'Certified Lover Boy',
        'artistId': 'artist_5',
        'artistName': 'Drake',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273cd945b4e3de57edd28481a3f',
        'releaseDate': Timestamp.fromDate(DateTime(2021, 9, 3)),
        'albumType': 'album',
        'totalTracks': 21,
        'genres': ['Hip-Hop', 'Rap'],
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var album in albums) {
      await _db.collection('albums').doc(album['albumId'] as String).set(album);
      print('  ✓ Added: ${album['albumName']}');
    }
    
    print('  → ${albums.length} albums seeded\n');
  }

  /// Seed Songs
  Future<void> seedSongs() async {
    print('🎵 Seeding songs...');
    
    final songs = [
      {
        'songId': 'song_1',
        'songName': 'Blinding Lights',
        'artistId': 'artist_1',
        'artistName': 'The Weeknd',
        'albumId': 'album_1',
        'albumName': 'After Hours',
        'durationMs': 200040,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36',
        'lyrics': 'I said, ooh, I\'m blinded by the lights...',
        'genre': 'Pop',
        'releaseDate': Timestamp.fromDate(DateTime(2020, 11, 29)),
        'playCount': 3500000,
        'isExplicit': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_2',
        'songName': 'Happier Than Ever',
        'artistId': 'artist_2',
        'artistName': 'Billie Eilish',
        'albumId': 'album_2',
        'albumName': 'Happier Than Ever',
        'durationMs': 298000,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b2732a038d3bf875d23e4aeaa84e',
        'lyrics': 'When I\'m away from you, I\'m happier than ever...',
        'genre': 'Pop',
        'releaseDate': Timestamp.fromDate(DateTime(2021, 7, 30)),
        'playCount': 2800000,
        'isExplicit': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_3',
        'songName': 'Shape of You',
        'artistId': 'artist_3',
        'artistName': 'Ed Sheeran',
        'albumId': 'album_3',
        'albumName': 'Divide',
        'durationMs': 233713,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96',
        'lyrics': 'The club isn\'t the best place to find a lover...',
        'genre': 'Pop',
        'releaseDate': Timestamp.fromDate(DateTime(2017, 1, 6)),
        'playCount': 4200000,
        'isExplicit': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_4',
        'songName': 'Anti-Hero',
        'artistId': 'artist_4',
        'artistName': 'Taylor Swift',
        'albumId': 'album_4',
        'albumName': 'Midnights',
        'durationMs': 200690,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'lyrics': 'It\'s me, hi, I\'m the problem, it\'s me...',
        'genre': 'Pop',
        'releaseDate': Timestamp.fromDate(DateTime(2022, 10, 21)),
        'playCount': 3900000,
        'isExplicit': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_5',
        'songName': 'Way 2 Sexy',
        'artistId': 'artist_5',
        'artistName': 'Drake',
        'albumId': 'album_5',
        'albumName': 'Certified Lover Boy',
        'durationMs': 258000,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273cd945b4e3de57edd28481a3f',
        'lyrics': 'Way too sexy for this girl, way too sexy...',
        'genre': 'Hip-Hop',
        'releaseDate': Timestamp.fromDate(DateTime(2021, 9, 3)),
        'playCount': 2500000,
        'isExplicit': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_6',
        'songName': 'Save Your Tears',
        'artistId': 'artist_1',
        'artistName': 'The Weeknd',
        'albumId': 'album_1',
        'albumName': 'After Hours',
        'durationMs': 215626,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36',
        'lyrics': 'I saw you dancing in a crowded room...',
        'genre': 'Pop',
        'releaseDate': Timestamp.fromDate(DateTime(2020, 11, 29)),
        'playCount': 3200000,
        'isExplicit': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_7',
        'songName': 'bad guy',
        'artistId': 'artist_2',
        'artistName': 'Billie Eilish',
        'albumId': 'album_2',
        'albumName': 'Happier Than Ever',
        'durationMs': 194088,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b2732a038d3bf875d23e4aeaa84e',
        'lyrics': 'So you\'re a tough guy, like it really rough guy...',
        'genre': 'Pop',
        'releaseDate': Timestamp.fromDate(DateTime(2019, 3, 29)),
        'playCount': 3800000,
        'isExplicit': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_8',
        'songName': 'Perfect',
        'artistId': 'artist_3',
        'artistName': 'Ed Sheeran',
        'albumId': 'album_3',
        'albumName': 'Divide',
        'durationMs': 263400,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96',
        'lyrics': 'I found a love for me, darling just dive right in...',
        'genre': 'Pop',
        'releaseDate': Timestamp.fromDate(DateTime(2017, 3, 3)),
        'playCount': 3600000,
        'isExplicit': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_9',
        'songName': 'Lavender Haze',
        'artistId': 'artist_4',
        'artistName': 'Taylor Swift',
        'albumId': 'album_4',
        'albumName': 'Midnights',
        'durationMs': 202000,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'lyrics': 'Meet me at midnight...',
        'genre': 'Pop',
        'releaseDate': Timestamp.fromDate(DateTime(2022, 10, 21)),
        'playCount': 2900000,
        'isExplicit': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_10',
        'songName': 'One Dance',
        'artistId': 'artist_5',
        'artistName': 'Drake',
        'albumId': 'album_5',
        'albumName': 'Certified Lover Boy',
        'durationMs': 173987,
        'fileUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        'coverUrl': 'https://i.scdn.co/image/ab67616d0000b273cd945b4e3de57edd28481a3f',
        'lyrics': 'Baby, I like your style...',
        'genre': 'Hip-Hop',
        'releaseDate': Timestamp.fromDate(DateTime(2016, 4, 5)),
        'playCount': 4000000,
        'isExplicit': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var song in songs) {
      await _db.collection('songs').doc(song['songId'] as String).set(song);
      print('  ✓ Added: ${song['songName']} - ${song['artistName']}');
    }
    
    print('  → ${songs.length} songs seeded\n');
  }

  /// Clear all collections (use with caution!)
  Future<void> clearAll() async {
    print('🗑️  Clearing all data...');
    
    await _clearCollection('songs');
    await _clearCollection('artists');
    await _clearCollection('albums');
    
    print('✅ All data cleared!');
  }

  Future<void> _clearCollection(String collectionName) async {
    final snapshot = await _db.collection(collectionName).get();
    final batch = _db.batch();
    
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('  ✓ Cleared $collectionName (${snapshot.docs.length} documents)');
  }
}
