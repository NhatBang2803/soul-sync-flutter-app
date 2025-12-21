import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/audio_player_service.dart';
import '../services/queue_service.dart';
import '../core/core.dart';
import '../now_playing_page.dart';
import '../components/add_to_playlist_dialog.dart';

class PlaylistPage extends StatefulWidget {
  final String playlistId;

  const PlaylistPage({super.key, required this.playlistId});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final QueueService _queueService = QueueService();

  Playlist? _playlist;
  List<Song> _songs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await _supabaseService.getPlaylistWithSongs(
        widget.playlistId,
      );

      if (mounted && result != null) {
        setState(() {
          _playlist = Playlist.fromJson(result);
          _songs = (result['songs'] as List? ?? [])
              .map((json) => Song.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Không tìm thấy playlist';
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

  void _playPlaylist({int startIndex = 0}) {
    if (_songs.isEmpty) return;

    // Replace queue with playlist songs
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
    _playPlaylist(startIndex: index);
  }

  String _formatTotalPlayCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M lượt nghe';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K lượt nghe';
    }
    return '$count lượt nghe';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: AppLoadingPage(message: 'Đang tải playlist...'),
      );
    }

    if (_error != null || _playlist == null) {
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
          message: _error ?? 'Không tìm thấy playlist',
          onRetry: _loadPlaylist,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildPlaylistInfo()),
          SliverToBoxAdapter(child: _buildPlayButton()),
          SliverToBoxAdapter(child: _buildSongsList()),
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
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          ),
          onPressed: () {
            // Show playlist options
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Playlist cover
            _playlist!.coverUrl != null
                ? Image.network(
                    _playlist!.coverUrl!,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.purpleGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.queue_music, size: 80, color: Colors.white70),
      ),
    );
  }

  Widget _buildPlaylistInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playlist name
          Text(
            _playlist!.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          if (_playlist!.description != null &&
              _playlist!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _playlist!.description!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Meta info row
          Wrap(
            spacing: 16,
            children: [
              // Privacy status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _playlist!.isPublic
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _playlist!.isPublic ? Icons.public : Icons.lock,
                      size: 14,
                      color: _playlist!.isPublic
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _playlist!.isPublic ? 'Công khai' : 'Riêng tư',
                      style: TextStyle(
                        color: _playlist!.isPublic
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Listen count (sum of all songs' play counts)
              Text(
                _formatTotalPlayCount(
                  _songs.fold(0, (sum, s) => sum + s.playCount),
                ),
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
              // Created date
              if (_playlist!.createdAt != null)
                Text(
                  'Tạo ngày ${_playlist!.formattedCreatedDate}',
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
              onPressed: _songs.isEmpty ? null : () => _playPlaylist(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Phát tất cả'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                disabledBackgroundColor: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.shuffle, color: AppColors.textPrimary),
            onPressed: _songs.isEmpty
                ? null
                : () {
                    _queueService.setShuffle(true);
                    _playPlaylist();
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    if (_songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: AppEmptyState(
          icon: Icons.music_off,
          title: 'Playlist trống',
          subtitle: 'Thêm bài hát vào playlist này',
        ),
      );
    }

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
            // Cover image
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
                          size: 24,
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
                        size: 24,
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
            // Add to another playlist button
            AddToPlaylistButton(
              songId: song.id,
              songTitle: song.title,
              song: song,
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
}
