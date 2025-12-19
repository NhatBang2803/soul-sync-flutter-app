import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'services/supabase_service.dart';
import 'services/audio_player_service.dart';
import 'models/song.dart';
import 'now_playing_page.dart';
import 'core/core.dart';

class SearchPage extends StatefulWidget {
  final Function(int)? onTabChanged;
  
  const SearchPage({super.key, this.onTabChanged});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayerService _audioService = AudioPlayerService();
  
  String _searchQuery = '';
  List<Song> _searchResults = [];
  bool _isSearching = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() => _isSearching = true);
    
    try {
      final results = await _supabaseService.searchSongs(query);
      if (mounted) {
        setState(() {
          _searchResults = results.map((json) => Song.fromJson(json)).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  void _onSongTap(Song song, int index) async {
    final playlist = _searchResults.map((s) => s.toPlayerFormat()).toList();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildBrowseCategories()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemTapped: widget.onTabChanged ?? (index) {},
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: AppStrings.searchHint,
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _performSearch(value);
                },
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _searchResults = [];
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBrowseCategories() {
    final categories = [
      {'name': 'Podcast', 'color': AppColors.primary, 'emoji': '🎙️'},
      {'name': 'Nhạc sống', 'color': const Color(0xFF8E24AA), 'emoji': '🎸'},
      {'name': 'Nhạc được tạo cho bạn', 'color': const Color(0xFF1E88E5), 'emoji': '🎵'},
      {'name': 'Bảng xếp hạng', 'color': const Color(0xFFE53935), 'emoji': '📊'},
      {'name': 'Nhạc mới phát hành', 'color': const Color(0xFFD81B60), 'emoji': '🆕'},
      {'name': 'Nhạc Việt', 'color': const Color(0xFFF57C00), 'emoji': '🇻🇳'},
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.browse,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(
                  name: category['name'] as String,
                  color: category['color'] as Color,
                  emoji: category['emoji'] as String,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String name,
    required Color color,
    required String emoji,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const AppLoadingIndicator();
    }
    
    if (_searchResults.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: AppStrings.noResults,
        subtitle: AppStrings.tryAgain,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final song = _searchResults[index];
        return SongListTile(
          song: song.toPlayerFormat(),
          onTap: () => _onSongTap(song, index),
          padding: const EdgeInsets.symmetric(vertical: 8),
        );
      },
    );
  }
}
