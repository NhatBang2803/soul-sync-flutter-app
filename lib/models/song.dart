class Song {
  final String id;
  final String title;
  final List<String> artistNames;
  final List<String> artistIds;
  final String? album;
  final String? albumId;
  final int duration; // in seconds
  final String? coverUrl;
  final String? audioUrl;
  final int playCount;
  final String? genre;
  bool isLiked;
  // Podcast support
  final bool isPodcast;
  final String? podcastId;

  Song({
    required this.id,
    required this.title,
    required this.artistNames,
    required this.artistIds,
    this.album,
    this.albumId,
    required this.duration,
    this.coverUrl,
    this.audioUrl,
    this.playCount = 0,
    this.genre,
    this.isLiked = false,
    this.isPodcast = false,
    this.podcastId,
  });

  /// Get primary artist name (first in list)
  String get artist =>
      artistNames.isNotEmpty ? artistNames.first : 'Unknown Artist';

  /// Get all artists as comma-separated string
  String get allArtists => artistNames.join(', ');

  /// Get primary artist ID
  String? get artistId => artistIds.isNotEmpty ? artistIds.first : null;

  /// Create Song from Supabase JSON (snake_case)
  factory Song.fromJson(Map<String, dynamic> json) {
    // Handle multiple artists from songs_with_artists view
    List<String> artistNames = [];
    List<String> artistIds = [];

    if (json['artist_names_array'] != null &&
        json['artist_names_array'] is List) {
      artistNames = List<String>.from(json['artist_names_array']);
    } else if (json['artist_name'] != null) {
      // Single artist name (could be comma-separated from STRING_AGG)
      final name = json['artist_name'].toString();
      artistNames = name.contains(',') ? name.split(', ') : [name];
    } else if (json['artistName'] != null) {
      artistNames = [json['artistName'].toString()];
    } else {
      artistNames = ['Unknown Artist'];
    }

    if (json['artist_ids'] != null && json['artist_ids'] is List) {
      artistIds = List<String>.from(
        json['artist_ids'].map((e) => e.toString()),
      );
    } else if (json['artist_id'] != null) {
      artistIds = [json['artist_id'].toString()];
    }

    return Song(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['songName'] ?? 'Unknown',
      artistNames: artistNames,
      artistIds: artistIds,
      album: json['album_name'] ?? json['albumName'],
      albumId: json['album_id']?.toString(),
      duration: json['duration'] ?? 0,
      coverUrl: json['cover_url'] ?? json['coverUrl'],
      audioUrl: json['audio_url'] ?? json['audioUrl'],
      playCount: json['play_count'] ?? 0,
      genre: json['genre_name'] ?? json['genre'],
      isLiked: json['is_liked'] ?? false,
      isPodcast: json['isPodcast'] == true || json['is_podcast'] == true,
      podcastId:
          json['podcastId']?.toString() ?? json['podcast_id']?.toString(),
    );
  }

  /// Create Song from player format (camelCase from AudioPlayerService)
  factory Song.fromPlayerFormat(Map<String, dynamic> json) {
    List<String> artistNames = [];

    if (json['artistNames'] != null && json['artistNames'] is List) {
      artistNames = List<String>.from(json['artistNames']);
    } else if (json['artistName'] != null) {
      final name = json['artistName'].toString();
      artistNames = name.contains(',') ? name.split(', ') : [name];
    } else {
      artistNames = ['Unknown Artist'];
    }

    return Song(
      id: json['id']?.toString() ?? '',
      title: json['songName'] ?? json['title'] ?? 'Unknown',
      artistNames: artistNames,
      artistIds: json['artistIds'] != null && json['artistIds'] is List
          ? List<String>.from(json['artistIds'].map((e) => e.toString()))
          : [],
      album: json['albumName'] ?? json['album_name'],
      albumId: json['albumId']?.toString(),
      duration: json['duration'] ?? 0,
      coverUrl: json['coverUrl'] ?? json['cover_url'],
      audioUrl: json['audioUrl'] ?? json['audio_url'],
      playCount: 0,
      isLiked: false,
      isPodcast: json['isPodcast'] == true,
      podcastId: json['podcastId']?.toString(),
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_name': allArtists,
      'artist_names': artistNames,
      'artist_ids': artistIds,
      'album_name': album,
      'album_id': albumId,
      'duration': duration,
      'cover_url': coverUrl,
      'audio_url': audioUrl,
      'play_count': playCount,
      'genre': genre,
      'is_liked': isLiked,
      'is_podcast': isPodcast,
      'podcast_id': podcastId,
    };
  }

  /// Convert to player format (camelCase for AudioPlayerService)
  Map<String, dynamic> toPlayerFormat() {
    return {
      'id': id,
      'songName': title,
      'artistName': allArtists,
      'artistNames': artistNames,
      'artistIds': artistIds,
      'albumName': album,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
      'duration': duration,
      'isPodcast': isPodcast,
      'podcastId': podcastId,
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
    List<String>? artistNames,
    List<String>? artistIds,
    String? album,
    String? albumId,
    int? duration,
    String? coverUrl,
    String? audioUrl,
    int? playCount,
    String? genre,
    bool? isLiked,
    bool? isPodcast,
    String? podcastId,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artistNames: artistNames ?? this.artistNames,
      artistIds: artistIds ?? this.artistIds,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      duration: duration ?? this.duration,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      playCount: playCount ?? this.playCount,
      genre: genre ?? this.genre,
      isLiked: isLiked ?? this.isLiked,
      isPodcast: isPodcast ?? this.isPodcast,
      podcastId: podcastId ?? this.podcastId,
    );
  }

  @override
  String toString() => 'Song(id: $id, title: $title, artists: $allArtists)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
