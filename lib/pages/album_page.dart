import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/audio_player_service.dart';
import '../services/queue_service.dart';
import '../core/core.dart';
import '../now_playing_page.dart';
import '../components/add_to_playlist_dialog.dart';

class AlbumPage extends StatefulWidget {
  final String albumId;

  const AlbumPage({super.key, required this.albumId});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final QueueService _queueService = QueueService();

  Album? _album;
  List<Song> _songs = [];
  List<Album> _suggestedAlbums = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlbum();
  }

  Future<void> _loadAlbum() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _supabaseService.getAlbumById(widget.albumId),
        _supabaseService.getSongsByAlbum(widget.albumId),
        _supabaseService.getRandomAlbums(6),
      ]);

      if (mounted) {
        setState(() {
          if (results[0] != null) {
            _album = Album.fromJson(results[0] as Map<String, dynamic>);
          }
          _songs = (results[1] as List)
              .map((json) => Song.fromJson(json))
              .toList();
          _suggestedAlbums = (results[2] as List)
              .map((json) => Album.fromJson(json))
              .where((a) => a.id != widget.albumId)
              .take(5)
              .toList();
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

  void _playAlbum({int startIndex = 0}) {
    if (_songs.isEmpty) return;

    // Replace queue with album songs
    _queueService.replaceQueue(_songs, startIndex: startIndex);

    // Play first song
    final playlist = _songs.map((s) => s.toPlayerFormat()).toList();
    _audioService.setPlaylist(playlist, startIndex);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NowPlayingPage()),
    );
  }

  void _onSongTap(Song song, int index) {
    _playAlbum(startIndex: index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: AppLoadingPage(message: 'Đang tải album...'),
      );
    }

    if (_error != null || _album == null) {
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
          message: _error ?? 'Không tìm thấy album',
          onRetry: _loadAlbum,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildAlbumInfo()),
          SliverToBoxAdapter(child: _buildPlayButton()),
          SliverToBoxAdapter(child: _buildSongsList()),
          if (_suggestedAlbums.isNotEmpty)
            SliverToBoxAdapter(child: _buildSuggestedAlbums()),
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
            // Album cover
            _album!.coverUrl != null
                ? Image.network(
                    _album!.coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultCover(),
                  )
                : _buildDefaultCover(),
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

  Widget _buildDefaultCover() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.album, size: 80, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildAlbumInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album name
          Text(
            _album!.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Artist name
          Text(
            _album!.artist,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Meta info row
          Wrap(
            spacing: 16,
            children: [
              // Privacy status (only show for owner)
              if (!_album!.isPublic)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Riêng tư',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              // Listen count
              Text(
                _album!.formattedListenCount,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              // Release year
              if (_album!.year != null)
                Text(
                  '${_album!.year}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              // Song count
              Text(
                '${_songs.length} bài hát',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _playAlbum(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Phát tất cả'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.shuffle, color: AppColors.textPrimary),
            onPressed: () {
              _queueService.setShuffle(true);
              _playAlbum();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ...List.generate(_songs.length, (index) {
            final song = _songs[index];
            return _buildSongItem(song, index);
          }),
        ],
      ),
    );
  }

  Widget _buildSongItem(Song song, int index) {
    return InkWell(
      onTap: () => _onSongTap(song, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Track number
            SizedBox(
              width: 32,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
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
            const SizedBox(width: 8),
            // Duration
            Text(
              song.formattedDuration,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            // More button
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onPressed: () {
                // Show song options
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedAlbums() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Album tương tự',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _suggestedAlbums.length,
            itemBuilder: (context, index) {
              final album = _suggestedAlbums[index];
              return _buildSuggestedAlbumItem(album);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedAlbumItem(Album album) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
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
            // Cover
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
            // Name
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
            // Artist
            Text(
              album.artist,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
