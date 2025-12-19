class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int songCount;
  final int listenCount;
  final bool isPublic;
  final String? ownerId;
  final DateTime? createdAt;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.songCount = 0,
    this.listenCount = 0,
    this.isPublic = true,
    this.ownerId,
    this.createdAt,
  });

  /// Create Playlist from Supabase JSON
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Playlist',
      description: json['description'],
      coverUrl: json['cover_url'] ?? json['coverUrl'],
      songCount: json['song_count'] ?? 0,
      listenCount: json['listen_count'] ?? json['listenCount'] ?? 0,
      isPublic: json['is_public'] ?? true,
      ownerId: json['owner_id']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_url': coverUrl,
      'song_count': songCount,
      'listen_count': listenCount,
      'is_public': isPublic,
      'owner_id': ownerId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Format listen count
  String get formattedListenCount {
    if (listenCount >= 1000000) {
      return '${(listenCount / 1000000).toStringAsFixed(1)}M lượt nghe';
    } else if (listenCount >= 1000) {
      return '${(listenCount / 1000).toStringAsFixed(1)}K lượt nghe';
    }
    return '$listenCount lượt nghe';
  }

  /// Format created date
  String get formattedCreatedDate {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  /// Get privacy status text
  String get privacyText => isPublic ? 'Công khai' : 'Riêng tư';

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    int? songCount,
    int? listenCount,
    bool? isPublic,
    String? ownerId,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      songCount: songCount ?? this.songCount,
      listenCount: listenCount ?? this.listenCount,
      isPublic: isPublic ?? this.isPublic,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Playlist(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
