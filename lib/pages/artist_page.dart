import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/audio_player_service.dart';
import '../services/queue_service.dart';
import '../services/auth_service.dart';
import '../core/core.dart';
import '../now_playing_page.dart';
import '../components/add_to_playlist_dialog.dart';
import 'album_page.dart';

class ArtistPage extends StatefulWidget {
  final String artistId;

  const ArtistPage({super.key, required this.artistId});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final QueueService _queueService = QueueService();
  final AuthService _authService = AuthService();

  Artist? _artist;
  List<Song> _topSongs = [];
  List<Album> _albums = [];
  List<Song> _featuringSongs = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArtist();
  }

  Future<void> _loadArtist() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _supabaseService.getArtistById(widget.artistId),
        _supabaseService.getArtistTopSongs(widget.artistId, limit: 5),
        _supabaseService.getAlbumsByArtist(widget.artistId),
        _supabaseService.getArtistFeaturing(widget.artistId),
      ]);

      // Check follow status
      bool isFollowing = false;
      final userId = _authService.currentUserId;
      if (userId != null) {
        isFollowing = await _supabaseService.isFollowingArtist(
          userId,
          widget.artistId,
        );
      }

      if (mounted) {
        setState(() {
          if (results[0] != null) {
            _artist = Artist.fromJson(results[0] as Map<String, dynamic>);
          }
          _topSongs = (results[1] as List)
              .map((json) => Song.fromJson(json))
              .toList();
          _albums = (results[2] as List)
              .map((json) => Album.fromJson(json))
              .toList();
          _featuringSongs = (results[3] as List)
              .map((json) => Song.fromJson(json))
              .toList();
          _isFollowing = isFollowing;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để theo dõi nghệ sĩ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (_isFollowing) {
        await _supabaseService.unfollowArtist(userId, widget.artistId);
      } else {
        await _supabaseService.followArtist(userId, widget.artistId);
      }

      setState(() => _isFollowing = !_isFollowing);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _playSong(Song song, List<Song> playlist, int index) {
    _queueService.replaceQueue(playlist, startIndex: index);
    final playerPlaylist = playlist.map((s) => s.toPlayerFormat()).toList();
    _audioService.setPlaylist(playerPlaylist, index);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NowPlayingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: AppLoadingPage(message: 'Đang tải thông tin nghệ sĩ...'),
      );
    }

    if (_error != null || _artist == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: AppErrorState(
          message: _error ?? 'Không tìm thấy nghệ sĩ',
          onRetry: _loadArtist,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildArtistInfo()),
          if (_topSongs.isNotEmpty)
            SliverToBoxAdapter(child: _buildTopSongsSection()),
          if (_albums.isNotEmpty)
            SliverToBoxAdapter(child: _buildAlbumsSection()),
          if (_featuringSongs.isNotEmpty)
            SliverToBoxAdapter(child: _buildFeaturingSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Artist image
            _artist!.imageUrl != null
                ? Image.network(
                    _artist!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultImage(),
                  )
                : _buildDefaultImage(),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 80, color: Colors.white70),
      ),
    );
  }

  Widget _buildArtistInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Artist name with verified badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _artist!.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_artist!.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.verified,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Monthly listeners
                    Text(
                      _artist!.formattedMonthlyListeners,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Follow button
              ElevatedButton(
                onPressed: _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing
                      ? AppColors.surface
                      : AppColors.primary,
                  foregroundColor: _isFollowing
                      ? AppColors.textPrimary
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  _isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          // Bio
          if (_artist!.bio != null && _artist!.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _artist!.bio!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopSongsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bài hát được nghe nhiều nhất',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_topSongs.length, (index) {
            final song = _topSongs[index];
            return _buildSongItem(song, index, _topSongs);
          }),
        ],
      ),
    );
  }

  Widget _buildSongItem(Song song, int index, List<Song> playlist) {
    return InkWell(
      onTap: () => _playSong(song, playlist, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 32,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${song.playCount} lượt nghe',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Add to playlist button
            AddToPlaylistButton(
              songId: song.id,
              songTitle: song.title,
              size: 26,
            ),
            const SizedBox(width: 8),
            // Duration
            Text(
              song.formattedDuration,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Album',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full album list
                  _showAllAlbums();
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _albums.take(5).length,
            itemBuilder: (context, index) {
              final album = _albums[index];
              return _buildAlbumItem(album);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumItem(Album album) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlbumPage(albumId: album.id)),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: album.coverUrl != null
                  ? Image.network(
                      album.coverUrl!,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 140,
                        height: 140,
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.album,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : Container(
                      width: 140,
                      height: 140,
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.album,
                        color: AppColors.textMuted,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              album.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.year?.toString() ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturingSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featuring',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Các bài hát có sự tham gia của nghệ sĩ khác',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...List.generate(_featuringSongs.take(5).length, (index) {
            final song = _featuringSongs[index];
            return _buildFeaturingSongItem(song, index);
          }),
        ],
      ),
    );
  }

  Widget _buildFeaturingSongItem(Song song, int index) {
    return InkWell(
      onTap: () => _playSong(song, _featuringSongs, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
            AddToPlaylistButton(
              songId: song.id,
              songTitle: song.title,
              size: 26,
            ),
            const SizedBox(width: 4),
            // Play button
            IconButton(
              icon: const Icon(
                Icons.play_circle_outline,
                color: AppColors.primary,
              ),
              onPressed: () => _playSong(song, _featuringSongs, index),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllAlbums() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tất cả album',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Album list with songs
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _albums.length,
                itemBuilder: (context, index) {
                  final album = _albums[index];
                  return _buildAlbumWithSongs(album);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumWithSongs(Album album) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _supabaseService.getSongsByAlbum(album.id),
      builder: (context, snapshot) {
        final songs =
            snapshot.data?.map((json) => Song.fromJson(json)).toList() ?? [];

        return ExpansionTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: album.coverUrl != null
                ? Image.network(
                    album.coverUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surface,
                    child: const Icon(Icons.album, color: AppColors.textMuted),
                  ),
          ),
          title: Text(
            album.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${album.year} • ${songs.length} bài hát',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          children: songs.asMap().entries.map((entry) {
            final index = entry.key;
            final song = entry.value;
            return ListTile(
              contentPadding: const EdgeInsets.only(left: 72, right: 16),
              title: Text(
                song.title,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                song.formattedDuration,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow, color: AppColors.primary),
                onPressed: () {
                  Navigator.pop(context);
                  _playSong(song, songs, index);
                },
              ),
              onTap: () {
                Navigator.pop(context);
                _playSong(song, songs, index);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
