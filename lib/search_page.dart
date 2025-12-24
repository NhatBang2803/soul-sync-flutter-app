import 'dart:async';
import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'components/add_to_playlist_dialog.dart';
import 'components/artist_card.dart';
import 'models/models.dart';
import 'services/supabase_service.dart';
import 'services/audio_player_service.dart';
import 'services/queue_service.dart';
import 'core/core.dart';
import 'now_playing_page.dart';
import 'pages/artist_page.dart';
import 'pages/album_page.dart';
import 'pages/playlist_page.dart';
import 'pages/podcast_page.dart';

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
  List<Podcast> _podcastResults = [];

  // Random suggestions khi không có kết quả
  List<Song> _randomSongs = [];
  List<Artist> _randomArtists = [];
  List<Album> _randomAlbums = [];
  List<Playlist> _randomPlaylists = [];
  List<Podcast> _randomPodcasts = [];
  List<Map<String, dynamic>> _browseGenres = []; // Random genres for browsing
  bool _isLoadingSuggestions = false;
  bool _isLoadingGenres = false;

  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Tất cả',
    'Bài hát',
    'Nghệ sĩ',
    'Album',
    'Playlist',
    'Podcast',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRandomGenres(); // Load random genres on init
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
        _podcastResults = [];
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
          _podcastResults = (results['podcasts'] ?? [])
              .map<Podcast>((json) => Podcast.fromJson(json))
              .toList();
          _hasSearched = true;
          _isSearching = false;
        });

        // Nếu không có kết quả, fetch random suggestions
        if (!_hasResults) {
          _fetchRandomSuggestions();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
        });
        // Fetch random suggestions khi có lỗi
        _fetchRandomSuggestions();
      }
    }
  }

  /// Fetch random suggestions khi không có kết quả tìm kiếm
  Future<void> _fetchRandomSuggestions() async {
    if (_isLoadingSuggestions) return;

    setState(() => _isLoadingSuggestions = true);

    try {
      final results = await Future.wait([
        _supabaseService.getRandomSongs(3),
        _supabaseService.getArtists(), // Get all then take 3
        _supabaseService.getRandomAlbums(3),
        _supabaseService.getPublicPlaylists(), // Get all then take 3
        _supabaseService.getPodcasts(limit: 10), // Get podcasts for suggestions
      ]);

      if (mounted) {
        final artists = (results[1] as List).toList();
        artists.shuffle();

        final playlists = (results[3] as List).toList();
        playlists.shuffle();

        final podcasts = (results[4] as List).toList();
        podcasts.shuffle();

        setState(() {
          _randomSongs = (results[0] as List)
              .map<Song>((json) => Song.fromJson(json))
              .take(3)
              .toList();
          _randomArtists = artists
              .take(3)
              .map<Artist>((json) => Artist.fromJson(json))
              .toList();
          _randomAlbums = (results[2] as List)
              .map<Album>((json) => Album.fromJson(json))
              .take(3)
              .toList();
          _randomPlaylists = playlists
              .take(3)
              .map<Playlist>((json) => Playlist.fromJson(json))
              .toList();
          _randomPodcasts = podcasts
              .take(3)
              .map<Podcast>((json) => Podcast.fromJson(json))
              .toList();
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
      }
    }
  }

  /// Load 8 random genres from database
  Future<void> _loadRandomGenres() async {
    setState(() => _isLoadingGenres = true);

    try {
      final genresData = await _supabaseService.getGenres();

      if (mounted && genresData.isNotEmpty) {
        // Shuffle and take 8 random genres
        final shuffled = List<Map<String, dynamic>>.from(genresData);
        shuffled.shuffle();

        setState(() {
          _browseGenres = shuffled.take(8).toList();
          _isLoadingGenres = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGenres = false);
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
      _podcastResults = [];
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
        _playlistResults.isNotEmpty ||
        _podcastResults.isNotEmpty;
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
              child: _hasSearched
                  ? _buildSearchResults()
                  : _buildBrowseContent(),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
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
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
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
      return _buildNoResultsWithSuggestions();
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
          // Podcasts
          if (_shouldShowCategory(5) && _podcastResults.isNotEmpty)
            _buildPodcastsSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Build no results message với random suggestions
  Widget _buildNoResultsWithSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary.withOpacity(0.8),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Không có thông tin phù hợp với yêu cầu của bạn, nhưng có thể bạn sẽ thích những nội dung bên dưới',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Loading suggestions
          if (_isLoadingSuggestions)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: AppLoadingIndicator()),
            )
          else ...[
            // Random Songs
            if (_randomSongs.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Bài hát gợi ý',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._randomSongs.map((song) => _buildSongItem(song)),
            ],

            // Random Artists
            if (_randomArtists.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Nghệ sĩ gợi ý',
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
                  itemCount: _randomArtists.length,
                  itemBuilder: (context, index) {
                    final artist = _randomArtists[index];
                    // Using reusable ArtistCard component
                    return ArtistCard(
                      artist: artist,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArtistPage(artistId: artist.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],

            // Random Albums
            if (_randomAlbums.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Album gợi ý',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._randomAlbums.map((album) => _buildAlbumItem(album)),
            ],

            // Random Playlists
            if (_randomPlaylists.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Playlist gợi ý',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._randomPlaylists.map(
                (playlist) => _buildPlaylistItem(playlist),
              ),
            ],

            // Random Podcasts
            if (_randomPodcasts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Podcast gợi ý',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._randomPodcasts.map((podcast) => _buildPodcastItem(podcast)),
            ],
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  bool _shouldShowCategory(int categoryIndex) {
    return _selectedCategoryIndex == 0 ||
        _selectedCategoryIndex == categoryIndex;
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
                errorBuilder: (_, __, ___) =>
                    _buildDefaultCover(Icons.music_note),
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AddToPlaylistButton(
            songId: song.id,
            songTitle: song.title,
            song: song,
            size: 26,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.play_circle_outline,
              color: AppColors.primary,
            ),
            onPressed: () => _onSongTap(song),
          ),
        ],
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
              final artist = _artistResults[index];
              // Using reusable ArtistCard component
              return ArtistCard(
                artist: artist,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistPage(artistId: artist.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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
                errorBuilder: (_, __, ___) =>
                    _buildDefaultCover(Icons.queue_music),
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
          MaterialPageRoute(
            builder: (context) => PlaylistPage(playlistId: playlist.id),
          ),
        );
      },
    );
  }

  Widget _buildPodcastsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Podcast',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._podcastResults.map((podcast) => _buildPodcastItem(podcast)),
      ],
    );
  }

  Widget _buildPodcastItem(Podcast podcast) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: podcast.imageUrl != null
            ? Image.network(
                podcast.imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildDefaultCover(Icons.podcasts),
              )
            : _buildDefaultCover(Icons.podcasts),
      ),
      title: Text(
        podcast.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${podcast.hostName} • ${podcast.episodeCount} tập',
        style: const TextStyle(color: AppColors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PodcastPage(podcastId: podcast.id),
          ),
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

          // Show loading or genres
          _isLoadingGenres
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: AppLoadingIndicator(),
                  ),
                )
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: _browseGenres.map((genre) {
                    return _buildBrowseCategory(
                      genre['display_name'] ?? genre['name'] ?? 'Unknown',
                      _parseColor(genre['color'] as String?),
                      _getIconForGenre(genre['name'] as String?),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  /// Parse color from hex string
  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return const Color(0xFF9C27B0); // Default purple
    }

    try {
      // Remove # if present
      final hex = colorHex.replaceAll('#', '');
      // Add FF for full opacity if not present
      final colorString = hex.length == 6 ? 'FF$hex' : hex;
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return const Color(0xFF9C27B0); // Default purple on error
    }
  }

  /// Get icon based on genre name
  IconData _getIconForGenre(String? genreName) {
    if (genreName == null) return Icons.music_note;

    final name = genreName.toLowerCase();
    if (name.contains('pop')) return Icons.favorite;
    if (name.contains('hip') || name.contains('rap')) return Icons.headphones;
    if (name.contains('indie')) return Icons.music_note;
    if (name.contains('ballad')) return Icons.piano;
    if (name.contains('edm') || name.contains('electronic'))
      return Icons.speaker;
    if (name.contains('r&b') || name.contains('rnb')) return Icons.album;
    if (name.contains('rock')) return Icons.electric_bolt;
    if (name.contains('jazz')) return Icons.nightlife;
    if (name.contains('classical')) return Icons.music_note;
    if (name.contains('acoustic')) return Icons.music_note;
    if (name.contains('drill')) return Icons.headphones;

    return Icons.music_note; // Default icon
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
              child: Icon(icon, size: 60, color: Colors.white.withOpacity(0.2)),
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
