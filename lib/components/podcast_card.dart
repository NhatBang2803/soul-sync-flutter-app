import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/podcast.dart';

/// Reusable Podcast Card Widget
/// Similar to AlbumCard but with 20% larger width for podcast appearance
/// Used in: HomePage, SearchPage, PodcastPage
class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final VoidCallback? onTap;
  final double size;
  final bool showHost;
  final bool showEpisodeCount;

  const PodcastCard({
    super.key,
    required this.podcast,
    this.onTap,
    this.size = 156, // 20% larger than AlbumCard's 130
    this.showHost = true,
    this.showEpisodeCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Podcast cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: podcast.imageUrl != null
                  ? Image.network(
                      podcast.imageUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultCover(),
                    )
                  : _buildDefaultCover(),
            ),
            const SizedBox(height: 6),
            // Text content wrapped in Flexible to prevent overflow
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Podcast title
                  Text(
                    podcast.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Host name
                  if (showHost) ...[
                    const SizedBox(height: 2),
                    Text(
                      podcast.hostName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Episode count
                  if (showEpisodeCount) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${podcast.episodeCount} tập',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.podcasts, color: AppColors.textPrimary, size: 48),
    );
  }
}

/// Quick Access Podcast Card with frosted glass effect
/// Used in: HomePage grid (similar to QuickAccessAlbumCard)
class QuickAccessPodcastCard extends StatelessWidget {
  final Podcast podcast;
  final VoidCallback? onTap;

  const QuickAccessPodcastCard({super.key, required this.podcast, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Podcast cover
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          bottomLeft: Radius.circular(7),
                        ),
                        image: podcast.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(podcast.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: podcast.imageUrl == null
                            ? AppColors.primary.withOpacity(0.3)
                            : null,
                      ),
                      child: podcast.imageUrl == null
                          ? const Icon(
                              Icons.podcasts,
                              color: AppColors.textPrimary,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    // Podcast info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcast.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            podcast.hostName,
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.8),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrollable list of Podcast Cards
class PodcastCardList extends StatelessWidget {
  final List<Podcast> podcasts;
  final void Function(Podcast podcast)? onPodcastTap;
  final double height;
  final double cardSize;
  final int maxItems;

  const PodcastCardList({
    super.key,
    required this.podcasts,
    this.onPodcastTap,
    this.height = 220, // Taller than AlbumCardList due to larger cards
    this.cardSize = 156, // 20% larger
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (podcasts.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayPodcasts = podcasts.take(maxItems).toList();

    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: displayPodcasts.length,
        itemBuilder: (context, index) {
          final podcast = displayPodcasts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PodcastCard(
              podcast: podcast,
              size: cardSize,
              onTap: onPodcastTap != null ? () => onPodcastTap!(podcast) : null,
            ),
          );
        },
      ),
    );
  }
}
