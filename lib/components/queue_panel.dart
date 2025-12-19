import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/queue_service.dart';
import '../core/core.dart';

class QueuePanel extends StatefulWidget {
  const QueuePanel({super.key});

  @override
  State<QueuePanel> createState() => _QueuePanelState();
}

class _QueuePanelState extends State<QueuePanel> {
  final QueueService _queueService = QueueService();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              Expanded(
                child: _buildQueueList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textMuted,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hàng đợi phát',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Shuffle toggle
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: _queueService.isShuffleEnabled 
                  ? AppColors.primary 
                  : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _queueService.toggleShuffle();
              });
            },
          ),
          // Clear queue
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text(
                    'Xóa hàng đợi?',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  content: const Text(
                    'Tất cả bài hát trong hàng đợi sẽ bị xóa.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        _queueService.clearQueue();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Xóa',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(ScrollController scrollController) {
    final queue = _queueService.queue;
    final currentIndex = _queueService.currentIndex;

    if (queue.isEmpty) {
      return const Center(
        child: AppEmptyState(
          icon: Icons.queue_music,
          title: 'Hàng đợi trống',
          subtitle: 'Thêm bài hát để bắt đầu nghe',
        ),
      );
    }

    return ReorderableListView.builder(
      scrollController: scrollController,
      itemCount: queue.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          _queueService.reorderQueue(oldIndex, newIndex);
        });
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 2,
              color: AppColors.surface,
              shadowColor: Colors.black45,
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final song = queue[index];
        final isCurrentSong = index == currentIndex;

        return _buildQueueItem(
          key: ValueKey(song.id),
          song: song,
          index: index,
          isCurrentSong: isCurrentSong,
        );
      },
    );
  }

  Widget _buildQueueItem({
    required Key key,
    required Song song,
    required int index,
    required bool isCurrentSong,
  }) {
    return Container(
      key: key,
      color: isCurrentSong ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Stack(
          children: [
            ClipRRect(
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
            if (isCurrentSong)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.equalizer,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          song.title,
          style: TextStyle(
            color: isCurrentSong ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.w500,
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
            if (!isCurrentSong)
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                onPressed: () {
                  setState(() {
                    _queueService.removeFromQueue(index);
                  });
                },
              ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: AppColors.textMuted),
            ),
          ],
        ),
        onTap: () {
          _queueService.jumpToIndex(index);
          Navigator.pop(context, true); // Return true to indicate song was selected
        },
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.surface,
      child: const Icon(Icons.music_note, color: AppColors.textMuted),
    );
  }
}

/// Show queue panel as a modal bottom sheet
Future<bool?> showQueuePanel(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const QueuePanel(),
  );
}
