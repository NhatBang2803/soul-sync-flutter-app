import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'components/bottom_nav_bar.dart';
import 'components/add_to_playlist_dialog.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'models/models.dart';
import 'models/user.dart' as app_user;
import 'core/core.dart';
import 'pages/artist_page.dart';
import 'pages/album_page.dart';
import 'pages/history_page.dart';
import 'pages/artist_follow_page.dart';

class ProfilePage extends StatefulWidget {
  final Function(int)? onTabChanged;

  const ProfilePage({super.key, this.onTabChanged});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  app_user.User? _userProfile;
  List<Song> _recentlyPlayed = [];
  List<Artist> _followingArtists = [];
  List<Album> _recentAlbums = [];
  bool _isLoading = true;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userId = _authService.currentUserId;

      if (userId != null) {
        // Load user profile first
        final userProfile = await _authService.getUserProfile(userId);

        final results = await Future.wait([
          _supabaseService.getListeningHistory(userId, limit: 10),
          _supabaseService.getFollowingArtists(userId),
          _supabaseService.getRecentlyPlayedAlbums(userId, limit: 10),
        ]);

        if (mounted) {
          setState(() {
            _userProfile = userProfile;
            // Extract songs from listening history and deduplicate by song ID
            final seenSongIds = <String>{};
            _recentlyPlayed = (results[0] as List)
                .map(
                  (item) => Song.fromJson(item['song'] as Map<String, dynamic>),
                )
                .where((song) {
                  // Keep only first occurrence of each song (most recent listen)
                  if (seenSongIds.contains(song.id)) {
                    return false;
                  }
                  seenSongIds.add(song.id);
                  return true;
                })
                .toList();
            _followingArtists = (results[1] as List)
                .map((json) => Artist.fromJson(json))
                .toList();
            _recentAlbums = (results[2] as List)
                .map((json) => Album.fromJson(json))
                .toList();
            _isLoading = false;
          });
        }
      } else {
        // Not logged in - show empty state
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading profile data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==================== AVATAR METHODS ====================

  void _showAvatarOptions() {
    final hasAvatar =
        _userProfile?.avatarUrl != null && _userProfile!.avatarUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Thay đổi ảnh đại diện',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23DD5B).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF23DD5B),
                  ),
                ),
                title: const Text(
                  'Chọn từ thư viện',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C9FF).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF00C9FF)),
                ),
                title: const Text(
                  'Chụp ảnh mới',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar(ImageSource.camera);
                },
              ),
              if (hasAvatar)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text(
                    'Xóa ảnh đại diện',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeAvatar();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingAvatar = true);

      final file = File(pickedFile.path);
      final avatarUrl = await _authService.uploadAvatar(file);

      if (avatarUrl != null) {
        final result = await _authService.updateProfile(avatarUrl: avatarUrl);

        if (result.success && mounted) {
          setState(() {
            _userProfile = result.user;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cập nhật ảnh đại diện thành công!'),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _isUploadingAvatar = true);

    try {
      final result = await _authService.removeAvatar();

      if (result.success && mounted) {
        // Reload profile to get updated data
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã xóa ảnh đại diện'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Xóa ảnh thất bại'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const AppLoadingIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildProfileInfo(),
                    const SizedBox(height: 32),
                    _buildRecentlyPlayedSection(),
                    const SizedBox(height: 24),
                    _buildFollowingArtistsSection(),
                    const SizedBox(height: 24),
                    _buildRecentAlbumsSection(),
                    const SizedBox(height: 28),
                    _buildLogoutSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3,
        onItemTapped: widget.onTabChanged ?? (index) {},
      ),
    );
  }

  void _showEditDisplayNameDialog() {
    final TextEditingController controller = TextEditingController(
      text: _userProfile?.displayName ?? '',
    );
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                'Đổi tên hiển thị',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên hiển thị mới',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      errorText: errorMessage,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF23DD5B)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isEmpty) {
                      setState(() {
                        errorMessage = 'Tên không được để trống';
                      });
                      return;
                    }

                    final result = await _authService.updateProfile(
                      displayName: newName,
                    );

                    if (result.success && mounted) {
                      Navigator.pop(context);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã cập nhật tên hiển thị'),
                        ),
                      );
                    } else if (mounted) {
                      setState(() {
                        errorMessage = result.message ?? 'Có lỗi xảy ra';
                      });
                    }
                  },
                  child: const Text(
                    'Lưu',
                    style: TextStyle(color: Color(0xFF23DD5B)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tài khoản',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Removed settings icon as requested
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    // Use profile from database, fallback to auth user metadata
    final authUser = _authService.currentAuthUser;

    // Determine display name
    final displayName =
        _userProfile?.displayName ??
        _userProfile?.username ??
        authUser?.userMetadata?['display_name'] ??
        authUser?.userMetadata?['username'] ??
        'Người dùng Soul Sync';

    // Determine subtitle (username or email)
    final subtitle =
        _userProfile?.username != null && _userProfile!.username!.isNotEmpty
        ? '@${_userProfile!.username}'
        : (_userProfile?.email ?? authUser?.email ?? 'Chưa đăng nhập');

    // Determine avatar URL
    final avatarUrl =
        _userProfile?.avatarUrl ?? authUser?.userMetadata?['avatar_url'];

    return Column(
      children: [
        GestureDetector(
          onTap: _isUploadingAvatar ? null : _showAvatarOptions,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF23DD5B), Color(0xFF00C9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black,
                  child: CircleAvatar(
                    radius: 47,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
              // Camera icon overlay
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23DD5B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: _isUploadingAvatar
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
              onPressed: _showEditDisplayNameDialog,
              tooltip: 'Đổi tên hiển thị',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      ],
    );
  }

  // ==================== SECTION WIDGETS ====================

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'Xem tất cả',
              style: TextStyle(
                color: Color(0xFF23DD5B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== RECENTLY PLAYED (VERTICAL LIST) ====================

  Widget _buildRecentlyPlayedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Lịch sử nghe gần đây', () {
          // Navigate to full history
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryPage()),
          );
        }),
        const SizedBox(height: 8),
        if (_recentlyPlayed.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chưa có lịch sử nghe',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ..._recentlyPlayed.take(3).map(_buildRecentlyPlayedItem),
      ],
    );
  }

  Widget _buildRecentlyPlayedItem(Song song) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: song.coverUrl != null
            ? Image.network(
                song.coverUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultSongCover(),
              )
            : _buildDefaultSongCover(),
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
          AddToPlaylistButton(
            songId: song.id,
            songTitle: song.title,
            song: song,
            size: 26,
          ),
          const SizedBox(width: 12),
          Text(
            song.formattedDuration,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
      onTap: () {
        // Play song
      },
    );
  }

  Widget _buildDefaultSongCover() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey[800],
      child: const Icon(Icons.music_note, color: Colors.white),
    );
  }

  // ==================== FOLLOWING ARTISTS (HORIZONTAL SLIDER) ====================

  Widget _buildFollowingArtistsSection() {
    // Get up to 3 most recently followed artists (already sorted by followed_at desc)
    final displayArtists = _followingArtists.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Nghệ sĩ đang theo dõi', () {
          // Navigate to all following artists
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ArtistFollowPage()),
          );
        }),
        const SizedBox(height: 8),
        if (_followingArtists.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chưa theo dõi nghệ sĩ nào',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: displayArtists.length,
              itemBuilder: (context, index) {
                return _buildArtistCircleItem(displayArtists[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildArtistCircleItem(Artist artist) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistPage(artistId: artist.id),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF23DD5B).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[800],
                backgroundImage: artist.imageUrl != null
                    ? NetworkImage(artist.imageUrl!)
                    : null,
                child: artist.imageUrl == null
                    ? const Icon(Icons.person, size: 32, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              artist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RECENT ALBUMS (HORIZONTAL SLIDER) ====================

  Widget _buildRecentAlbumsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple title without "See All" button
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Album nghe gần đây',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_recentAlbums.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chưa nghe album nào',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recentAlbums.take(7).length,
              itemBuilder: (context, index) {
                return _buildAlbumItem(_recentAlbums[index]);
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
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: album.coverUrl != null
                  ? Image.network(
                      album.coverUrl!,
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAlbumCover(),
                    )
                  : _buildDefaultAlbumCover(),
            ),
            const SizedBox(height: 8),
            Text(
              album.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.artist,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAlbumCover() {
    return Container(
      width: 130,
      height: 130,
      color: Colors.grey[800],
      child: const Icon(Icons.album, size: 50, color: Colors.white70),
    );
  }

  // ==================== LOGOUT SECTION ====================

  Widget _buildLogoutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const Divider(color: Colors.grey, height: 32),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showLogoutConfirmDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade700, Colors.red.shade900],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Phiên bản 1.0.0',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    final result = await _authService.signOut();

    if (mounted) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã đăng xuất thành công'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Navigate back to login/main page
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Đăng xuất thất bại'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
