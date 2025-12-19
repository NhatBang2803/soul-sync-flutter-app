class Album {
  final String id;
  final String name;
  final String artist;
  final String? artistId;
  final String? coverUrl;
  final int? year;
  final int songCount;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    this.artistId,
    this.coverUrl,
    this.year,
    this.songCount = 0,
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
    };
  }

  Album copyWith({
    String? id,
    String? name,
    String? artist,
    String? artistId,
    String? coverUrl,
    int? year,
    int? songCount,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      coverUrl: coverUrl ?? this.coverUrl,
      year: year ?? this.year,
      songCount: songCount ?? this.songCount,
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
