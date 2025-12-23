import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../models/artist.dart';
import '../core/core.dart';
import 'artist_page.dart';

/// Page hiển thị tất cả nghệ sĩ đang theo dõi
class ArtistFollowPage extends StatefulWidget {
  const ArtistFollowPage({super.key});

  @override
  State<ArtistFollowPage> createState() => _ArtistFollowPageState();
}

class _ArtistFollowPageState extends State<ArtistFollowPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();

  List<Artist> _followingArtists = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFollowingArtists();
  }

  Future<void> _loadFollowingArtists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = _authService.currentUserId;

      if (userId != null) {
        final artists = await _supabaseService.getFollowingArtists(userId);
        if (mounted) {
          setState(() {
            _followingArtists = artists
                .map((json) => Artist.fromJson(json))
                .toList();
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Bạn cần đăng nhập để xem nghệ sĩ đang theo dõi';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Không thể tải danh sách nghệ sĩ';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nghệ sĩ đang theo dõi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: AppLoadingIndicator())
          : _error != null
          ? AppErrorState(message: _error!, onRetry: _loadFollowingArtists)
          : _followingArtists.isEmpty
          ? _buildEmptyState()
          : _buildArtistGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'Chưa theo dõi nghệ sĩ nào',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy tìm và theo dõi nghệ sĩ yêu thích của bạn',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75, // Wider cards
      ),
      itemCount: _followingArtists.length,
      itemBuilder: (context, index) {
        return _buildArtistCard(_followingArtists[index]);
      },
    );
  }

  Widget _buildArtistCard(Artist artist) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistPage(artistId: artist.id),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Artist avatar with gradient border
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
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[800],
                backgroundImage: artist.imageUrl != null
                    ? NetworkImage(artist.imageUrl!)
                    : null,
                child: artist.imageUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Artist name
          Text(
            artist.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
