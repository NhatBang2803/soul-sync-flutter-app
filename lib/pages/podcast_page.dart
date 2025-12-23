import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/audio_player_service.dart';
import '../services/queue_service.dart';
import '../services/auth_service.dart';
import '../core/core.dart';
import '../now_playing_page.dart';
import '../components/episode_list_item.dart';

/// Podcast detail page - shows podcast info and episodes
/// Similar to AlbumPage pattern for consistency
class PodcastPage extends StatefulWidget {
  final String podcastId;

  const PodcastPage({super.key, required this.podcastId});

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final QueueService _queueService = QueueService();
  final AuthService _authService = AuthService();

  Podcast? _podcast;
  List<PodcastEpisode> _episodes = [];
  bool _isLoading = true;
  bool _isSaved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPodcast();
  }

  Future<void> _loadPodcast() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _supabaseService.getPodcastById(widget.podcastId),
        _supabaseService.getPodcastEpisodes(widget.podcastId),
      ]);

      if (mounted) {
        setState(() {
          if (results[0] != null) {
            _podcast = Podcast.fromJson(results[0] as Map<String, dynamic>);
          }
          _episodes = (results[1] as List)
              .map((json) => PodcastEpisode.fromJson(json))
              .toList();
          _isLoading = false;
        });
        _checkIfSaved();
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

  Future<void> _checkIfSaved() async {
    final userId = _authService.currentUserId;
    if (userId == null || _podcast == null) return;

    final isSaved = await _supabaseService.isPodcastSaved(userId, _podcast!.id);
    if (mounted) {
      setState(() => _isSaved = isSaved);
    }
  }

  Future<void> _toggleSave() async {
    final userId = _authService.currentUserId;
    if (userId == null || _podcast == null) return;

    try {
      if (_isSaved) {
        await _supabaseService.unsavePodcast(userId, _podcast!.id);
      } else {
        await _supabaseService.savePodcast(userId, _podcast!.id);
      }
      if (mounted) {
        setState(() => _isSaved = !_isSaved);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Đã lưu podcast' : 'Đã bỏ lưu podcast'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra')));
      }
    }
  }

  void _playEpisode(PodcastEpisode episode, int index) {
    // Convert episodes to player format
    final playlist = _episodes.map((e) => e.toPlayerFormat()).toList();

    _queueService.replaceQueue(
      _episodes
          .map(
            (e) => Song(
              id: e.id,
              title: e.title,
              artistNames: [e.hostName ?? 'Unknown Host'],
              artistIds: [],
              duration: e.duration,
              coverUrl: e.podcastImage,
              audioUrl: e.audioUrl,
            ),
          )
          .toList(),
      startIndex: index,
    );

    _audioService.setPlaylist(playlist, index);

    // Record listening
    final userId = _authService.currentUserId;
    if (userId != null) {
      _supabaseService.recordPodcastListening(
        userId: userId,
        episodeId: episode.id,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NowPlayingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: AppLoadingIndicator())
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Không thể tải podcast',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadPodcast, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_podcast == null) {
      return const Center(
        child: Text(
          'Không tìm thấy podcast',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(child: _buildPodcastInfo()),
        SliverToBoxAdapter(child: _buildPlayButton()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '${_episodes.length} tập',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _buildEpisodesList(),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_podcast?.imageUrl != null)
              Image.network(
                _podcast!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultCover(),
              )
            else
              _buildDefaultCover(),
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
      child: const Icon(Icons.podcasts, size: 80, color: AppColors.textMuted),
    );
  }

  Widget _buildPodcastInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _podcast!.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Host name
          Text(
            _podcast!.hostName,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Stats
          Row(
            children: [
              Icon(Icons.podcasts, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${_podcast!.episodeCount} tập',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Icon(Icons.play_arrow, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${_podcast!.totalPlays} lượt nghe',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
          // Description
          if (_podcast!.description != null) ...[
            const SizedBox(height: 12),
            Text(
              _podcast!.description!,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Save button
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: _toggleSave,
            iconSize: 28,
          ),
          const Spacer(),
          // Play all button
          ElevatedButton.icon(
            onPressed: _episodes.isNotEmpty
                ? () => _playEpisode(_episodes.first, 0)
                : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Phát tập mới nhất'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesList() {
    if (_episodes.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Chưa có tập nào',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final episode = _episodes[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CompactEpisodeItem(
            episode: episode,
            index: index,
            onTap: () => _playEpisode(episode, index),
          ),
        );
      }, childCount: _episodes.length),
    );
  }
}
