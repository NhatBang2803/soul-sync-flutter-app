import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../services/queue_service.dart';
import '../models/models.dart';
import '../core/constants/app_colors.dart';

/// Widget hiển thị dialog để thêm bài hát vào playlist
class AddToPlaylistDialog extends StatefulWidget {
  final String songId;
  final String songTitle;
  final Song? song; // Optional full song object for queue operations

  const AddToPlaylistDialog({
    super.key,
    required this.songId,
    required this.songTitle,
    this.song,
  });

  @override
  State<AddToPlaylistDialog> createState() => _AddToPlaylistDialogState();

  /// Hiển thị dialog để thêm bài hát vào playlist
  static Future<void> show(
    BuildContext context,
    String songId,
    String songTitle, {
    Song? song,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          AddToPlaylistDialog(songId: songId, songTitle: songTitle, song: song),
    );
  }
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final QueueService _queueService = QueueService();

  List<Playlist> _playlists = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      setState(() {
        _error = 'Vui lòng đăng nhập để thêm vào playlist';
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await _supabaseService.getUserPlaylists(userId);
      if (mounted) {
        setState(() {
          _playlists = data.map((json) => Playlist.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Không thể tải danh sách playlist';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addToPlaylist(Playlist playlist) async {
    try {
      await _supabaseService.addSongToPlaylist(playlist.id, widget.songId);

      if (mounted) {
        // Đóng bottom sheet trước
        Navigator.of(context).pop();

        // Sau đó hiển thị snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm vào "${playlist.name}"'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final isDuplicate =
            e.toString().contains('duplicate') ||
            e.toString().contains('unique constraint');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDuplicate
                  ? 'Bài hát đã có trong playlist này'
                  : 'Lỗi: ${e.toString()}',
            ),
            backgroundColor: isDuplicate ? Colors.orange[700] : Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _addToQueue() {
    if (widget.song == null) return;
    
    _queueService.addToQueue(widget.song!);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${widget.songTitle}" vào hàng đợi'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToPlayNext() {
    if (widget.song == null) return;
    
    _queueService.addToPlayNext(widget.song!);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${widget.songTitle}" để phát tiếp theo'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    final TextEditingController nameController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Tạo Playlist Mới',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: TextField(
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
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: isCreating
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) return;

                          final userId = _authService.currentUserId;
                          if (userId == null) return;

                          setDialogState(() => isCreating = true);

                          try {
                            final newPlaylist = await _supabaseService
                                .createPlaylist(
                                  name: nameController.text.trim(),
                                  ownerId: userId,
                                );

                            // Add song to the new playlist
                            await _supabaseService.addSongToPlaylist(
                              newPlaylist['id'],
                              widget.songId,
                            );

                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).pop(); // Close bottom sheet

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã tạo "${nameController.text.trim()}" và thêm bài hát',
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
                            setDialogState(() => isCreating = false);
                          }
                        },
                  child: isCreating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Text(
                          'Tạo & Thêm',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Thêm bài hát',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.songTitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          
          // Queue options (only show if song object is available)
          if (widget.song != null) ...[
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.playlist_add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: const Text(
                'Thêm vào hàng đợi',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Phát sau các bài hiện tại',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              onTap: () => _addToQueue(),
            ),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.queue_music,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: const Text(
                'Phát tiếp theo',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Phát ngay sau bài hiện tại',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              onTap: () => _addToPlayNext(),
            ),
            const Divider(color: Colors.grey, height: 1),
          ],
          
          // Create new playlist button
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),
            title: const Text(
              'Tạo Playlist Mới',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: _showCreatePlaylistDialog,
          ),
          const Divider(color: Colors.grey, height: 1),
          // Playlist list
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _playlists.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.queue_music,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bạn chưa có playlist nào',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = _playlists[index];

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: playlist.coverUrl != null
                              ? Image.network(
                                  playlist.coverUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildDefaultCover(),
                                )
                              : _buildDefaultCover(),
                        ),
                        title: Text(
                          playlist.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${playlist.songCount} bài hát',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        trailing: Icon(
                          playlist.isPublic ? Icons.public : Icons.lock,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        onTap: () => _addToPlaylist(playlist),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.purpleGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.queue_music, color: Colors.white70, size: 24),
    );
  }
}

/// Widget nút cộng tròn để thêm bài hát vào playlist
class AddToPlaylistButton extends StatelessWidget {
  final String songId;
  final String songTitle;
  final Song? song;
  final double size;

  const AddToPlaylistButton({
    super.key,
    required this.songId,
    required this.songTitle,
    this.song,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AddToPlaylistDialog.show(context, songId, songTitle, song: song),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Icon(
          Icons.add_rounded,
          color: AppColors.primary,
          size: size * 0.7,
        ),
      ),
    );
  }
}
