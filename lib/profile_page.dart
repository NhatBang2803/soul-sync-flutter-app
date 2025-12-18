import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';

class ProfilePage extends StatelessWidget {
  final Function(int)? onTabChanged;
  
  const ProfilePage({super.key, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildProfileInfo(),
              const SizedBox(height: 32),
              _buildStatsSection(),
              const SizedBox(height: 32),
              _buildMenuSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3,
        onItemTapped: onTabChanged ?? (index) {},
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
            'Tài khoản',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
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
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Người dùng Music App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'user@musicapp.com',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('42', 'Playlist'),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[800],
          ),
          _buildStatItem('128', 'Nghệ sĩ'),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[800],
          ),
          _buildStatItem('2.4K', 'Bài hát'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF23DD5B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(Icons.history, 'Lịch sử nghe gần đây'),
        _buildMenuItem(Icons.download, 'Tải xuống'),
        _buildMenuItem(Icons.favorite, 'Bài hát yêu thích'),
        _buildMenuItem(Icons.queue_music, 'Playlist của tôi'),
        _buildMenuItem(Icons.person_add, 'Đang theo dõi'),
        const Divider(color: Color(0xFF222222), height: 32),
        _buildMenuItem(Icons.notifications, 'Thông báo'),
        _buildMenuItem(Icons.language, 'Ngôn ngữ'),
        _buildMenuItem(Icons.dark_mode, 'Giao diện'),
        _buildMenuItem(Icons.privacy_tip, 'Quyền riêng tư'),
        _buildMenuItem(Icons.help, 'Trợ giúp & Hỗ trợ'),
        _buildMenuItem(Icons.info, 'Giới thiệu'),
        const Divider(color: Color(0xFF222222), height: 32),
        _buildMenuItemWithRoute(Icons.admin_panel_settings, '🔧 Admin - Seed Data', '/admin'),
        const Divider(color: Color(0xFF222222), height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF222222),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildMenuItemWithRoute(IconData icon, String title, String route) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.blue),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
