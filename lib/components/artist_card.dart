import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/artist.dart';

/// Reusable Artist Card Widget
/// Displays artist avatar (circular) with name and optional follower count
/// Used in: HomePage (horizontal list), SearchPage (horizontal list)
class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final double avatarRadius;
  final double width;
  final bool showFollowers;
  final int? rank;

  const ArtistCard({
    super.key,
    required this.artist,
    this.onTap,
    this.avatarRadius = 35,
    this.width = 90,
    this.showFollowers = false,
    this.rank,
  });

  /// Create from Map data (for backward compatibility)
  factory ArtistCard.fromMap({
    required Map<String, dynamic> data,
    VoidCallback? onTap,
    double avatarRadius = 35,
    double width = 90,
    bool showFollowers = false,
    int? rank,
  }) {
    return ArtistCard(
      artist: Artist.fromJson(data),
      onTap: onTap,
      avatarRadius: avatarRadius,
      width: width,
      showFollowers: showFollowers,
      rank: rank,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: AppColors.surface,
                  backgroundImage: artist.imageUrl != null
                      ? NetworkImage(artist.imageUrl!)
                      : null,
                  child: artist.imageUrl == null
                      ? Icon(
                          Icons.person,
                          size: avatarRadius * 0.85,
                          color: AppColors.textMuted,
                        )
                      : null,
                ),
                // Rank badge (if provided)
                if (rank != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _getRankColor(rank!),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showFollowers)
              Text(
                artist.formattedFollowers,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }
}

/// Horizontal scrollable list of Artist Cards
class ArtistCardList extends StatelessWidget {
  final List<Artist> artists;
  final void Function(Artist artist)? onArtistTap;
  final double height;
  final double avatarRadius;
  final bool showFollowers;
  final bool showRanks;
  final int maxItems;

  const ArtistCardList({
    super.key,
    required this.artists,
    this.onArtistTap,
    this.height = 120,
    this.avatarRadius = 35,
    this.showFollowers = false,
    this.showRanks = false,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    final displayArtists = artists.take(maxItems).toList();

    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: displayArtists.length,
        itemBuilder: (context, index) {
          final artist = displayArtists[index];
          return ArtistCard(
            artist: artist,
            avatarRadius: avatarRadius,
            showFollowers: showFollowers,
            rank: showRanks ? index + 1 : null,
            onTap: onArtistTap != null ? () => onArtistTap!(artist) : null,
          );
        },
      ),
    );
  }
}
