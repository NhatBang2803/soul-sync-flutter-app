import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'dart:async';
import 'config/app_config.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'library_page.dart';
import 'profile_page.dart';
import 'now_playing_page.dart';
import 'admin_seed_page.dart';
import 'services/audio_player_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize JustAudioMediaKit for Linux support
  JustAudioMediaKit.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoulSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF23DD5B),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainScreen(),
      routes: {
        '/admin': (context) => const AdminSeedPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTab = 0;
  bool _isPlaying = false;
  bool _showNowPlaying = false;
  
  // Audio service for tracking current song
  final AudioPlayerService _audioService = AudioPlayerService();
  StreamSubscription? _playingSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initAudioListeners();
  }

  void _initAudioListeners() {
    // Listen to playing state changes
    _playingSubscription = _audioService.playingStream.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
      }
    });
    
    // Listen to player state to detect when song changes
    _playerStateSubscription = _audioService.playerStateStream.listen((_) {
      if (mounted) {
        setState(() {}); // Rebuild to show updated song info
      }
    });
  }

  @override
  void dispose() {
    _playingSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  void _togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  void _expandPlayer() {
    setState(() {
      _showNowPlaying = true;
    });
  }

  void _closePlayer() {
    setState(() {
      _showNowPlaying = false;
    });
  }

  Widget _getCurrentPage() {
    switch (_selectedTab) {
      case 0:
        return HomePage(onTabChanged: _onTabTapped);
      case 1:
        return SearchPage(onTabChanged: _onTabTapped);
      case 2:
        return LibraryPage(onTabChanged: _onTabTapped);
      case 3:
        return ProfilePage(onTabChanged: _onTabTapped);
      default:
        return HomePage(onTabChanged: _onTabTapped);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current song from AudioPlayerService
    final currentSong = _audioService.currentSong;
    final hasSong = currentSong != null;

    return Stack(
      children: [
        // Main Content
        _getCurrentPage(),

        // Mini Player - only show when there's a song playing
        if (!_showNowPlaying && hasSong)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayerDynamic(
              song: currentSong,
              isPlaying: _isPlaying,
              onPlayPause: _togglePlayPause,
              onExpand: _expandPlayer,
            ),
          ),

        // Now Playing Screen (Full Screen)
        if (_showNowPlaying)
          Positioned.fill(
            child: NowPlayingPage(
              onClose: _closePlayer,
            ),
          ),
      ],
    );
  }
}

/// Dynamic MiniPlayer that works with Map<String, dynamic> from AudioPlayerService
class MiniPlayerDynamic extends StatelessWidget {
  final Map<String, dynamic> song;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onExpand;

  const MiniPlayerDynamic({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final title = song['songName'] ?? song['title'] ?? 'Unknown';
    final artist = song['artistName'] ?? song['artist_name'] ?? 'Unknown Artist';
    final coverUrl = song['coverUrl'] ?? song['cover_url'];

    return GestureDetector(
      onTap: onExpand,
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 80),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildCoverImage(coverUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artist,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: onPlayPause,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? url) {
    if (url == null || url.isEmpty) {
      return _buildDefaultCover();
    }

    // Check if it's a network URL or asset
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    } else {
      return Image.asset(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    }
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey[800],
      child: const Icon(Icons.music_note, color: Colors.white, size: 24),
    );
  }
}
