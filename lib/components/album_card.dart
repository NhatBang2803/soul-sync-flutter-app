import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/album.dart';

/// Reusable Album Card Widget
/// Displays album cover with title and artist name
/// Used in: HomePage (Quick Access, New Releases), SearchPage, ArtistPage
class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback? onTap;
  final double size;
  final bool showArtist;

  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.size = 130,
    this.showArtist = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: album.coverUrl != null
                  ? Image.network(
                      album.coverUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultCover(),
                    )
                  : _buildDefaultCover(),
            ),
            const SizedBox(height: 8),
            // Album name
            Text(
              album.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Artist name
            if (showArtist)
              Text(
                album.artist,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      child: const Icon(Icons.album, color: AppColors.textPrimary, size: 40),
    );
  }
}

/// Quick Access Album Item with frosted glass effect
/// Used in: HomePage grid (2 columns)
class QuickAccessAlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback? onTap;

  const QuickAccessAlbumCard({super.key, required this.album, this.onTap});

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
                    // Album cover
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          bottomLeft: Radius.circular(7),
                        ),
                        image: album.coverUrl != null
                            ? DecorationImage(
                                image: NetworkImage(album.coverUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: album.coverUrl == null
                            ? AppColors.primary.withOpacity(0.3)
                            : null,
                      ),
                      child: album.coverUrl == null
                          ? const Icon(
                              Icons.album,
                              color: AppColors.textPrimary,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    // Album info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.name,
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
                            album.artist,
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

/// Grid of Quick Access Album Cards (2 columns)
class QuickAccessAlbumGrid extends StatelessWidget {
  final List<Album> albums;
  final void Function(Album album)? onAlbumTap;
  final int maxItems;

  const QuickAccessAlbumGrid({
    super.key,
    required this.albums,
    this.onAlbumTap,
    this.maxItems = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayAlbums = albums.take(maxItems).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          for (int i = 0; i < displayAlbums.length && i < maxItems; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: QuickAccessAlbumCard(
                      album: displayAlbums[i],
                      onTap: onAlbumTap != null
                          ? () => onAlbumTap!(displayAlbums[i])
                          : null,
                    ),
                  ),
                  const SizedBox(width: 9),
                  if (i + 1 < displayAlbums.length)
                    Expanded(
                      child: QuickAccessAlbumCard(
                        album: displayAlbums[i + 1],
                        onTap: onAlbumTap != null
                            ? () => onAlbumTap!(displayAlbums[i + 1])
                            : null,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Horizontal scrollable list of Album Cards
class AlbumCardList extends StatelessWidget {
  final List<Album> albums;
  final void Function(Album album)? onAlbumTap;
  final double height;
  final double cardSize;
  final int maxItems;

  const AlbumCardList({
    super.key,
    required this.albums,
    this.onAlbumTap,
    this.height = 180,
    this.cardSize = 130,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    final displayAlbums = albums.take(maxItems).toList();

    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: displayAlbums.length,
        itemBuilder: (context, index) {
          final album = displayAlbums[index];
          return AlbumCard(
            album: album,
            size: cardSize,
            onTap: onAlbumTap != null ? () => onAlbumTap!(album) : null,
          );
        },
      ),
    );
  }
}
