import 'package:supabase_flutter/supabase_flutter.dart';

/// Service để tương tác với Supabase database
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // ==================== SONGS ====================

  /// Lấy tất cả bài hát với thông tin artist và album
  Future<List<Map<String, dynamic>>> getSongs() async {
    final response = await client
        .from('songs_with_artists')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy bài hát theo ID
  Future<Map<String, dynamic>?> getSongById(String id) async {
    final response = await client
        .from('songs_with_artists')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  /// Lấy bài hát theo artist
  Future<List<Map<String, dynamic>>> getSongsByArtist(String artistId) async {
    final response = await client
        .from('song_artists')
        .select('songs_with_artists(*)')
        .eq('artist_id', artistId)
        .order('position');
    return List<Map<String, dynamic>>.from(
      response.map((r) => r['songs_with_artists']),
    );
  }

  /// Lấy bài hát theo album
  Future<List<Map<String, dynamic>>> getSongsByAlbum(String albumId) async {
    final response = await client
        .from('album_songs')
        .select('track_number, songs_with_artists(*)')
        .eq('album_id', albumId)
        .order('track_number');
    return List<Map<String, dynamic>>.from(
      response.map((r) => r['songs_with_artists']),
    );
  }

  /// Lấy bài hát ngẫu nhiên
  Future<List<Map<String, dynamic>>> getRandomSongs(int limit) async {
    final response = await client.rpc(
      'get_random_songs',
      params: {'limit_count': limit},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  /// Tìm kiếm bài hát
  Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    final response = await client
        .from('songs_with_artists')
        .select()
        .or('title.ilike.%$query%,artist_name.ilike.%$query%')
        .limit(20);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Tăng lượt nghe
  Future<void> incrementPlayCount(String songId) async {
    await client.rpc('increment_play_count', params: {'song_id': songId});
  }

  /// Ghi lịch sử nghe
  Future<void> recordListening({
    String? userId,
    required String songId,
    int durationPlayed = 0,
    bool completed = false,
  }) async {
    await client.rpc(
      'record_listening',
      params: {
        'p_user_id': userId,
        'p_song_id': songId,
        'p_duration': durationPlayed,
        'p_completed': completed,
      },
    );
  }

  // ==================== RANKINGS ====================

  /// Lấy bảng xếp hạng bài hát theo tuần theo thể loại
  Future<List<Map<String, dynamic>>> getWeeklySongRankingByGenre(
    String genreName,
  ) async {
    final response = await client
        .from('weekly_song_rankings')
        .select()
        .eq('genre_name', genreName)
        .order('rank')
        .limit(10);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy tất cả thể loại có bảng xếp hạng
  Future<List<Map<String, dynamic>>> getGenres() async {
    final response = await client.from('genres').select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy bảng xếp hạng nghệ sĩ theo tuần
  Future<List<Map<String, dynamic>>> getWeeklyArtistRanking() async {
    final response = await client
        .from('weekly_artist_rankings')
        .select()
        .order('rank')
        .limit(10);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy bài hát mới phát hành (7 ngày gần đây)
  Future<List<Map<String, dynamic>>> getNewReleases() async {
    final response = await client
        .from('new_releases')
        .select()
        .order('created_at', ascending: false)
        .limit(20);
    return List<Map<String, dynamic>>.from(response);
  }

  // ==================== ARTISTS ====================

  /// Lấy tất cả nghệ sĩ
  Future<List<Map<String, dynamic>>> getArtists() async {
    final response = await client.from('artists').select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy nghệ sĩ theo ID
  Future<Map<String, dynamic>?> getArtistById(String id) async {
    final response = await client
        .from('artists')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  /// Lấy top bài hát của nghệ sĩ
  Future<List<Map<String, dynamic>>> getArtistTopSongs(
    String artistId, {
    int limit = 5,
  }) async {
    final response = await client
        .from('song_artists')
        .select('songs_with_artists(*)')
        .eq('artist_id', artistId)
        .order(
          'play_count',
          ascending: false,
          referencedTable: 'songs_with_artists',
        )
        .limit(limit);
    return List<Map<String, dynamic>>.from(
      response.map((r) => r['songs_with_artists']),
    );
  }

  /// Lấy các bài featuring của nghệ sĩ
  Future<List<Map<String, dynamic>>> getArtistFeaturing(String artistId) async {
    final response = await client
        .from('song_artists')
        .select('songs_with_artists(*)')
        .eq('artist_id', artistId)
        .eq('role', 'featuring')
        .limit(20);
    return List<Map<String, dynamic>>.from(
      response.map((r) => r['songs_with_artists']),
    );
  }

  /// Theo dõi nghệ sĩ
  Future<void> followArtist(String userId, String artistId) async {
    await client.from('user_follows').upsert({
      'user_id': userId,
      'artist_id': artistId,
    });
    // Update followers count
    await client.rpc(
      'increment_artist_followers',
      params: {'p_artist_id': artistId},
    );
  }

  /// Bỏ theo dõi nghệ sĩ
  Future<void> unfollowArtist(String userId, String artistId) async {
    await client
        .from('user_follows')
        .delete()
        .eq('user_id', userId)
        .eq('artist_id', artistId);
  }

  /// Kiểm tra đã theo dõi nghệ sĩ chưa
  Future<bool> isFollowingArtist(String userId, String artistId) async {
    final response = await client
        .from('user_follows')
        .select()
        .eq('user_id', userId)
        .eq('artist_id', artistId)
        .maybeSingle();
    return response != null;
  }

  /// Lấy danh sách nghệ sĩ đang theo dõi
  Future<List<Map<String, dynamic>>> getFollowingArtists(String userId) async {
    final response = await client
        .from('user_follows')
        .select('artists(*)')
        .eq('user_id', userId)
        .order('followed_at', ascending: false);
    return List<Map<String, dynamic>>.from(response.map((r) => r['artists']));
  }

  // ==================== ALBUMS ====================

  /// Lấy tất cả album
  Future<List<Map<String, dynamic>>> getAlbums() async {
    final response = await client
        .from('albums_with_artists')
        .select()
        .order('release_year', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy album theo ID
  Future<Map<String, dynamic>?> getAlbumById(String id) async {
    final response = await client
        .from('albums_with_artists')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  /// Lấy album theo artist (qua junction table)
  Future<List<Map<String, dynamic>>> getAlbumsByArtist(String artistId) async {
    final response = await client
        .from('album_artists')
        .select('albums_with_artists(*)')
        .eq('artist_id', artistId);
    return List<Map<String, dynamic>>.from(
      response.map((r) => r['albums_with_artists']),
    );
  }

  /// Lấy album ngẫu nhiên (để gợi ý)
  Future<List<Map<String, dynamic>>> getRandomAlbums(int limit) async {
    final response = await client
        .from('albums_with_artists')
        .select()
        .eq('is_public', true)
        .limit(limit * 2); // Get more to shuffle
    // Shuffle in memory since Supabase doesn't have RANDOM()
    final list = List<Map<String, dynamic>>.from(response);
    list.shuffle();
    return list.take(limit).toList();
  }

  // ==================== PLAYLISTS ====================

  /// Lấy tất cả playlist public
  Future<List<Map<String, dynamic>>> getPublicPlaylists() async {
    final response = await client
        .from('playlists')
        .select()
        .eq('is_public', true)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy playlist của user
  Future<List<Map<String, dynamic>>> getUserPlaylists(String userId) async {
    final response = await client
        .from('playlists')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy playlist theo ID kèm danh sách bài hát
  Future<Map<String, dynamic>?> getPlaylistWithSongs(String playlistId) async {
    final playlist = await client
        .from('playlists')
        .select()
        .eq('id', playlistId)
        .single();

    final songs = await client
        .from('playlist_songs')
        .select('position, songs_with_artists(*)')
        .eq('playlist_id', playlistId)
        .order('position');

    return {
      ...playlist,
      'songs': songs.map((s) => s['songs_with_artists']).toList(),
    };
  }

  /// Tạo playlist mới
  Future<Map<String, dynamic>> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    required String ownerId,
    bool isPublic = true,
  }) async {
    final response = await client
        .from('playlists')
        .insert({
          'name': name,
          'description': description,
          'cover_url': coverUrl,
          'owner_id': ownerId,
          'is_public': isPublic,
        })
        .select()
        .single();
    return response;
  }

  /// Cập nhật playlist
  Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    String? coverUrl,
    bool? isPublic,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (coverUrl != null) updates['cover_url'] = coverUrl;
    if (isPublic != null) updates['is_public'] = isPublic;

    await client.from('playlists').update(updates).eq('id', playlistId);
  }

  /// Xóa playlist
  Future<void> deletePlaylist(String playlistId) async {
    await client.from('playlists').delete().eq('id', playlistId);
  }

  /// Thêm bài hát vào playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    // Lấy position cao nhất hiện tại
    final maxPos = await client
        .from('playlist_songs')
        .select('position')
        .eq('playlist_id', playlistId)
        .order('position', ascending: false)
        .limit(1);

    final newPosition = maxPos.isEmpty ? 0 : (maxPos[0]['position'] as int) + 1;

    await client.from('playlist_songs').insert({
      'playlist_id': playlistId,
      'song_id': songId,
      'position': newPosition,
    });

    // Update song count directly - đếm số bài hát trong playlist
    final countResult = await client
        .from('playlist_songs')
        .select('id')
        .eq('playlist_id', playlistId);

    final songCount = countResult.length;

    await client
        .from('playlists')
        .update({'song_count': songCount})
        .eq('id', playlistId);
  }

  /// Xóa bài hát khỏi playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await client
        .from('playlist_songs')
        .delete()
        .eq('playlist_id', playlistId)
        .eq('song_id', songId);
  }

  // ==================== USER LIKES ====================

  /// Kiểm tra bài hát có được like không
  Future<bool> isSongLiked(String userId, String songId) async {
    final response = await client
        .from('user_liked_songs')
        .select()
        .eq('user_id', userId)
        .eq('song_id', songId)
        .maybeSingle();
    return response != null;
  }

  /// Like bài hát
  Future<void> likeSong(String userId, String songId) async {
    await client.from('user_liked_songs').insert({
      'user_id': userId,
      'song_id': songId,
    });
  }

  /// Unlike bài hát
  Future<void> unlikeSong(String userId, String songId) async {
    await client
        .from('user_liked_songs')
        .delete()
        .eq('user_id', userId)
        .eq('song_id', songId);
  }

  /// Lấy danh sách bài hát đã like
  Future<List<Map<String, dynamic>>> getLikedSongs(String userId) async {
    final response = await client
        .from('user_liked_songs')
        .select('song_id, songs_with_artists(*)')
        .eq('user_id', userId)
        .order('liked_at', ascending: false);
    return response
        .map<Map<String, dynamic>>(
          (r) => r['songs_with_artists'] as Map<String, dynamic>,
        )
        .toList();
  }

  // ==================== LISTENING HISTORY ====================

  /// Lấy lịch sử nghe gần đây
  Future<List<Map<String, dynamic>>> getRecentlyPlayed(
    String userId, {
    int limit = 20,
  }) async {
    final response = await client
        .from('user_recently_played')
        .select()
        .eq('user_id', userId)
        .order('listened_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy album nghe gần đây
  Future<List<Map<String, dynamic>>> getRecentlyPlayedAlbums(
    String userId, {
    int limit = 10,
  }) async {
    final response = await client
        .from('listening_history')
        .select('songs(album_songs(albums(*)))')
        .eq('user_id', userId)
        .order('listened_at', ascending: false)
        .limit(50);

    // Extract unique albums
    final albumIds = <String>{};
    final albums = <Map<String, dynamic>>[];

    for (final record in response) {
      final song = record['songs'];
      if (song != null && song['album_songs'] != null) {
        for (final albumSong in song['album_songs']) {
          final album = albumSong['albums'];
          if (album != null && !albumIds.contains(album['id'])) {
            albumIds.add(album['id']);
            albums.add(album);
            if (albums.length >= limit) break;
          }
        }
      }
      if (albums.length >= limit) break;
    }

    return albums;
  }

  // ==================== SEARCH ====================

  /// Tìm kiếm tất cả (songs, artists, albums, playlists)
  /// Tìm kiếm theo title, artist name, album name, và cả genre name
  Future<Map<String, List<Map<String, dynamic>>>> searchAll(
    String query,
  ) async {
    if (query.isEmpty) {
      return {'songs': [], 'artists': [], 'albums': [], 'playlists': []};
    }

    try {
      final results = await Future.wait([
        // Search songs by title or artist name
        client
            .from('songs_with_artists')
            .select()
            .or('title.ilike.%$query%,artist_name.ilike.%$query%')
            .limit(20),
        // Search artists by name
        client.from('artists').select().ilike('name', '%$query%').limit(20),
        // Search albums by name (using view)
        client
            .from('albums_with_artists')
            .select()
            .or('name.ilike.%$query%,artist_name.ilike.%$query%')
            .limit(20),
        // Search playlists by name
        client
            .from('playlists')
            .select()
            .eq('is_public', true)
            .ilike('name', '%$query%')
            .limit(20),
      ]);

      // Also search songs by genre
      List<Map<String, dynamic>> songsByGenre = [];
      try {
        final genreResponse = await client
            .from('song_genres')
            .select('song_id, genres!inner(name, display_name)')
            .or('genres.name.ilike.%$query%,genres.display_name.ilike.%$query%')
            .limit(20);

        // Get the song IDs that match genre
        final songIds = genreResponse.map((r) => r['song_id']).toSet().toList();
        if (songIds.isNotEmpty) {
          songsByGenre = await client
              .from('songs_with_artists')
              .select()
              .inFilter('id', songIds)
              .limit(20);
        }
      } catch (e) {
        // Genre search failed, continue without it
      }

      // Combine and deduplicate songs
      final allSongs = <String, Map<String, dynamic>>{};
      for (final song in results[0]) {
        allSongs[song['id']] = song;
      }
      for (final song in songsByGenre) {
        allSongs[song['id']] = song;
      }

      return {
        'songs': allSongs.values.toList(),
        'artists': List<Map<String, dynamic>>.from(results[1]),
        'albums': List<Map<String, dynamic>>.from(results[2]),
        'playlists': List<Map<String, dynamic>>.from(results[3]),
      };
    } catch (e) {
      print('Search error: $e');
      return {'songs': [], 'artists': [], 'albums': [], 'playlists': []};
    }
  }

  // ==================== REALTIME STREAMS ====================

  /// Stream bài hát mới
  Stream<List<Map<String, dynamic>>> songsStream() {
    return client
        .from('songs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  /// Stream playlist
  Stream<List<Map<String, dynamic>>> playlistsStream() {
    return client
        .from('playlists')
        .stream(primaryKey: ['id'])
        .eq('is_public', true);
  }
}
