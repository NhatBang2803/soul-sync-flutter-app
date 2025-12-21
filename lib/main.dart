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
import 'pages/album_page.dart';
import 'pages/auth/login_screen.dart';
import 'components/mini_player.dart';
import 'services/audio_player_service.dart';
import 'services/auth_service.dart';

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

  // Sign out to force login every time (remove this line to keep sessions)
  await Supabase.instance.client.auth.signOut();

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
      home: const AuthWrapper(),
      routes: {
        '/admin': (context) => const AdminSeedPage(),
        '/main': (context) => const MainScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/album') {
          final albumId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => AlbumPage(albumId: albumId ?? ''),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Wrapper to check auth state and show appropriate screen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      // When user signs in (including OAuth), ensure profile exists
      if (data.event == AuthChangeEvent.signedIn) {
        await _authService.ensureUserProfile();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // Only show main screen if logged in
    if (session != null) {
      return const MainScreen();
    }

    // Show login page (now imported from pages/auth/login_screen.dart)
    return const LoginScreen();
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
        // Using MiniPlayerDynamic from components/mini_player.dart
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
          Positioned.fill(child: NowPlayingPage(onClose: _closePlayer)),
      ],
    );
  }
}
