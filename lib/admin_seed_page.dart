import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSeedPage extends StatefulWidget {
  const AdminSeedPage({super.key});

  @override
  State<AdminSeedPage> createState() => _AdminSeedPageState();
}

class _AdminSeedPageState extends State<AdminSeedPage> {
  bool _isSeeding = false;
  String _message = '';
  final _client = Supabase.instance.client;

  Future<void> _seedData() async {
    setState(() {
      _isSeeding = true;
      _message = 'Seeding data...';
    });

    try {
      // Seed Artists
      await _client.from('artists').upsert([
        {
          'id': 'a1000000-0000-0000-0000-000000000001',
          'name': 'HIEUTHUHAI',
          'image_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          'followers': 2400000,
        },
        {
          'id': 'a1000000-0000-0000-0000-000000000002',
          'name': 'Sơn Tùng M-TP',
          'image_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          'followers': 1800000,
        },
        {
          'id': 'a1000000-0000-0000-0000-000000000003',
          'name': 'Phương Mỹ Chi',
          'image_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          'followers': 3200000,
        },
      ]);

      // Seed Albums
      await _client.from('albums').upsert([
        {
          'id': 'b1000000-0000-0000-0000-000000000001',
          'name': 'Trại sáng tác 2024',
          'artist_id': 'a1000000-0000-0000-0000-000000000001',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          'release_year': 2024,
        },
        {
          'id': 'b1000000-0000-0000-0000-000000000002',
          'name': 'M-TP Collection',
          'artist_id': 'a1000000-0000-0000-0000-000000000002',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          'release_year': 2023,
        },
      ]);

      // Seed Songs with demo audio URLs
      await _client.from('songs').upsert([
        {
          'title': 'Ai cũng phải bắt đầu từ đâu đó',
          'artist_id': 'a1000000-0000-0000-0000-000000000001',
          'album_id': 'b1000000-0000-0000-0000-000000000001',
          'duration': 245,
          'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        },
        {
          'title': 'Ngân nga',
          'artist_id': 'a1000000-0000-0000-0000-000000000001',
          'album_id': 'b1000000-0000-0000-0000-000000000001',
          'duration': 312,
          'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        },
        {
          'title': 'ẾCH NGOÀI ĐÁY GIẾNG',
          'artist_id': 'a1000000-0000-0000-0000-000000000003',
          'duration': 198,
          'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        },
        {
          'title': 'Mưa tháng sáu',
          'artist_id': 'a1000000-0000-0000-0000-000000000002',
          'album_id': 'b1000000-0000-0000-0000-000000000002',
          'duration': 267,
          'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        },
        {
          'title': 'Em của ngày hôm qua',
          'artist_id': 'a1000000-0000-0000-0000-000000000002',
          'album_id': 'b1000000-0000-0000-0000-000000000002',
          'duration': 289,
          'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        },
        {
          'title': 'Lạc trôi',
          'artist_id': 'a1000000-0000-0000-0000-000000000002',
          'album_id': 'b1000000-0000-0000-0000-000000000002',
          'duration': 215,
          'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        },
      ]);

      // Seed Playlists
      await _client.from('playlists').upsert([
        {
          'id': 'c1000000-0000-0000-0000-000000000001',
          'name': 'EM XINH SAY HI 2025',
          'description': 'Những ca khúc hot nhất từ chương trình',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          'is_public': true,
        },
        {
          'id': 'c1000000-0000-0000-0000-000000000002',
          'name': 'ANH TRAI SAY HI 2025',
          'description': 'Playlist chill cho ngày mới',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          'is_public': true,
        },
        {
          'id': 'c1000000-0000-0000-0000-000000000003',
          'name': 'V-Pop Top Hits',
          'description': 'Top các bài hát V-Pop hot nhất',
          'cover_url': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          'is_public': true,
        },
      ]);

      setState(() {
        _message = '✅ Success! Data đã được seed vào Supabase.';
        _isSeeding = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Error: $e';
        _isSeeding = false;
      });
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Warning'),
        content: const Text('Xóa TẤT CẢ dữ liệu trong Supabase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSeeding = true;
      _message = 'Clearing data...';
    });

    try {
      await _client.from('playlist_songs').delete().neq('id', '');
      await _client.from('user_liked_songs').delete().neq('id', '');
      await _client.from('songs').delete().neq('id', '');
      await _client.from('albums').delete().neq('id', '');
      await _client.from('playlists').delete().neq('id', '');
      await _client.from('artists').delete().neq('id', '');

      setState(() {
        _message = '✅ All data cleared.';
        _isSeeding = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Error: $e';
        _isSeeding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin - Supabase'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Color(0xFF23DD5B),
              ),
              const SizedBox(height: 20),
              const Text(
                'SoulSync Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Seed mock data vào Supabase + Cloudinary',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              if (_isSeeding)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF23DD5B)),
                    SizedBox(height: 20),
                  ],
                ),
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSeeding ? null : _seedData,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Seed Mock Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23DD5B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSeeding ? null : _clearData,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Clear All Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Sẽ seed:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 3 Artists\n'
                      '• 2 Albums\n'
                      '• 6 Songs (demo audio từ SoundHelix)\n'
                      '• 3 Playlists\n\n'
                      '⚠️ Nhớ đã tạo tables trong Supabase!',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
