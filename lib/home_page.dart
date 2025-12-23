import 'dart:ui';
import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'components/add_to_playlist_dialog.dart';
import 'components/artist_card.dart';
import 'components/album_card.dart';
import 'components/podcast_card.dart';
import 'now_playing_page.dart';
import 'services/supabase_service.dart';
import 'services/audio_player_service.dart';
import 'services/queue_service.dart';
import 'services/auth_service.dart';
import 'models/models.dart';
import 'core/core.dart';
import 'pages/artist_page.dart';
import 'pages/podcast_page.dart';

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
  final QueueService _queueService = QueueService();
  final AuthService _authService = AuthService();

  List<Song> _recentlyPlayed = [];
  List<Genre> _genres = [];
  Map<String, List<Song>> _rankingsByGenre = {};
  List<Artist> _topArtists = [];
  List<Song> _newReleases = [];
  List<Album> _quickAccessAlbums = [];

  // Podcast data
  List<Podcast> _podcasts = [];
  List<PodcastEpisode> _podcastNewReleases = [];
  List<Podcast> _recentlyPlayedPodcasts = [];

  bool _isLoading = true;
  String? _error;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load recently played unique songs (no duplicates)
      List<Map<String, dynamic>> recentlyPlayedData = [];
      try {
        final userId = _authService.currentUserId;
        if (userId != null) {
          recentlyPlayedData = await _supabaseService
              .getRecentlyPlayedUniqueSongs(userId, limit: 5);
        }
      } catch (e) {
        print('Error loading recently played: $e');
      }

      // Load genres (optional)
      List<Map<String, dynamic>> genresData = [];
      try {
        genresData = await _supabaseService.getGenres();
      } catch (e) {
        print('Error loading genres: $e');
      }

      // Load top artists (optional)
      List<Map<String, dynamic>> artistsData = [];
      try {
        artistsData = await _supabaseService.getWeeklyArtistRanking();
      } catch (e) {
        // Fallback to regular artists list
        try {
          artistsData = await _supabaseService.getArtists();
        } catch (e2) {
          print('Error loading artists: $e2');
        }
      }

      // Load new releases (optional)
      List<Map<String, dynamic>> releasesData = [];
      try {
        releasesData = await _supabaseService.getNewReleases();
      } catch (e) {
        print('Error loading new releases: $e');
      }

      // Load quick access albums (4 random)
      List<Map<String, dynamic>> quickAlbumsData = [];
      try {
        quickAlbumsData = await _supabaseService.getRandomAlbums(4);
      } catch (e) {
        print('Error loading quick access albums: $e');
      }

      // Load podcasts (for Tab Tất cả and Podcast)
      List<Map<String, dynamic>> podcastsData = [];
      try {
        podcastsData = await _supabaseService.getPodcasts(limit: 10);
      } catch (e) {
        print('Error loading podcasts: $e');
      }

      // Load podcast new releases
      List<Map<String, dynamic>> podcastNewReleasesData = [];
      try {
        podcastNewReleasesData = await _supabaseService.getPodcastNewReleases();
      } catch (e) {
        print('Error loading podcast new releases: $e');
      }

      // Load recently played podcasts
      List<Map<String, dynamic>> recentPodcastsData = [];
      try {
        final userId = _authService.currentUserId;
        if (userId != null) {
          recentPodcastsData = await _supabaseService.getRecentlyPlayedPodcasts(
            userId,
          );
        }
      } catch (e) {
        print('Error loading recent podcasts: $e');
      }

      if (mounted) {
        final genres = genresData.map((json) => Genre.fromJson(json)).toList();

        // Load song rankings for each genre
        final rankingsMap = <String, List<Song>>{};
        for (final genre in genres.take(4)) {
          try {
            final rankings = await _supabaseService.getWeeklySongRankingByGenre(
              genre.name,
            );
            rankingsMap[genre.name] = rankings
                .map((json) => Song.fromJson(json))
                .toList();
          } catch (e) {
            rankingsMap[genre.name] = [];
          }
        }

        setState(() {
          // Database already returns unique songs, no need to filter
          _recentlyPlayed = recentlyPlayedData
              .map((song) => Song.fromJson(song))
              .toList();
          _genres = genres;
          _rankingsByGenre = rankingsMap;
          _topArtists = artistsData
              .map((json) => Artist.fromJson(json))
              .toList();
          _newReleases = releasesData
              .map((json) => Song.fromJson(json))
              .take(10)
              .toList();
          _quickAccessAlbums = quickAlbumsData
              .map((json) => Album.fromJson(json))
              .toList();
          _podcasts = podcastsData
              .map((json) => Podcast.fromJson(json))
              .toList();
          _podcastNewReleases = podcastNewReleasesData
              .map((json) => PodcastEpisode.fromJson(json))
              .toList();
          _recentlyPlayedPodcasts = recentPodcastsData
              .map((json) => Podcast.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _recentlyPlayed = [];
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
        _scrollController.position.pixels ==
            _scrollController.position.minScrollExtent) {
      _resetPage();
    }
  }

  void _resetPage() {
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.refresh),
        duration: Duration(milliseconds: 800),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onSongTap(Song song, List<Song> playlist, int index) async {
    _queueService.replaceQueue(playlist, startIndex: index);
    final playerPlaylist = playlist.map((s) => s.toPlayerFormat()).toList();
    await _audioService.setPlaylist(playerPlaylist, index);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NowPlayingPage()),
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
                child: _buildTabContent(),
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
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
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
          // Create Playlist icon
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded),
              color: Colors.black,
              iconSize: 26,
              onPressed: () => _showCreatePlaylistDialog(),
            ),
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

  /// Build content based on selected tab
  Widget _buildTabContent() {
    switch (_selectedFilterIndex) {
      case 0: // Tất cả
        return _buildAllTabContent();
      case 1: // Âm nhạc
        return _buildMusicTabContent();
      case 2: // Podcast
        return _buildPodcastTabContent();
      default:
        return _buildAllTabContent();
    }
  }

  /// Tab "Tất cả" - Albums, New Releases, Podcasts, Recently Played
  Widget _buildAllTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuickAccessGrid(),
        const SizedBox(height: 20),
        // New Releases (Music)
        if (_newReleases.isNotEmpty) ...[
          const SectionHeader(title: 'Mới phát hành'),
          _buildNewReleases(),
          const SizedBox(height: 20),
        ],
        // Podcasts Featured
        if (_podcasts.isNotEmpty) ...[
          const SectionHeader(title: 'Podcast nổi bật'),
          _buildPodcastList(),
          const SizedBox(height: 20),
        ],
        const SectionHeader(title: 'Nội dung bạn nghe gần đây'),
        _buildRecentlyPlayedList(),
        const SizedBox(height: 100),
      ],
    );
  }

  /// Tab "Âm nhạc" - Artists, Rankings, New Releases, Recently Played
  Widget _buildMusicTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly Artist Ranking
        if (_topArtists.isNotEmpty) ...[
          const SectionHeader(title: 'Nghệ sĩ hàng đầu tuần này'),
          _buildArtistRanking(),
          const SizedBox(height: 20),
        ],
        // Song Rankings by Genre
        ..._buildGenreRankings(),
        const SizedBox(height: 20),
        // New Releases
        if (_newReleases.isNotEmpty) ...[
          const SectionHeader(title: 'Mới phát hành'),
          _buildNewReleases(),
          const SizedBox(height: 20),
        ],
        const SectionHeader(title: 'Bài hát đã nghe gần đây'),
        _buildRecentlyPlayedList(),
        const SizedBox(height: 100),
      ],
    );
  }

  /// Tab "Podcast" - Podcasts only
  Widget _buildPodcastTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Podcasts
        if (_podcasts.isNotEmpty) ...[
          const SectionHeader(title: 'Podcast nổi bật'),
          _buildPodcastList(),
          const SizedBox(height: 20),
        ],
        // Podcast New Releases
        if (_podcastNewReleases.isNotEmpty) ...[
          const SectionHeader(title: 'Tập mới phát hành'),
          _buildPodcastNewReleasesList(),
          const SizedBox(height: 20),
        ],
        // Recently Played Podcasts
        if (_recentlyPlayedPodcasts.isNotEmpty) ...[
          const SectionHeader(title: 'Podcast đã nghe gần đây'),
          _buildRecentPodcastsList(),
          const SizedBox(height: 20),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  /// Build horizontal podcast list
  Widget _buildPodcastList() {
    return PodcastCardList(
      podcasts: _podcasts,
      onPodcastTap: (podcast) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PodcastPage(podcastId: podcast.id),
          ),
        );
      },
    );
  }

  /// Build podcast new releases list (episodes)
  Widget _buildPodcastNewReleasesList() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _podcastNewReleases.length,
        itemBuilder: (context, index) {
          final episode = _podcastNewReleases[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                // Phát episode ngay lập tức thay vì navigate đến PodcastPage
                final episodePlayerFormat = episode.toPlayerFormat();
                await _audioService.setPlaylist([episodePlayerFormat], 0);
              },
              child: SizedBox(
                width: 156,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: episode.podcastImage != null
                              ? Image.network(
                                  episode.podcastImage!,
                                  width: 156,
                                  height: 156,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 156,
                                  height: 156,
                                  color: AppColors.surface,
                                  child: const Icon(Icons.podcasts, size: 48),
                                ),
                        ),
                        // Play overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: const Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            episode.title.length > 50
                                ? '${episode.title.substring(0, 50)}...'
                                : episode.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            episode.podcastTitle ?? '',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build recently played podcasts list
  Widget _buildRecentPodcastsList() {
    return PodcastCardList(
      podcasts: _recentlyPlayedPodcasts,
      onPodcastTap: (podcast) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PodcastPage(podcastId: podcast.id),
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessGrid() {
    // Using reusable QuickAccessAlbumGrid component
    return QuickAccessAlbumGrid(
      albums: _quickAccessAlbums,
      maxItems: 4,
      onAlbumTap: (album) {
        Navigator.pushNamed(context, '/album', arguments: album.id);
      },
    );
  }

  // ==================== ARTIST RANKING ====================

  Widget _buildArtistRanking() {
    // Using reusable ArtistCardList component with ranking
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _topArtists.take(7).length,
        itemBuilder: (context, index) {
          final artist = _topArtists[index];
          return ArtistCard(
            artist: artist,
            avatarRadius: 45,
            width: 110,
            showFollowers: true,
            rank: index + 1,
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
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }

  // ==================== NEW RELEASES ====================

  Widget _buildNewReleases() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _newReleases.length,
        itemBuilder: (context, index) {
          final song = _newReleases[index];
          return _buildNewReleaseItem(song, index);
        },
      ),
    );
  }

  Widget _buildNewReleaseItem(Song song, int index) {
    return GestureDetector(
      onTap: () => _onSongTap(song, _newReleases, index),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: song.coverUrl != null
                      ? Image.network(
                          song.coverUrl!,
                          width: 130,
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultCover(),
                        )
                      : _buildDefaultCover(),
                ),
                // "Mới" badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Mới',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Add to playlist button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: AddToPlaylistButton(
                    songId: song.id,
                    songTitle: song.title,
                    song: song,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.allArtists,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== GENRE RANKINGS ====================

  List<Widget> _buildGenreRankings() {
    final widgets = <Widget>[];

    for (final genre in _genres.take(4)) {
      final songs = _rankingsByGenre[genre.name] ?? [];
      if (songs.isEmpty) continue;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _parseColor(genre.color),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Top ${genre.displayName} tuần này',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...songs.take(5).toList().asMap().entries.map((entry) {
                return _buildRankingSongItem(entry.value, entry.key + 1, songs);
              }),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildRankingSongItem(Song song, int rank, List<Song> playlist) {
    return InkWell(
      onTap: () => _onSongTap(song, playlist, rank - 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 32,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: _getRankColor(rank),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: song.coverUrl != null
                  ? Image.network(
                      song.coverUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.music_note,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.music_note,
                        color: AppColors.textMuted,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.allArtists,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Add to playlist button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AddToPlaylistButton(
                songId: song.id,
                songTitle: song.title,
                song: song,
                size: 26,
              ),
            ),
            // Duration thay vì play count
            Text(
              song.formattedDuration,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return AppColors.primary;
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 130,
      height: 130,
      color: AppColors.surface,
      child: const Icon(Icons.music_note, size: 40, color: AppColors.textMuted),
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
        child: AppErrorState(message: _error!, onRetry: _loadData),
      );
    }

    if (_recentlyPlayed.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: AppEmptyState(
          icon: Icons.music_off,
          title: 'Chưa có lịch sử nghe',
          subtitle: 'Bắt đầu nghe nhạc để xem nội dung gần đây.',
        ),
      );
    }

    return Column(
      children: _recentlyPlayed.asMap().entries.map((entry) {
        final index = entry.key;
        final song = entry.value;
        return SongListTile(
          song: song.toPlayerFormat(),
          onTap: () => _onSongTap(song, _recentlyPlayed, index),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      }).toList(),
    );
  }

  // ==================== CREATE PLAYLIST DIALOG ====================

  void _showCreatePlaylistDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    bool isPublic = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.playlist_add_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Tạo Playlist Mới',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Playlist name input
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tên playlist',
                        hintStyle: TextStyle(color: Colors.grey[500]),
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
                        prefixIcon: const Icon(
                          Icons.music_note,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description input
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Mô tả (không bắt buộc)',
                        hintStyle: TextStyle(color: Colors.grey[500]),
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
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(
                            Icons.description_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Public/Private toggle
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPublic ? Icons.public : Icons.lock,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isPublic ? 'Công khai' : 'Riêng tư',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isPublic,
                            onChanged: (value) {
                              setDialogState(() => isPublic = value);
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Hủy', style: TextStyle(color: Colors.grey[400])),
                ),
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Vui lòng nhập tên playlist',
                                ),
                                backgroundColor: Colors.red[700],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }

                          final userId = _authService.currentUserId;
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Vui lòng đăng nhập để tạo playlist',
                                ),
                                backgroundColor: Colors.red[700],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          try {
                            await _supabaseService.createPlaylist(
                              name: nameController.text.trim(),
                              description:
                                  descriptionController.text.trim().isNotEmpty
                                  ? descriptionController.text.trim()
                                  : null,
                              ownerId: userId,
                              isPublic: isPublic,
                            );

                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Đã tạo playlist thành công!',
                                  ),
                                  backgroundColor: Colors.green[700],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isLoading = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi tạo playlist: $e'),
                                  backgroundColor: Colors.red[700],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Tạo',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
