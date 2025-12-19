class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int songCount;
  final bool isPublic;
  final String? ownerId;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.songCount = 0,
    this.isPublic = true,
    this.ownerId,
  });

  /// Create Playlist from Supabase JSON
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Playlist',
      description: json['description'],
      coverUrl: json['cover_url'] ?? json['coverUrl'],
      songCount: json['song_count'] ?? 0,
      isPublic: json['is_public'] ?? true,
      ownerId: json['owner_id']?.toString(),
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
      'is_public': isPublic,
      'owner_id': ownerId,
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    int? songCount,
    bool? isPublic,
    String? ownerId,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      songCount: songCount ?? this.songCount,
      isPublic: isPublic ?? this.isPublic,
      ownerId: ownerId ?? this.ownerId,
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
