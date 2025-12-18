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
        .from('songs_with_details')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy bài hát theo ID
  Future<Map<String, dynamic>?> getSongById(String id) async {
    final response = await client
        .from('songs_with_details')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  /// Lấy bài hát theo artist
  Future<List<Map<String, dynamic>>> getSongsByArtist(String artistId) async {
    final response = await client
        .from('songs_with_details')
        .select()
        .eq('artist_id', artistId)
        .order('title');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy bài hát theo album
  Future<List<Map<String, dynamic>>> getSongsByAlbum(String albumId) async {
    final response = await client
        .from('songs_with_details')
        .select()
        .eq('album_id', albumId)
        .order('title');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Tìm kiếm bài hát
  Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    final response = await client
        .from('songs_with_details')
        .select()
        .or('title.ilike.%$query%,artist_name.ilike.%$query%')
        .limit(20);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Tăng lượt nghe
  Future<void> incrementPlayCount(String songId) async {
    await client.rpc('increment_play_count', params: {'song_id': songId});
  }

  // ==================== ARTISTS ====================
  
  /// Lấy tất cả nghệ sĩ
  Future<List<Map<String, dynamic>>> getArtists() async {
    final response = await client
        .from('artists')
        .select()
        .order('name');
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

  // ==================== ALBUMS ====================
  
  /// Lấy tất cả album
  Future<List<Map<String, dynamic>>> getAlbums() async {
    final response = await client
        .from('albums')
        .select('*, artists(name)')
        .order('release_year', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy album theo ID
  Future<Map<String, dynamic>?> getAlbumById(String id) async {
    final response = await client
        .from('albums')
        .select('*, artists(name)')
        .eq('id', id)
        .single();
    return response;
  }

  /// Lấy album theo artist
  Future<List<Map<String, dynamic>>> getAlbumsByArtist(String artistId) async {
    final response = await client
        .from('albums')
        .select('*, artists(name)')
        .eq('artist_id', artistId)
        .order('release_year', ascending: false);
    return List<Map<String, dynamic>>.from(response);
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

  /// Lấy playlist theo ID kèm danh sách bài hát
  Future<Map<String, dynamic>?> getPlaylistWithSongs(String playlistId) async {
    final playlist = await client
        .from('playlists')
        .select()
        .eq('id', playlistId)
        .single();
    
    final songs = await client
        .from('playlist_songs')
        .select('position, songs_with_details(*)')
        .eq('playlist_id', playlistId)
        .order('position');
    
    return {
      ...playlist,
      'songs': songs.map((s) => s['songs_with_details']).toList(),
    };
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
        .select('song_id, songs_with_details(*)')
        .eq('user_id', userId)
        .order('liked_at', ascending: false);
    return response.map<Map<String, dynamic>>((r) => r['songs_with_details'] as Map<String, dynamic>).toList();
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
