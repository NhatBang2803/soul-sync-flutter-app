import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'now_playing_page.dart';
import 'data/mock_data.dart';
// import 'services/firestore_service.dart';
import 'services/audio_player_service.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onTabChanged;
  
  const HomePage({super.key, this.onTabChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  // final FirestoreService _firestoreService = FirestoreService();
  final AudioPlayerService _audioService = AudioPlayerService();
  
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels <= 0 && 
        _scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      _resetPage();
    }
  }

  void _resetPage() {
    setState(() {
      // Reset logic here - refresh the page
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trang đã được làm mới!'),
        duration: Duration(milliseconds: 800),
        backgroundColor: Color(0xFF23DD5B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar and Header
            _buildHeader(),
            
            // Tab Filters
            _buildTabFilters(),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Access Grid
                    _buildQuickAccessGrid(),
                    
                    const SizedBox(height: 20),
                    
                    // Recently Played Section
                    _buildSectionTitle('Nội dung bạn nghe gần đây'),
                    _buildRecentlyPlayedList(),
                    
                    const SizedBox(height: 20),
                    
                    // Replay Section
                    _buildSectionTitle('Nghe lại'),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onItemTapped: widget.onTabChanged ?? (index) {},
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          // Profile Avatar with gradient border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF23DD5B), Color(0xFF00C9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[800],
                backgroundImage: const AssetImage('assets/images/ellipse1.png'),
                onBackgroundImageError: (exception, stackTrace) {},
                child: const Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào buổi tối',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Soul Sync',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Notification icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Colors.white,
                iconSize: 28,
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF23DD5B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          _buildTabChip('Tất cả', 0, true),
          const SizedBox(width: 7),
          _buildTabChip('Âm nhạc', 1, false),
          const SizedBox(width: 7),
          _buildTabChip('Podcast', 2, false),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle tab selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF23DD5B) : const Color(0xFF222222),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildQuickAccessItem('EM XINH SAY\nHI 2025', const Color.fromARGB(255, 233, 30, 99)),
              const SizedBox(width: 9),
              _buildQuickAccessItem('ANH TRAI SAY\nHI 2025', Colors.blue),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQuickAccessItem('EM XINH SAY\nHI 2025', Colors.pink),
              const SizedBox(width: 9),
              _buildQuickAccessItem('ANH TRAI SAY\nHI 2025', Colors.blue),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQuickAccessItem('EM XINH SAY\nHI 2025', Colors.pink),
              const SizedBox(width: 9),
              _buildQuickAccessItem('ANH TRAI SAY\nHI 2025', Colors.blue),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQuickAccessItem('EM XINH SAY\nHI 2025', Colors.pink),
              const SizedBox(width: 9),
              _buildQuickAccessItem('ANH TRAI SAY\nHI 2025', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(String title, Color color) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.music_note, color: Colors.white),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayedList() {
    // Load songs from MockData instead of Firebase
    final songs = MockData.songs.map((song) => {
      'id': song.id,
      'songName': song.title,
      'artistName': song.artist,
      'albumName': song.album,
      'coverUrl': song.coverUrl,
      'audioUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Dummy URL
      'duration': song.duration,
    }).toList();

    return Column(
      children: songs.take(6).map((song) {
        return _buildSongItem(song, songs);
      }).toList(),
    );
  }

  Widget _buildSongItem(Map<String, dynamic> song, List<Map<String, dynamic>> allSongs) {
    return InkWell(
      onTap: () async {
        // Play song khi click
        final songIndex = allSongs.indexOf(song);
        await _audioService.setPlaylist(allSongs, songIndex);
        
        // Navigate to Now Playing
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NowPlayingPage(),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          children: [
            // Song cover
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: song['coverUrl'] != null
                  ? (song['coverUrl'].toString().startsWith('http')
                      ? Image.network(
                          song['coverUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note, color: Colors.white),
                          ),
                        )
                      : Image.asset(
                          song['coverUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note, color: Colors.white),
                          ),
                        ))
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song['songName'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  song['artistName'] ?? 'Unknown Artist',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
            const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }


}
