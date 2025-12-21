// Integration test để kiểm tra chức năng like song và like album
// Chạy: dart test test/like_functionality_test.dart

import 'dart:io';
import 'package:test/test.dart';
import 'package:supabase/supabase.dart';

// Đọc .env file manually
Map<String, String> loadEnvFile() {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    throw Exception('File .env không tồn tại!');
  }
  final content = envFile.readAsStringSync();
  final Map<String, String> env = {};
  for (final line in content.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx > 0) {
      final key = trimmed.substring(0, idx).trim();
      final value = trimmed.substring(idx + 1).trim();
      env[key] = value;
    }
  }
  return env;
}

void main() {
  late SupabaseClient supabase;
  late String userId;
  String? testSongId;
  String? testAlbumId;

  setUpAll(() async {
    // Load environment variables
    final env = loadEnvFile();

    final supabaseUrl = env['SUPABASE_URL'] ?? '';
    final supabaseKey = env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      fail('Không tìm thấy SUPABASE_URL hoặc SUPABASE_ANON_KEY trong .env');
    }

    // Initialize Supabase client
    supabase = SupabaseClient(supabaseUrl, supabaseKey);
  });

  group('Kiểm tra đăng nhập và lấy dữ liệu test', () {
    test('Đăng nhập với tài khoản naba123', () async {
      print('\n🔐 Đăng nhập với tài khoản naba123...');

      // Tìm user theo username
      final userRecord = await supabase
          .from('users')
          .select('*')
          .eq('username', 'naba123')
          .maybeSingle();

      if (userRecord == null) {
        print('⚠️ Username naba123 không tồn tại trong bảng users');
        // Thử tìm bất kỳ user nào
        final anyUser =
            await supabase.from('users').select('*').limit(1).single();
        userId = anyUser['id'];
        print('ℹ️ Sử dụng user test: ${anyUser['username']}');
      } else {
        userId = userRecord['id'];
        print('✅ Tìm thấy user: ${userRecord['username']}');
        print('📧 Email: ${userRecord['email']}');
        print('🆔 User ID: $userId');

        // Thử đăng nhập qua Supabase Auth
        final email = userRecord['email'] as String;
        try {
          final response = await supabase.auth.signInWithPassword(
            email: email,
            password: 'naba123',
          );

          if (response.user != null) {
            print('✅ Đăng nhập Supabase Auth thành công');
          }
        } catch (authError) {
          print('⚠️ Auth login error: $authError');
          print('ℹ️ Tiếp tục với user ID từ database...');
        }
      }

      expect(userId, isNotEmpty);
    });

    test('Lấy dữ liệu test (song và album)', () async {
      print('\n📊 Lấy dữ liệu test...');

      // Lấy một song bất kỳ
      try {
        final songs =
            await supabase.from('songs').select('id, title').limit(1);

        if (songs.isNotEmpty) {
          testSongId = songs[0]['id'];
          print('✅ Test Song: ${songs[0]['title']} ($testSongId)');
        } else {
          print('⚠️ Không có bài hát nào trong database');
        }
      } catch (e) {
        print('❌ Lỗi lấy song: $e');
      }

      // Lấy một album bất kỳ
      try {
        final albums =
            await supabase.from('albums').select('id, name').limit(1);

        if (albums.isNotEmpty) {
          testAlbumId = albums[0]['id'];
          print('✅ Test Album: ${albums[0]['name']} ($testAlbumId)');
        } else {
          print('⚠️ Không có album nào trong database');
        }
      } catch (e) {
        print('❌ Lỗi lấy album: $e');
      }

      // Ít nhất phải có song hoặc album để test
      expect(testSongId != null || testAlbumId != null, isTrue,
          reason: 'Cần ít nhất 1 song hoặc 1 album để test');
    });
  });

  group('Kiểm tra chức năng LIKE SONG', () {
    test('Kiểm tra và toggle like song', () async {
      if (testSongId == null) {
        print('⚠️ Không có song để test, bỏ qua...');
        return;
      }

      print('\n🎵 Kiểm tra chức năng LIKE SONG...');

      // Test 1: Kiểm tra trạng thái like ban đầu
      print('   📍 Test 1: Kiểm tra trạng thái like ban đầu...');
      final checkInitial = await supabase
          .from('user_liked_songs')
          .select('id')
          .eq('user_id', userId)
          .eq('song_id', testSongId!)
          .maybeSingle();

      final wasLiked = checkInitial != null;
      print('   → Trạng thái ban đầu: ${wasLiked ? "Đã like" : "Chưa like"}');

      // Test 2: Like bài hát (nếu chưa like)
      print('   📍 Test 2: Like bài hát...');
      if (!wasLiked) {
        await supabase.from('user_liked_songs').insert({
          'user_id': userId,
          'song_id': testSongId,
        });
        print('   ✅ Like thành công!');
      } else {
        print('   ℹ️ Bài hát đã được like trước đó');
      }

      // Test 3: Kiểm tra đã like
      print('   📍 Test 3: Xác nhận đã like...');
      final checkAfterLike = await supabase
          .from('user_liked_songs')
          .select('id, liked_at')
          .eq('user_id', userId)
          .eq('song_id', testSongId!)
          .maybeSingle();

      expect(checkAfterLike, isNotNull, reason: 'Bài hát phải được like');
      print('   ✅ Xác nhận: Bài hát đã được like');
      print('   → Liked at: ${checkAfterLike!['liked_at']}');

      // Test 4: Unlike bài hát
      print('   📍 Test 4: Unlike bài hát...');
      await supabase
          .from('user_liked_songs')
          .delete()
          .eq('user_id', userId)
          .eq('song_id', testSongId!);
      print('   ✅ Unlike thành công!');

      // Test 5: Kiểm tra đã unlike
      print('   📍 Test 5: Xác nhận đã unlike...');
      final checkAfterUnlike = await supabase
          .from('user_liked_songs')
          .select('id')
          .eq('user_id', userId)
          .eq('song_id', testSongId!)
          .maybeSingle();

      expect(checkAfterUnlike, isNull, reason: 'Bài hát phải được unlike');
      print('   ✅ Xác nhận: Bài hát đã được unlike');

      // Khôi phục trạng thái ban đầu
      if (wasLiked) {
        await supabase.from('user_liked_songs').insert({
          'user_id': userId,
          'song_id': testSongId,
        });
        print('   ℹ️ Đã khôi phục trạng thái like ban đầu');
      }

      print('   ✅ KIỂM TRA LIKE SONG: THÀNH CÔNG!');
    });

    test('Lấy danh sách bài hát đã like', () async {
      print('\n📋 Kiểm tra lấy danh sách bài hát đã like...');

      try {
        final response = await supabase
            .from('user_liked_songs')
            .select('song_id, liked_at, songs(id, title)')
            .eq('user_id', userId)
            .order('liked_at', ascending: false);

        print('   ✅ Tổng số bài hát đã like: ${response.length}');

        if (response.isNotEmpty) {
          print('   📋 Danh sách (tối đa 5):');
          for (var i = 0; i < response.length && i < 5; i++) {
            final item = response[i];
            final song = item['songs'];
            print(
                '      ${i + 1}. ${song?['title'] ?? 'Unknown'} (liked: ${item['liked_at']})');
          }
        }
      } catch (e) {
        print('   ❌ LỖI khi lấy liked songs: $e');
        rethrow;
      }

      // Test lấy qua view songs_with_artists
      try {
        final responseWithArtists = await supabase
            .from('user_liked_songs')
            .select('song_id, songs_with_artists(*)')
            .eq('user_id', userId)
            .order('liked_at', ascending: false)
            .limit(5);

        print(
            '   ✅ Lấy với songs_with_artists view: ${responseWithArtists.length} bài');
      } catch (e) {
        print('   ⚠️ View songs_with_artists có thể không tồn tại: $e');
      }
    });
  });

  group('Kiểm tra chức năng LIKE ALBUM', () {
    test('Kiểm tra và toggle like album', () async {
      if (testAlbumId == null) {
        print('⚠️ Không có album để test, bỏ qua...');
        return;
      }

      print('\n💿 Kiểm tra chức năng LIKE ALBUM...');

      // Test 1: Kiểm tra trạng thái like ban đầu
      print('   📍 Test 1: Kiểm tra trạng thái like ban đầu...');
      final checkInitial = await supabase
          .from('user_liked_albums')
          .select('id')
          .eq('user_id', userId)
          .eq('album_id', testAlbumId!)
          .maybeSingle();

      final wasLiked = checkInitial != null;
      print('   → Trạng thái ban đầu: ${wasLiked ? "Đã like" : "Chưa like"}');

      // Test 2: Like album (sử dụng upsert như trong code gốc)
      print('   📍 Test 2: Like album (upsert)...');
      await supabase.from('user_liked_albums').upsert({
        'user_id': userId,
        'album_id': testAlbumId,
        'liked_at': DateTime.now().toIso8601String(),
      });
      print('   ✅ Like album thành công!');

      // Test 3: Kiểm tra đã like
      print('   📍 Test 3: Xác nhận đã like...');
      final checkAfterLike = await supabase
          .from('user_liked_albums')
          .select('id, liked_at')
          .eq('user_id', userId)
          .eq('album_id', testAlbumId!)
          .maybeSingle();

      expect(checkAfterLike, isNotNull, reason: 'Album phải được like');
      print('   ✅ Xác nhận: Album đã được like');
      print('   → Liked at: ${checkAfterLike!['liked_at']}');

      // Test 4: Unlike album
      print('   📍 Test 4: Unlike album...');
      await supabase
          .from('user_liked_albums')
          .delete()
          .eq('user_id', userId)
          .eq('album_id', testAlbumId!);
      print('   ✅ Unlike album thành công!');

      // Test 5: Kiểm tra đã unlike
      print('   📍 Test 5: Xác nhận đã unlike...');
      final checkAfterUnlike = await supabase
          .from('user_liked_albums')
          .select('id')
          .eq('user_id', userId)
          .eq('album_id', testAlbumId!)
          .maybeSingle();

      expect(checkAfterUnlike, isNull, reason: 'Album phải được unlike');
      print('   ✅ Xác nhận: Album đã được unlike');

      // Khôi phục trạng thái ban đầu
      if (wasLiked) {
        await supabase.from('user_liked_albums').upsert({
          'user_id': userId,
          'album_id': testAlbumId,
          'liked_at': DateTime.now().toIso8601String(),
        });
        print('   ℹ️ Đã khôi phục trạng thái like ban đầu');
      }

      print('   ✅ KIỂM TRA LIKE ALBUM: THÀNH CÔNG!');
    });

    test('Lấy danh sách album đã like', () async {
      print('\n📋 Kiểm tra lấy danh sách album đã like...');

      try {
        final response = await supabase
            .from('user_liked_albums')
            .select('album_id, liked_at, albums(id, name)')
            .eq('user_id', userId)
            .order('liked_at', ascending: false);

        print('   ✅ Tổng số album đã like: ${response.length}');

        if (response.isNotEmpty) {
          print('   📋 Danh sách (tối đa 5):');
          for (var i = 0; i < response.length && i < 5; i++) {
            final item = response[i];
            final album = item['albums'];
            print(
                '      ${i + 1}. ${album?['name'] ?? 'Unknown'} (liked: ${item['liked_at']})');
          }
        }
      } catch (e) {
        print('   ❌ LỖI khi lấy liked albums: $e');
        rethrow;
      }

      // Test lấy qua view albums_with_artists
      try {
        final responseWithArtists = await supabase
            .from('user_liked_albums')
            .select('album_id, albums_with_artists(*)')
            .eq('user_id', userId)
            .order('liked_at', ascending: false)
            .limit(5);

        print(
            '   ✅ Lấy với albums_with_artists view: ${responseWithArtists.length} album');
      } catch (e) {
        print('   ⚠️ View albums_with_artists có thể không tồn tại: $e');
      }
    });
  });
}
