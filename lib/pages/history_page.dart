import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/audio_player_service.dart';
import '../services/queue_service.dart';
import '../services/auth_service.dart';
import '../core/core.dart';
import '../now_playing_page.dart';
import '../components/add_to_playlist_dialog.dart';
import '../components/auto_mini_player.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final QueueService _queueService = QueueService();
  final AuthService _authService = AuthService();

  final ScrollController _scrollController = ScrollController();
  Map<String, List<HistoryItem>> _historyByDate = {};

  // Pagination state
  static const int _pageSize = 20;
  int _currentOffset = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreHistory();
    }
  }

  Future<void> _loadHistory({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentOffset = 0;
        _historyByDate = {};
        _hasMore = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    await _fetchData();
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        setState(() {
          _error = 'Vui lòng đăng nhập để xem lịch sử';
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      final history = await _supabaseService.getListeningHistory(
        userId,
        limit: _pageSize,
        offset: _currentOffset,
      );

      if (history.isEmpty) {
        if (mounted) {
          setState(() {
            _hasMore = false;
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
        return;
      }

      // Group by date
      // We need to merge with existing data
      final Map<String, List<HistoryItem>> currentGrouped = Map.from(
        _historyByDate,
      );

      for (final item in history) {
        final historyItem = HistoryItem.fromJson(item);
        final dateKey = _formatDateKey(historyItem.listenedAt);

        if (!currentGrouped.containsKey(dateKey)) {
          currentGrouped[dateKey] = [];
        }

        // Check for duplicates (should rarely happen with distinct pagination unless data changes)
        final exists = currentGrouped[dateKey]!.any(
          (h) =>
              h.song.id == historyItem.song.id &&
              h.listenedAt.difference(historyItem.listenedAt).abs().inSeconds <
                  2,
        );
        if (!exists) {
          currentGrouped[dateKey]!.add(historyItem);
        }
      }

      if (mounted) {
        setState(() {
          _historyByDate = currentGrouped;
          _currentOffset += history.length;
          _hasMore = history.length >= _pageSize;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  String _formatDateKey(DateTime date) {
    // Convert to Vietnam timezone (UTC+7)
    final vietnamTime = date.toUtc().add(const Duration(hours: 7));
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(
      vietnamTime.year,
      vietnamTime.month,
      vietnamTime.day,
    );

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == yesterday) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd/MM/yyyy').format(vietnamTime);
    }
  }

  void _playSong(Song song) {
    // Only add this single song to queue
    _queueService.replaceQueue([song], startIndex: 0);
    _audioService.setPlaylist([song.toPlayerFormat()], 0);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NowPlayingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch sử nghe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _loadHistory(refresh: true),
          ),
        ],
      ),
      body: Stack(children: [_buildBody(), const AutoMiniPlayer()]),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingPage(message: 'Đang tải lịch sử nghe...');
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_historyByDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử nghe',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu nghe nhạc để xem lịch sử tại đây',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadHistory(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: _historyByDate.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _historyByDate.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final dateKey = _historyByDate.keys.elementAt(index);
          final items = _historyByDate[dateKey]!;
          return _buildDateSection(dateKey, items);
        },
      ),
    );
  }

  Widget _buildDateSection(String dateKey, List<HistoryItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            dateKey,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => _buildHistoryItem(item)),
        const Divider(color: Colors.grey, height: 1),
      ],
    );
  }

  Widget _buildHistoryItem(HistoryItem item) {
    final song = item.song;

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: song.coverUrl != null
            ? Image.network(
                song.coverUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultCover(),
              )
            : _buildDefaultCover(),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.allArtists,
        style: TextStyle(color: Colors.grey[400]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white70),
            iconSize: 22,
            onPressed: () => _showSongOptions(song),
          ),
          Text(
            DateFormat(
              'HH:mm',
            ).format(item.listenedAt.toUtc().add(const Duration(hours: 7))),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
      onTap: () => _playSong(song),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey[800],
      child: const Icon(Icons.music_note, color: Colors.white),
    );
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SongOptionsSheet(
        song: song,
        onAddToQueue: () {
          _queueService.addToQueue(song);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm "${song.title}" vào hàng đợi'),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onPlayNext: () {
          _queueService.addToPlayNext(song);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sẽ phát "${song.title}" tiếp theo'),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onAddToPlaylist: () {
          Navigator.pop(context);
          AddToPlaylistDialog.show(context, song.id, song.title, song: song);
        },
      ),
    );
  }
}

// ==================== HISTORY ITEM MODEL ====================

class HistoryItem {
  final Song song;
  final DateTime listenedAt;
  final int durationPlayed;
  final bool completed;

  HistoryItem({
    required this.song,
    required this.listenedAt,
    this.durationPlayed = 0,
    this.completed = false,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      song: Song.fromJson(json['song'] ?? json),
      listenedAt: DateTime.parse(
        json['listened_at'] ?? DateTime.now().toIso8601String(),
      ),
      durationPlayed: json['duration_played'] ?? 0,
      completed: json['completed'] ?? false,
    );
  }
}

// ==================== SONG OPTIONS SHEET ====================

class SongOptionsSheet extends StatelessWidget {
  final Song song;
  final VoidCallback onAddToQueue;
  final VoidCallback onPlayNext;
  final VoidCallback onAddToPlaylist;

  const SongOptionsSheet({
    super.key,
    required this.song,
    required this.onAddToQueue,
    required this.onPlayNext,
    required this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Song info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: song.coverUrl != null
                      ? Image.network(
                          song.coverUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.allArtists,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.grey, height: 1),

          // Options
          _buildOption(
            icon: Icons.playlist_add,
            label: 'Thêm vào hàng đợi',
            onTap: onAddToQueue,
          ),
          _buildOption(
            icon: Icons.queue_music,
            label: 'Phát tiếp theo',
            onTap: onPlayNext,
          ),
          _buildOption(
            icon: Icons.playlist_add_check,
            label: 'Thêm vào playlist',
            onTap: onAddToPlaylist,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
