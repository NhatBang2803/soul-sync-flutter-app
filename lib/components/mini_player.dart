import 'package:flutter/material.dart';
import '../models/song.dart';

/// MiniPlayer widget that displays current song at bottom of screen
/// Supports both Song model and Map<String, dynamic> data
class MiniPlayer extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onExpand;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onExpand,
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 80),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildCoverImage(song.coverUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: onPlayPause,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? url) {
    if (url == null || url.isEmpty) {
      return _buildDefaultCover();
    }

    // Check if it's a network URL or asset
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    } else {
      return Image.asset(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    }
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey[800],
      child: const Icon(Icons.music_note, color: Colors.white, size: 24),
    );
  }
}

/// Dynamic MiniPlayer that works with Map<String, dynamic> from AudioPlayerService
/// This is useful when the current song comes from a service as raw map data
class MiniPlayerDynamic extends StatelessWidget {
  final Map<String, dynamic> song;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onExpand;

  const MiniPlayerDynamic({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onExpand,
  });

  String get title => song['songName'] ?? song['title'] ?? 'Unknown';
  String get artist =>
      song['artistName'] ?? song['artist_name'] ?? 'Unknown Artist';
  String? get coverUrl => song['coverUrl'] ?? song['cover_url'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onExpand,
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 80),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildCoverImage(coverUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artist,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: onPlayPause,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? url) {
    if (url == null || url.isEmpty) {
      return _buildDefaultCover();
    }

    // Check if it's a network URL or asset
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    } else {
      return Image.asset(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    }
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey[800],
      child: const Icon(Icons.music_note, color: Colors.white, size: 24),
    );
  }
}
