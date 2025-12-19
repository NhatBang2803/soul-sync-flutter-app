import 'package:flutter/material.dart';

/// Reusable Image Widget that handles both network and asset images
/// with consistent error fallback
class AppImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final double borderRadius;
  final IconData fallbackIcon;
  final double? fallbackIconSize;
  final BoxFit fit;
  final Color? fallbackBackgroundColor;
  final Color? fallbackIconColor;

  const AppImage({
    super.key,
    this.url,
    required this.width,
    required this.height,
    this.borderRadius = 4,
    this.fallbackIcon = Icons.music_note,
    this.fallbackIconSize,
    this.fit = BoxFit.cover,
    this.fallbackBackgroundColor,
    this.fallbackIconColor,
  });

  /// Factory for album covers
  factory AppImage.album({
    String? url,
    double size = 64,
    double borderRadius = 4,
  }) {
    return AppImage(
      url: url,
      width: size,
      height: size,
      borderRadius: borderRadius,
      fallbackIcon: Icons.album,
    );
  }

  /// Factory for song covers
  factory AppImage.song({
    String? url,
    double size = 56,
    double borderRadius = 4,
  }) {
    return AppImage(
      url: url,
      width: size,
      height: size,
      borderRadius: borderRadius,
      fallbackIcon: Icons.music_note,
    );
  }

  /// Factory for playlist covers
  factory AppImage.playlist({
    String? url,
    double size = 64,
    double borderRadius = 4,
  }) {
    return AppImage(
      url: url,
      width: size,
      height: size,
      borderRadius: borderRadius,
      fallbackIcon: Icons.queue_music,
    );
  }

  /// Factory for artist avatars
  factory AppImage.artist({
    String? url,
    double size = 50,
  }) {
    return AppImage(
      url: url,
      width: size,
      height: size,
      borderRadius: size / 2, // Circle
      fallbackIcon: Icons.person,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (url == null || url!.isEmpty) {
      return _buildFallback();
    }

    // Check if it's a network URL or asset
    if (url!.startsWith('http')) {
      return Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoading();
        },
      );
    } else {
      return Image.asset(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: fallbackBackgroundColor ?? Colors.grey[800],
      child: Icon(
        fallbackIcon,
        color: fallbackIconColor ?? Colors.white,
        size: fallbackIconSize ?? (width * 0.5).clamp(16, 32),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[900],
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
          ),
        ),
      ),
    );
  }
}
