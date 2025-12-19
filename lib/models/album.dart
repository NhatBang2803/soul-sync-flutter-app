class Album {
  final String id;
  final String name;
  final String artist;
  final String? artistId;
  final String? coverUrl;
  final int? year;
  final int songCount;
  final int listenCount;
  final bool isPublic;
  final DateTime? createdAt;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    this.artistId,
    this.coverUrl,
    this.year,
    this.songCount = 0,
    this.listenCount = 0,
    this.isPublic = true,
    this.createdAt,
  });

  /// Create Album from Supabase JSON
  factory Album.fromJson(Map<String, dynamic> json) {
    // Handle nested artist object from Supabase joins
    String artistName = 'Unknown Artist';
    if (json['artists'] != null && json['artists'] is Map) {
      artistName = json['artists']['name'] ?? 'Unknown Artist';
    } else {
      artistName = json['artist_name'] ?? json['artist'] ?? 'Unknown Artist';
    }

    return Album(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Album',
      artist: artistName,
      artistId: json['artist_id']?.toString(),
      coverUrl: json['cover_url'] ?? json['coverUrl'],
      year: json['release_year'] ?? json['year'],
      songCount: json['song_count'] ?? 0,
      listenCount: json['listen_count'] ?? json['listenCount'] ?? 0,
      isPublic: json['is_public'] ?? json['isPublic'] ?? true,
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
      'artist_name': artist,
      'artist_id': artistId,
      'cover_url': coverUrl,
      'release_year': year,
      'song_count': songCount,
      'listen_count': listenCount,
      'is_public': isPublic,
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

  Album copyWith({
    String? id,
    String? name,
    String? artist,
    String? artistId,
    String? coverUrl,
    int? year,
    int? songCount,
    int? listenCount,
    bool? isPublic,
    DateTime? createdAt,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      coverUrl: coverUrl ?? this.coverUrl,
      year: year ?? this.year,
      songCount: songCount ?? this.songCount,
      listenCount: listenCount ?? this.listenCount,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Album(id: $id, name: $name, artist: $artist)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
