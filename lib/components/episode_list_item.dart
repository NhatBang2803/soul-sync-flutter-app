import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/podcast_episode.dart';

/// Reusable Episode List Item Widget
/// Similar to song list item but for podcast episodes
/// Used in: PodcastPage, SearchPage, HistoryPage
class EpisodeListItem extends StatelessWidget {
  final PodcastEpisode episode;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final Widget? trailing;
  final bool showPodcastTitle;

  const EpisodeListItem({
    super.key,
    required this.episode,
    this.onTap,
    this.onPlayTap,
    this.trailing,
    this.showPodcastTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: episode.podcastImage != null
            ? Image.network(
                episode.podcastImage!,
                width: 56, // Slightly larger than song items
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultCover(),
              )
            : _buildDefaultCover(),
      ),
      title: Text(
        episode.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPodcastTitle && episode.podcastTitle != null)
            Text(
              episode.podcastTitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Row(
            children: [
              Text(
                episode.formattedDuration,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(width: 8),
              Text(
                episode.relativePublishedTime,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      trailing:
          trailing ??
          IconButton(
            icon: const Icon(
              Icons.play_circle_outline,
              color: AppColors.primary,
              size: 32,
            ),
            onPressed: onPlayTap ?? onTap,
          ),
      onTap: onTap,
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.surface,
      child: const Icon(Icons.podcasts, color: AppColors.textMuted),
    );
  }
}

/// Compact Episode Item for lists
/// Used when showing many episodes in a condensed format
class CompactEpisodeItem extends StatelessWidget {
  final PodcastEpisode episode;
  final VoidCallback? onTap;
  final int? index;

  const CompactEpisodeItem({
    super.key,
    required this.episode,
    this.onTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            // Episode number or play icon
            SizedBox(
              width: 32,
              child: index != null
                  ? Text(
                      '${index! + 1}',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : const Icon(
                      Icons.play_arrow,
                      color: AppColors.primary,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            // Episode info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${episode.formattedDuration} • ${episode.relativePublishedTime}',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Play button
            IconButton(
              icon: const Icon(
                Icons.play_circle_filled,
                color: AppColors.primary,
              ),
              onPressed: onTap,
              iconSize: 28,
            ),
          ],
        ),
      ),
    );
  }
}
