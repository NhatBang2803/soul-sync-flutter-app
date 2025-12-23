import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'services/supabase_service.dart';
import 'services/audio_player_service.dart';
import 'services/auth_service.dart';
import 'models/models.dart';
import 'now_playing_page.dart';
import 'core/core.dart';
import 'pages/playlist_page.dart';
import 'pages/album_page.dart';

class LibraryPage extends StatefulWidget {
  final Function(int)? onTabChanged;

  const LibraryPage({super.key, this.onTabChanged});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final AuthService _authService = AuthService();

  int _activeFilterIndex =
      0; // 0=all, 1=playlists, 2=albums (liked), 3=songs (liked)

  List<Playlist> _playlists = [];
  List<Song> _likedSongs = [];
  List<Album> _likedAlbums = [];
  bool _isLoading = true;
  String? _error;

  static const _filterLabels = [
    AppStrings.all,
    AppStrings.playlist,
    AppStrings.album,
    'Bài hát',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Lấy user ID hiện tại, nếu không đăng nhập thì trả về danh sách rỗng
      final userId = _authService.currentUserId;

      final results = await Future.wait([
        // Chỉ lấy playlist của người dùng đang đăng nhập
        userId != null
            ? _supabaseService.getUserPlaylists(userId)
            : Future.value(<Map<String, dynamic>>[]),
        // Lấy bài hát đã yêu thích của user
        userId != null
            ? _supabaseService.getLikedSongs(userId)
            : Future.value(<Map<String, dynamic>>[]),
        // Lấy album đã yêu thích của user
        userId != null
            ? _supabaseService.getLikedAlbums(userId)
            : Future.value(<Map<String, dynamic>>[]),
      ]);

      if (mounted) {
        setState(() {
          _playlists = (results[0] as List)
              .map((json) => Playlist.fromJson(json))
              .toList();
          _likedSongs = (results[1] as List)
              .map((json) => Song.fromJson(json))
              .toList();
          _likedAlbums = (results[2] as List)
              .map((json) => Album.fromJson(json))
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

  void _onSongTap(Song song, int index) async {
    final playlist = _likedSongs.map((s) => s.toPlayerFormat()).toList();
    await _audioService.setPlaylist(playlist, index);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NowPlayingPage()),
      );
    }
  }

  Future<void> _unlikeSong(Song song) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      await _supabaseService.unlikeSong(userId, song.id);
      if (mounted) {
        setState(() {
          _likedSongs.removeWhere((s) => s.id == song.id);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _unlikeAlbum(Album album) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      await _supabaseService.unlikeAlbum(userId, album.id);
      if (mounted) {
        setState(() {
          _likedAlbums.removeWhere((a) => a.id == album.id);
        });
      }
    } catch (e) {
      // Handle error silently
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
            _buildFilterPills(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        onItemTapped: widget.onTabChanged ?? (index) {},
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.yourLibrary,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary, size: 28),
            onPressed: () => _showCreatePlaylistDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    return AppFilterChipRow(
      labels: _filterLabels,
      selectedIndex: _activeFilterIndex,
      onSelected: (index) {
        setState(() => _activeFilterIndex = index);
      },
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const AppLoadingPage(message: 'Đang tải thư viện...');
    }

    if (_error != null) {
      return AppErrorState(message: _error!, onRetry: _loadData);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Show cards only in "All" view
          if (_activeFilterIndex == 0) _buildLikedSongsCard(),
          if (_activeFilterIndex == 0) _buildLikedAlbumsCard(),
          // Playlists section
          if (_activeFilterIndex == 0 || _activeFilterIndex == 1)
            _buildPlaylistsSection(),
          // Liked albums section (filter 2 = Album)
          if (_activeFilterIndex == 0 || _activeFilterIndex == 2)
            _buildLikedAlbumsSection(),
          // Liked songs section (filter 3 = Bài hát)
          if (_activeFilterIndex == 0 || _activeFilterIndex == 3)
            _buildLikedSongsSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLikedSongsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.purpleGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(
              () => _activeFilterIndex = 3,
            ), // Navigate to Bài hát filter
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.textPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.likedSongs,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_likedSongs.length} bài hát',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.queue_music, color: AppColors.textMuted, size: 20),
              SizedBox(width: 8),
              Text(
                AppStrings.myPlaylists,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                AppStrings.noPlaylist,
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ..._playlists.map(_buildPlaylistItem),
        ],
      ),
    );
  }

  Widget _buildPlaylistItem(Playlist playlist) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistPage(playlistId: playlist.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            AppImage.playlist(url: playlist.coverUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
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
                    '${AppStrings.playlist} • ${playlist.songCount} bài hát',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedAlbumsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.album, color: AppColors.textMuted, size: 20),
              SizedBox(width: 8),
              Text(
                'Album yêu thích',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_likedAlbums.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Chưa có album yêu thích',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ..._likedAlbums.map(_buildAlbumItem),
        ],
      ),
    );
  }

  Widget _buildAlbumItem(Album album) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlbumPage(albumId: album.id)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            AppImage.album(url: album.coverUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
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
                    '${AppStrings.album} • ${album.artist}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
              onPressed: () => _unlikeAlbum(album),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedSongsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.likedSongs,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_likedSongs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                AppStrings.noSong,
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ..._likedSongs.asMap().entries.map((entry) {
              final index = entry.key;
              final song = entry.value;
              return LikedSongListTile(
                song: song.toPlayerFormat(),
                isLiked: true,
                onTap: () => _onSongTap(song, index),
                onLikeTap: () => _unlikeSong(song),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLikedAlbumsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEC4899), Color(0xFFF97316)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(
              () => _activeFilterIndex = 2,
            ), // Navigate to Album filter
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.album,
                      color: AppColors.textPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Album yêu thích',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_likedAlbums.length} album',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                              // Reload data to show new playlist
                              _loadData();
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
