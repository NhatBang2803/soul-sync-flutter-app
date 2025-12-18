import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> quickAccess = [
    {'title': 'EM XINH SAY\nHI 2025', 'color': 'pink'},
    {'title': 'ANH TRAI SAY\nHI 2025', 'color': 'blue'},
    {'title': 'EM XINH SAY\nHI 2025', 'color': 'pink'},
    {'title': 'ANH TRAI SAY\nHI 2025', 'color': 'blue'},
    {'title': 'EM XINH SAY\nHI 2025', 'color': 'pink'},
    {'title': 'ANH TRAI SAY\nHI 2025', 'color': 'blue'},
    {'title': 'EM XINH SAY\nHI 2025', 'color': 'pink'},
    {'title': 'ANH TRAI SAY\nHI 2025', 'color': 'blue'},
  ];

  final List<Map<String, String>> charts = [
    {'title': 'Top 50', 'image': 'assets/images/image11.png'},
    {'title': 'Top 100', 'image': 'assets/images/image11.png'},
  ];

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
      quickAccess.shuffle();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trang đã được reset!'),
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
            _buildHeader(),
            _buildTabFilters(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    _buildQuickAccessGrid(),
                    const SizedBox(height: 25),
                    _buildSectionTitle('Bảng xếp hạng'),
                    const SizedBox(height: 15),
                    _buildChartsSection(),
                    const SizedBox(height: 25),
                    _buildSectionTitle('Dựa trên nhạc bạn nghe gần đây'),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.grey[800],
            child: Image.asset(
              'assets/images/ellipse1.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, size: 18, color: Colors.white);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabChip('Tất cả', 0, false),
            const SizedBox(width: 7),
            _buildTabChip('Nhạc', 1, true),
            const SizedBox(width: 7),
            _buildTabChip('Đang theo dõi', 2, false),
            const SizedBox(width: 7),
            _buildTabChip('Podcast', 3, false),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int index, bool isSelected) {
    return Container(
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
    );
  }

  Widget _buildQuickAccessGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          for (int i = 0; i < quickAccess.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessItem(
                      quickAccess[i]['title']!,
                      quickAccess[i]['color']! == 'pink' ? Colors.pink : Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 9),
                  if (i + 1 < quickAccess.length)
                    Expanded(
                      child: _buildQuickAccessItem(
                        quickAccess[i + 1]['title']!,
                        quickAccess[i + 1]['color']! == 'pink' ? Colors.pink : Colors.blue,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(String title, Color color) {
    return Container(
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
            child: const Icon(Icons.music_note, color: Colors.white, size: 24),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
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

  Widget _buildChartsSection() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: charts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    charts[index]['image']!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_note, color: Colors.white, size: 50),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  charts[index]['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


}
