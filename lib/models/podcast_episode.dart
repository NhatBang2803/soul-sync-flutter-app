/// PodcastEpisode model - represents a single podcast episode
/// Similar to Song but for podcast content
class PodcastEpisode {
  final String id;
  final String podcastId;
  final String title;
  final String? description;
  final String audioUrl;
  final int duration; // in seconds
  final int playCount;
  final DateTime publishedAt;
  final String? podcastTitle;
  final String? hostName;
  final String? podcastImage;
  final String? category;

  PodcastEpisode({
    required this.id,
    required this.podcastId,
    required this.title,
    this.description,
    required this.audioUrl,
    this.duration = 0,
    this.playCount = 0,
    required this.publishedAt,
    this.podcastTitle,
    this.hostName,
    this.podcastImage,
    this.category,
  });

  /// Create from JSON (view_podcast_episodes_full)
  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: json['id']?.toString() ?? '',
      podcastId:
          json['podcast_id']?.toString() ?? json['podcastId']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Episode',
      description: json['description'],
      audioUrl: json['audio_url'] ?? json['audioUrl'] ?? '',
      duration: json['duration'] ?? 0,
      playCount: json['play_count'] ?? json['playCount'] ?? 0,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      podcastTitle: json['podcast_title'] ?? json['podcastTitle'],
      hostName: json['host_name'] ?? json['hostName'],
      podcastImage: json['podcast_image'] ?? json['podcastImage'],
      category: json['category'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'podcast_id': podcastId,
      'title': title,
      'description': description,
      'audio_url': audioUrl,
      'duration': duration,
      'play_count': playCount,
      'published_at': publishedAt.toIso8601String(),
      'podcast_title': podcastTitle,
      'host_name': hostName,
      'podcast_image': podcastImage,
      'category': category,
    };
  }

  /// Convert to player format - REUSES AudioPlayerService
  /// Same format as Song.toPlayerFormat() for compatibility
  Map<String, dynamic> toPlayerFormat() {
    return {
      'id': id,
      'songName': title, // AudioPlayerService uses songName
      'artistName': hostName ?? 'Unknown Host',
      'artistNames': [hostName ?? 'Unknown Host'],
      'albumName': podcastTitle,
      'coverUrl': podcastImage,
      'audioUrl': audioUrl,
      'duration': duration,
      'isPodcast': true, // Flag to identify podcast in player
    };
  }

  /// Get formatted duration
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get relative published time
  String get relativePublishedTime {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    }
    return 'Vừa xong';
  }

  /// Create a copy with modifications
  PodcastEpisode copyWith({
    String? id,
    String? podcastId,
    String? title,
    String? description,
    String? audioUrl,
    int? duration,
    int? playCount,
    DateTime? publishedAt,
    String? podcastTitle,
    String? hostName,
    String? podcastImage,
    String? category,
  }) {
    return PodcastEpisode(
      id: id ?? this.id,
      podcastId: podcastId ?? this.podcastId,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      playCount: playCount ?? this.playCount,
      publishedAt: publishedAt ?? this.publishedAt,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      hostName: hostName ?? this.hostName,
      podcastImage: podcastImage ?? this.podcastImage,
      category: category ?? this.category,
    );
  }

  @override
  String toString() =>
      'PodcastEpisode(id: $id, title: $title, podcast: $podcastTitle)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastEpisode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
