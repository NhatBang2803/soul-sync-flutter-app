import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'now_playing_page.dart';
import 'services/supabase_service.dart';
import 'services/audio_player_service.dart';
import 'models/song.dart';
import 'core/core.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onTabChanged;
  
  const HomePage({super.key, this.onTabChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayerService _audioService = AudioPlayerService();
  
  List<Song> _songs = [];
  bool _isLoading = true;
  String? _error;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final songsData = await _supabaseService.getSongs();
      
      if (mounted) {
        setState(() {
          _songs = songsData.map((json) => Song.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _songs = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels <= 0 && 
        _scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      _resetPage();
    }
  }

  void _resetPage() {
    _loadSongs();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.refresh),
        duration: Duration(milliseconds: 800),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onSongTap(Song song, int index) async {
    final playlist = _songs.map((s) => s.toPlayerFormat()).toList();
    await _audioService.setPlaylist(playlist, index);
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NowPlayingPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabFilters(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickAccessGrid(),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Nội dung bạn nghe gần đây'),
                    _buildRecentlyPlayedList(),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Nghe lại'),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onItemTapped: widget.onTabChanged ?? (index) {},
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          // Profile Avatar with gradient border
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.background,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surface,
                backgroundImage: const AssetImage('assets/images/ellipse1.png'),
                onBackgroundImageError: (exception, stackTrace) {},
                child: const Icon(Icons.person, size: 16, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GreetingUtils.getGreeting(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Soul Sync',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Notification icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textPrimary,
                iconSize: 28,
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabFilters() {
    return AppFilterChipRow(
      labels: const [AppStrings.all, AppStrings.music, AppStrings.podcast],
      selectedIndex: _selectedFilterIndex,
      onSelected: (index) {
        setState(() => _selectedFilterIndex = index);
      },
    );
  }

  Widget _buildQuickAccessGrid() {
    final items = [
      {'title': 'EM XINH SAY\nHI 2025', 'color': Colors.pink},
      {'title': 'ANH TRAI SAY\nHI 2025', 'color': Colors.blue},
      {'title': 'EM XINH SAY\nHI 2025', 'color': Colors.pink},
      {'title': 'ANH TRAI SAY\nHI 2025', 'color': Colors.blue},
      {'title': 'EM XINH SAY\nHI 2025', 'color': Colors.pink},
      {'title': 'ANH TRAI SAY\nHI 2025', 'color': Colors.blue},
      {'title': 'EM XINH SAY\nHI 2025', 'color': Colors.pink},
      {'title': 'ANH TRAI SAY\nHI 2025', 'color': Colors.blue},
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessItem(
                      items[i]['title'] as String,
                      items[i]['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 9),
                  if (i + 1 < items.length)
                    Expanded(
                      child: _buildQuickAccessItem(
                        items[i + 1]['title'] as String,
                        items[i + 1]['color'] as Color,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(String title, Color color) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.music_note, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayedList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: AppLoadingIndicator(),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: AppErrorState(
          message: _error!,
          onRetry: _loadSongs,
        ),
      );
    }

    if (_songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: AppEmptyState(
          icon: Icons.music_off,
          title: AppStrings.noSong,
          subtitle: 'Vui lòng thêm dữ liệu vào Supabase.',
        ),
      );
    }

    return Column(
      children: _songs.take(6).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final song = entry.value;
        return SongListTile(
          song: song.toPlayerFormat(),
          onTap: () => _onSongTap(song, index),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      }).toList(),
    );
  }
}
