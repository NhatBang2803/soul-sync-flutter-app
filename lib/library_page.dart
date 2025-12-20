import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'services/supabase_service.dart';
import 'services/audio_player_service.dart';
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

  int _activeFilterIndex = 0; // 0=all, 1=playlists, 2=albums, 3=liked

  List<Playlist> _playlists = [];
  List<Album> _albums = [];
  List<Song> _songs = [];
  bool _isLoading = true;
  String? _error;

  static const _filterLabels = [
    AppStrings.all,
    AppStrings.playlist,
    AppStrings.album,
    AppStrings.liked,
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
      final results = await Future.wait([
        _supabaseService.getPublicPlaylists(),
        _supabaseService.getAlbums(),
        _supabaseService.getSongs(),
      ]);

      if (mounted) {
        setState(() {
          _playlists = (results[0] as List)
              .map((json) => Playlist.fromJson(json))
              .toList();
          _albums = (results[1] as List)
              .map((json) => Album.fromJson(json))
              .toList();
          _songs = (results[2] as List)
              .map((json) => Song.fromJson(json))
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
    final playlist = _songs.map((s) => s.toPlayerFormat()).toList();
    await _audioService.setPlaylist(playlist, index);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NowPlayingPage()),
      );
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
            onPressed: () {},
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
          if (_activeFilterIndex == 0 || _activeFilterIndex == 3)
            _buildLikedSongsCard(),
          if (_activeFilterIndex == 0 || _activeFilterIndex == 1)
            _buildPlaylistsSection(),
          if (_activeFilterIndex == 0 || _activeFilterIndex == 2)
            _buildAlbumsSection(),
          if (_activeFilterIndex == 3) _buildLikedSongsList(),
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
            onTap: () => setState(() => _activeFilterIndex = 3),
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
                          '${_songs.length} bài hát',
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

  Widget _buildAlbumsSection() {
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
                AppStrings.album,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_albums.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                AppStrings.noAlbum,
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ..._albums.map(_buildAlbumItem),
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
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedSongsList() {
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
          if (_songs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                AppStrings.noSong,
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ..._songs.asMap().entries.map((entry) {
              final index = entry.key;
              final song = entry.value;
              return LikedSongListTile(
                song: song.toPlayerFormat(),
                isLiked: true,
                onTap: () => _onSongTap(song, index),
              );
            }),
        ],
      ),
    );
  }
}
