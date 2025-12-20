import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'components/add_to_playlist_dialog.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'models/models.dart';
import 'core/core.dart';
import 'pages/artist_page.dart';
import 'pages/album_page.dart';
import 'pages/playlist_page.dart';

class ProfilePage extends StatefulWidget {
  final Function(int)? onTabChanged;

  const ProfilePage({super.key, this.onTabChanged});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();

  List<Song> _recentlyPlayed = [];
  List<Artist> _followingArtists = [];
  List<Playlist> _myPlaylists = [];
  List<Album> _recentAlbums = [];
  bool _isLoading = true;

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
        final results = await Future.wait([
          _supabaseService.getRecentlyPlayed(userId, limit: 10),
          _supabaseService.getFollowingArtists(userId),
          _supabaseService.getUserPlaylists(userId),
          _supabaseService.getRecentlyPlayedAlbums(userId, limit: 10),
        ]);

        if (mounted) {
          setState(() {
            _recentlyPlayed = (results[0] as List)
                .map((json) => Song.fromJson(json))
                .toList();
            _followingArtists = (results[1] as List)
                .map((json) => Artist.fromJson(json))
                .toList();
            _myPlaylists = (results[2] as List)
                .map((json) => Playlist.fromJson(json))
                .toList();
            _recentAlbums = (results[3] as List)
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
      if (mounted) {
        setState(() => _isLoading = false);
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
                    _buildMyPlaylistsSection(),
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
    final user = _authService.currentAuthUser;

    return Column(
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
              backgroundImage: user?.userMetadata?['avatar_url'] != null
                  ? NetworkImage(user!.userMetadata!['avatar_url'])
                  : null,
              child: user?.userMetadata?['avatar_url'] == null
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.userMetadata?['display_name'] ??
              user?.userMetadata?['username'] ??
              'Người dùng Soul Sync',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user?.email ?? 'Chưa đăng nhập',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
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
          ..._recentlyPlayed.take(5).map(_buildRecentlyPlayedItem),
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
          AddToPlaylistButton(songId: song.id, songTitle: song.title, size: 26),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Nghệ sĩ đang theo dõi', () {
          // Navigate to all following artists
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
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _followingArtists.length,
              itemBuilder: (context, index) {
                return _buildArtistItem(_followingArtists[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildArtistItem(Artist artist) {
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
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[800],
              backgroundImage: artist.imageUrl != null
                  ? NetworkImage(artist.imageUrl!)
                  : null,
              child: artist.imageUrl == null
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MY PLAYLISTS (HORIZONTAL SLIDER) ====================

  Widget _buildMyPlaylistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Playlist đã tạo', () {
          // Navigate to all playlists
        }),
        const SizedBox(height: 8),
        if (_myPlaylists.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chưa tạo playlist nào',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _myPlaylists.length,
              itemBuilder: (context, index) {
                return _buildPlaylistItem(_myPlaylists[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPlaylistItem(Playlist playlist) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistPage(playlistId: playlist.id),
          ),
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
              child: playlist.coverUrl != null
                  ? Image.network(
                      playlist.coverUrl!,
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildDefaultPlaylistCover(),
                    )
                  : _buildDefaultPlaylistCover(),
            ),
            const SizedBox(height: 8),
            Text(
              playlist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Icon(
                  playlist.isPublic ? Icons.public : Icons.lock,
                  size: 12,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '${playlist.songCount} bài',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPlaylistCover() {
    return Container(
      width: 130,
      height: 130,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7E22CE), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.queue_music, size: 50, color: Colors.white70),
    );
  }

  // ==================== RECENT ALBUMS (HORIZONTAL SLIDER) ====================

  Widget _buildRecentAlbumsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Album nghe gần đây', () {
          // Navigate to all recent albums
        }),
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
              itemCount: _recentAlbums.length,
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
