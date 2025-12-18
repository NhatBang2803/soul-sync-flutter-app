import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'library_page.dart';
import 'profile_page.dart';
import 'now_playing_page.dart';
import 'admin_seed_page.dart';
import 'components/mini_player.dart';
import 'data/mock_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  int _currentSongIndex = 0;
  bool _isPlaying = false;
  bool _showNowPlaying = false;

  void _onTabTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
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
    final currentSong = MockData.songs[_currentSongIndex];

    return Stack(
      children: [
        // Main Content
        _getCurrentPage(),

        // Mini Player
        if (!_showNowPlaying && _currentSongIndex >= 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(
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
