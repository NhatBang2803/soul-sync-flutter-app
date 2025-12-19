import 'dart:async';
import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'models/models.dart';
import 'services/supabase_service.dart';
import 'services/audio_player_service.dart';
import 'services/queue_service.dart';
import 'core/core.dart';
import 'now_playing_page.dart';
import 'pages/artist_page.dart';
import 'pages/album_page.dart';
import 'pages/playlist_page.dart';

class SearchPage extends StatefulWidget {
  final Function(int)? onTabChanged;
  
  const SearchPage({super.key, this.onTabChanged});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final QueueService _queueService = QueueService();
  
  Timer? _debounceTimer;
  bool _isSearching = false;
  bool _hasSearched = false;

  // Search results by category
  List<Song> _songResults = [];
  List<Artist> _artistResults = [];
  List<Album> _albumResults = [];
  List<Playlist> _playlistResults = [];

  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Tất cả', 'Bài hát', 'Nghệ sĩ', 'Album', 'Playlist'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        _songResults = [];
        _artistResults = [];
        _albumResults = [];
        _playlistResults = [];
      });
      return;
    }

    // Debounce search for 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final results = await _supabaseService.searchAll(query);

      if (mounted) {
        setState(() {
          _songResults = (results['songs'] ?? [])
              .map<Song>((json) => Song.fromJson(json))
              .toList();
          _artistResults = (results['artists'] ?? [])
              .map<Artist>((json) => Artist.fromJson(json))
              .toList();
          _albumResults = (results['albums'] ?? [])
              .map<Album>((json) => Album.fromJson(json))
              .toList();
          _playlistResults = (results['playlists'] ?? [])
              .map<Playlist>((json) => Playlist.fromJson(json))
              .toList();
          _hasSearched = true;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _songResults = [];
      _artistResults = [];
      _albumResults = [];
      _playlistResults = [];
    });
  }

  void _onSongTap(Song song) {
    _queueService.replaceQueue([song], startIndex: 0);
    _audioPlayerService.setPlaylist([song.toPlayerFormat()], 0);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NowPlayingPage()),
    );
  }

  bool get _hasResults {
    return _songResults.isNotEmpty ||
        _artistResults.isNotEmpty ||
        _albumResults.isNotEmpty ||
        _playlistResults.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            if (_hasSearched) _buildCategoryTabs(),
            Expanded(
              child: _hasSearched ? _buildSearchResults() : _buildBrowseContent(),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.search,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tìm bài hát, nghệ sĩ, album...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: _clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const AppLoadingIndicator();
    }

    if (!_hasResults) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: 'Không tìm thấy kết quả',
        subtitle: 'Hãy thử tìm kiếm với từ khóa khác',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Songs
          if (_shouldShowCategory(1) && _songResults.isNotEmpty)
            _buildSongsSection(),
          // Artists
          if (_shouldShowCategory(2) && _artistResults.isNotEmpty)
            _buildArtistsSection(),
          // Albums
          if (_shouldShowCategory(3) && _albumResults.isNotEmpty)
            _buildAlbumsSection(),
          // Playlists
          if (_shouldShowCategory(4) && _playlistResults.isNotEmpty)
            _buildPlaylistsSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  bool _shouldShowCategory(int categoryIndex) {
    return _selectedCategoryIndex == 0 || _selectedCategoryIndex == categoryIndex;
  }

  Widget _buildSongsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Bài hát',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._songResults.map((song) => _buildSongItem(song)),
      ],
    );
  }

  Widget _buildSongItem(Song song) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: song.coverUrl != null
            ? Image.network(
                song.coverUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultCover(Icons.music_note),
              )
            : _buildDefaultCover(Icons.music_note),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.allArtists,
        style: const TextStyle(color: AppColors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.play_circle_outline, color: AppColors.primary),
        onPressed: () => _onSongTap(song),
      ),
      onTap: () => _onSongTap(song),
    );
  }

  Widget _buildArtistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Nghệ sĩ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _artistResults.length,
            itemBuilder: (context, index) {
              return _buildArtistItem(_artistResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArtistItem(Artist artist) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArtistPage(artistId: artist.id)),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.surface,
              backgroundImage: artist.imageUrl != null 
                  ? NetworkImage(artist.imageUrl!) 
                  : null,
              child: artist.imageUrl == null
                  ? const Icon(Icons.person, size: 30, color: AppColors.textMuted)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Album',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._albumResults.map((album) => _buildAlbumItem(album)),
      ],
    );
  }

  Widget _buildAlbumItem(Album album) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: album.coverUrl != null
            ? Image.network(
                album.coverUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultCover(Icons.album),
              )
            : _buildDefaultCover(Icons.album),
      ),
      title: Text(
        album.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        album.artist,
        style: const TextStyle(color: AppColors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlbumPage(albumId: album.id)),
        );
      },
    );
  }

  Widget _buildPlaylistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Playlist',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._playlistResults.map((playlist) => _buildPlaylistItem(playlist)),
      ],
    );
  }

  Widget _buildPlaylistItem(Playlist playlist) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: playlist.coverUrl != null
            ? Image.network(
                playlist.coverUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultCover(Icons.queue_music),
              )
            : _buildDefaultCover(Icons.queue_music),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.songCount} bài hát',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlaylistPage(playlistId: playlist.id)),
        );
      },
    );
  }

  Widget _buildDefaultCover(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.surface,
      child: Icon(icon, color: AppColors.textMuted),
    );
  }

  Widget _buildBrowseContent() {
    // Categories for browsing when not searching
    final browseCategories = [
      {'name': 'Pop Việt Nam', 'color': const Color(0xFFE91E63), 'icon': Icons.favorite},
      {'name': 'Hip-Hop', 'color': const Color(0xFF9C27B0), 'icon': Icons.headphones},
      {'name': 'Indie', 'color': const Color(0xFF673AB7), 'icon': Icons.music_note},
      {'name': 'Ballad', 'color': const Color(0xFF3F51B5), 'icon': Icons.piano},
      {'name': 'EDM', 'color': const Color(0xFF00BCD4), 'icon': Icons.speaker},
      {'name': 'R&B', 'color': const Color(0xFFFF5722), 'icon': Icons.album},
      {'name': 'Rock', 'color': const Color(0xFF795548), 'icon': Icons.electric_bolt},
      {'name': 'Jazz', 'color': const Color(0xFF607D8B), 'icon': Icons.nightlife},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khám phá thể loại',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: browseCategories.map((category) {
              return _buildBrowseCategory(
                category['name'] as String,
                category['color'] as Color,
                category['icon'] as IconData,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseCategory(String name, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Set search to category name
        _searchController.text = name;
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: 60,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
