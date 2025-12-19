class Song {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? album;
  final String? albumId;
  final int duration; // in seconds
  final String? coverUrl;
  final String? audioUrl;
  final int playCount;
  bool isLiked;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.album,
    this.albumId,
    required this.duration,
    this.coverUrl,
    this.audioUrl,
    this.playCount = 0,
    this.isLiked = false,
  });

  /// Create Song from Supabase JSON (snake_case)
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['songName'] ?? 'Unknown',
      artist: json['artist_name'] ?? json['artistName'] ?? 'Unknown Artist',
      artistId: json['artist_id']?.toString(),
      album: json['album_name'] ?? json['albumName'],
      albumId: json['album_id']?.toString(),
      duration: json['duration'] ?? 0,
      coverUrl: json['cover_url'] ?? json['coverUrl'],
      audioUrl: json['audio_url'] ?? json['audioUrl'],
      playCount: json['play_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_name': artist,
      'artist_id': artistId,
      'album_name': album,
      'album_id': albumId,
      'duration': duration,
      'cover_url': coverUrl,
      'audio_url': audioUrl,
      'play_count': playCount,
      'is_liked': isLiked,
    };
  }

  /// Convert to player format (camelCase for AudioPlayerService)
  Map<String, dynamic> toPlayerFormat() {
    return {
      'id': id,
      'songName': title,
      'artistName': artist,
      'albumName': album,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
      'duration': duration,
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Create a copy with modifications
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? album,
    String? albumId,
    int? duration,
    String? coverUrl,
    String? audioUrl,
    int? playCount,
    bool? isLiked,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      duration: duration ?? this.duration,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      playCount: playCount ?? this.playCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
