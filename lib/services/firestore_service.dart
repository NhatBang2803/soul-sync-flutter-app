import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ SONGS ============
  
  /// Get all songs (top 50 by play count)
  Stream<List<Map<String, dynamic>>> getSongs() {
    return _db
        .collection('songs')
        .orderBy('playCount', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Get song by ID
  Future<Map<String, dynamic>?> getSongById(String songId) async {
    final doc = await _db.collection('songs').doc(songId).get();
    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    }
    return null;
  }

  /// Search songs (Note: Limited functionality, consider using Algolia)
  Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    final snapshot = await _db
        .collection('songs')
        .where('songName', isGreaterThanOrEqualTo: query)
        .where('songName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
  }

  /// Get songs by artist
  Stream<List<Map<String, dynamic>>> getSongsByArtist(String artistId) {
    return _db
        .collection('songs')
        .where('artistId', isEqualTo: artistId)
        .orderBy('releaseDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Get songs by album
  Stream<List<Map<String, dynamic>>> getSongsByAlbum(String albumId) {
    return _db
        .collection('songs')
        .where('albumId', isEqualTo: albumId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // ============ FAVORITES ============

  /// Add song to favorites
  Future<void> addToFavorites(String userId, Map<String, dynamic> song) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(song['id'])
        .set({
      'songId': song['id'],
      'songName': song['songName'],
      'artistName': song['artistName'],
      'coverUrl': song['coverUrl'],
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(String userId, String songId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(songId)
        .delete();
  }

  /// Check if song is in favorites
  Future<bool> isFavorite(String userId, String songId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(songId)
        .get();
    return doc.exists;
  }

  /// Get user's favorites
  Stream<List<Map<String, dynamic>>> getUserFavorites(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // ============ LISTENING HISTORY ============

  /// Add to listening history
  Future<void> addToListeningHistory(
      String userId, Map<String, dynamic> song) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('listeningHistory')
        .add({
      'songId': song['id'],
      'songName': song['songName'],
      'artistName': song['artistName'],
      'coverUrl': song['coverUrl'],
      'playedAt': FieldValue.serverTimestamp(),
      'durationPlayedMs': song['durationMs'],
      'completed': true,
    });

    // Increase play count
    await _db.collection('songs').doc(song['id']).update({
      'playCount': FieldValue.increment(1),
    });
  }

  /// Get listening history
  Stream<List<Map<String, dynamic>>> getListeningHistory(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('listeningHistory')
        .orderBy('playedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // ============ PLAYLISTS ============

  /// Create playlist
  Future<String> createPlaylist(
      String userId, String name, String description) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .add({
      'playlistName': name,
      'description': description,
      'coverUrl': '',
      'isPublic': true,
      'songs': [],
      'totalSongs': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Update playlist
  Future<void> updatePlaylist(String userId, String playlistId,
      {String? name, String? description, bool? isPublic}) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['playlistName'] = name;
    if (description != null) updates['description'] = description;
    if (isPublic != null) updates['isPublic'] = isPublic;

    await _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .doc(playlistId)
        .update(updates);
  }

  /// Delete playlist
  Future<void> deletePlaylist(String userId, String playlistId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .doc(playlistId)
        .delete();
  }

  /// Add song to playlist
  Future<void> addSongToPlaylist(
      String userId, String playlistId, Map<String, dynamic> song) async {
    final playlistRef = _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .doc(playlistId);

    await playlistRef.update({
      'songs': FieldValue.arrayUnion([
        {
          'songId': song['id'],
          'songName': song['songName'],
          'artistName': song['artistName'],
          'coverUrl': song['coverUrl'],
          'addedAt': FieldValue.serverTimestamp(),
        }
      ]),
      'totalSongs': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove song from playlist
  Future<void> removeSongFromPlaylist(
      String userId, String playlistId, String songId) async {
    final playlistRef = _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .doc(playlistId);

    final playlist = await playlistRef.get();
    if (playlist.exists) {
      final songs = List<Map<String, dynamic>>.from(playlist.data()!['songs']);
      songs.removeWhere((song) => song['songId'] == songId);

      await playlistRef.update({
        'songs': songs,
        'totalSongs': songs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get user's playlists
  Stream<List<Map<String, dynamic>>> getUserPlaylists(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Get playlist by ID
  Future<Map<String, dynamic>?> getPlaylistById(
      String userId, String playlistId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .doc(playlistId)
        .get();

    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    }
    return null;
  }

  // ============ ARTISTS ============

  /// Get all artists
  Stream<List<Map<String, dynamic>>> getArtists() {
    return _db
        .collection('artists')
        .orderBy('monthlyListeners', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Get artist by ID
  Future<Map<String, dynamic>?> getArtistById(String artistId) async {
    final doc = await _db.collection('artists').doc(artistId).get();
    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    }
    return null;
  }

  /// Follow artist
  Future<void> followArtist(
      String userId, Map<String, dynamic> artist) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('followedArtists')
        .doc(artist['id'])
        .set({
      'artistId': artist['id'],
      'artistName': artist['artistName'],
      'avatarUrl': artist['avatarUrl'],
      'followedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Unfollow artist
  Future<void> unfollowArtist(String userId, String artistId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('followedArtists')
        .doc(artistId)
        .delete();
  }

  /// Get followed artists
  Stream<List<Map<String, dynamic>>> getFollowedArtists(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('followedArtists')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // ============ ALBUMS ============

  /// Get all albums
  Stream<List<Map<String, dynamic>>> getAlbums() {
    return _db
        .collection('albums')
        .orderBy('releaseDate', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Get album by ID
  Future<Map<String, dynamic>?> getAlbumById(String albumId) async {
    final doc = await _db.collection('albums').doc(albumId).get();
    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    }
    return null;
  }

  /// Get albums by artist
  Stream<List<Map<String, dynamic>>> getAlbumsByArtist(String artistId) {
    return _db
        .collection('albums')
        .where('artistId', isEqualTo: artistId)
        .orderBy('releaseDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // ============ SEARCH HISTORY ============

  /// Add to search history
  Future<void> addToSearchHistory(String userId, String query) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .add({
      'searchQuery': query,
      'searchedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get search history
  Stream<List<Map<String, dynamic>>> getSearchHistory(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .orderBy('searchedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Clear search history
  Future<void> clearSearchHistory(String userId) async {
    final batch = _db.batch();
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ============ USER PROFILE ============

  /// Create or update user profile
  Future<void> updateUserProfile(String userId,
      {String? username,
      String? displayName,
      String? avatarUrl,
      String? country,
      DateTime? dateOfBirth}) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (username != null) updates['username'] = username;
    if (displayName != null) updates['displayName'] = displayName;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    if (country != null) updates['country'] = country;
    if (dateOfBirth != null) updates['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);

    await _db.collection('users').doc(userId).set(
          updates,
          SetOptions(merge: true),
        );
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    }
    return null;
  }

  /// Get user profile stream
  Stream<Map<String, dynamic>?> getUserProfileStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    });
  }
}
