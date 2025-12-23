/// Podcast model - represents a podcast show
class Podcast {
  final String id;
  final String title;
  final String hostName;
  final String? description;
  final String? imageUrl;
  final String category;
  final int episodeCount;
  final int totalDurationSeconds;
  final int totalPlays;
  final DateTime? lastUpdated;
  final DateTime createdAt;
  bool isSaved;

  Podcast({
    required this.id,
    required this.title,
    required this.hostName,
    this.description,
    this.imageUrl,
    this.category = 'General',
    this.episodeCount = 0,
    this.totalDurationSeconds = 0,
    this.totalPlays = 0,
    this.lastUpdated,
    required this.createdAt,
    this.isSaved = false,
  });

  /// Create from JSON (view_podcast_library)
  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Podcast',
      hostName: json['host_name'] ?? json['hostName'] ?? 'Unknown Host',
      description: json['description'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      category: json['category'] ?? 'General',
      episodeCount: json['episode_count'] ?? json['episodeCount'] ?? 0,
      totalDurationSeconds:
          json['total_duration_seconds'] ?? json['totalDurationSeconds'] ?? 0,
      totalPlays: json['total_plays'] ?? json['totalPlays'] ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isSaved: json['is_saved'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'host_name': hostName,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'episode_count': episodeCount,
      'total_duration_seconds': totalDurationSeconds,
      'total_plays': totalPlays,
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_saved': isSaved,
    };
  }

  /// Get formatted total duration
  String get formattedTotalDuration {
    final hours = totalDurationSeconds ~/ 3600;
    final minutes = (totalDurationSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours giờ $minutes phút';
    }
    return '$minutes phút';
  }

  /// Create a copy with modifications
  Podcast copyWith({
    String? id,
    String? title,
    String? hostName,
    String? description,
    String? imageUrl,
    String? category,
    int? episodeCount,
    int? totalDurationSeconds,
    int? totalPlays,
    DateTime? lastUpdated,
    DateTime? createdAt,
    bool? isSaved,
  }) {
    return Podcast(
      id: id ?? this.id,
      title: title ?? this.title,
      hostName: hostName ?? this.hostName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      episodeCount: episodeCount ?? this.episodeCount,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      totalPlays: totalPlays ?? this.totalPlays,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  String toString() => 'Podcast(id: $id, title: $title, host: $hostName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Podcast && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
