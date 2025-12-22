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
        height: 64,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 84),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Progress indicator at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 2,
                  color: const Color(0xFF23DD5B).withOpacity(0.3),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Cover with rounded corners
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildCoverImage(song.coverUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Song info
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
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Play/Pause button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF23DD5B),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF23DD5B).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 24,
                        ),
                        onPressed: onPlayPause,
                      ),
                    ),
                  ],
                ),
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
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    } else {
      return Image.asset(
        url,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    }
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[800]!, Colors.grey[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54, size: 22),
    );
  }
}

/// Dynamic MiniPlayer that works with Map<String, dynamic> from AudioPlayerService
/// This is useful when the current song comes from a service as raw map data
class MiniPlayerDynamic extends StatefulWidget {
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

  @override
  State<MiniPlayerDynamic> createState() => _MiniPlayerDynamicState();
}

class _MiniPlayerDynamicState extends State<MiniPlayerDynamic>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  String get title =>
      widget.song['songName'] ?? widget.song['title'] ?? 'Unknown';
  String get artist =>
      widget.song['artistName'] ??
      widget.song['artist_name'] ??
      'Unknown Artist';
  String? get coverUrl => widget.song['coverUrl'] ?? widget.song['cover_url'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onExpand,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            height: 64,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 84),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A2E),
                  Color.lerp(
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                    _animationController.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF1A1A2E),
                    const Color(0xFF23DD5B).withOpacity(0.15),
                    _animationController.value,
                  )!,
                ],
                stops: const [0.0, 0.6, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Cover with rounded corners
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildCoverImage(coverUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Song info
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
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artist,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Play/Pause button with green circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF23DD5B),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF23DD5B).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          widget.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 24,
                        ),
                        onPressed: widget.onPlayPause,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    } else {
      return Image.asset(
        url,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    }
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[800]!, Colors.grey[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54, size: 22),
    );
  }
}
