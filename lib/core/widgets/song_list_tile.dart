import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_image.dart';
import '../../components/add_to_playlist_dialog.dart';

/// Reusable Song List Tile Widget
/// Replaces duplicate _buildSongItem implementations across multiple pages
class SongListTile extends StatelessWidget {
  final Map<String, dynamic> song;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final Widget? trailing;
  final bool showMoreButton;
  final bool showAddToPlaylistButton;
  final double coverSize;
  final EdgeInsetsGeometry padding;

  const SongListTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMoreTap,
    this.trailing,
    this.showMoreButton = true,
    this.showAddToPlaylistButton = true,
    this.coverSize = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  /// Get song ID
  String? get songId => song['id']?.toString();

  /// Get song title with fallback
  String get title => song['songName'] ?? song['title'] ?? 'Unknown Song';

  /// Get artist name with fallback
  String get artist =>
      song['artistName'] ?? song['artist_name'] ?? 'Unknown Artist';

  /// Get cover URL
  String? get coverUrl => song['coverUrl'] ?? song['cover_url'];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            // Cover Image
            AppImage.song(url: coverUrl, size: coverSize),
            const SizedBox(width: 12),
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    artist,
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
            // Add to playlist button
            if (showAddToPlaylistButton && songId != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AddToPlaylistButton(
                  songId: songId!,
                  songTitle: title,
                  size: 28,
                ),
              ),
            // Trailing Widget
            if (trailing != null)
              trailing!
            else if (showMoreButton)
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: onMoreTap,
              ),
          ],
        ),
      ),
    );
  }
}

/// Song List Tile with Like Button
class LikedSongListTile extends StatelessWidget {
  final Map<String, dynamic> song;
  final bool isLiked;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;

  const LikedSongListTile({
    super.key,
    required this.song,
    this.isLiked = true,
    this.onTap,
    this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SongListTile(
      song: song,
      onTap: onTap,
      showMoreButton: false,
      showAddToPlaylistButton: true,
      trailing: IconButton(
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? AppColors.primary : Colors.grey,
          size: 20,
        ),
        onPressed: onLikeTap,
      ),
    );
  }
}
