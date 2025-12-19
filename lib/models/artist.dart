class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final int followers;
  final String? bio;

  Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.followers = 0,
    this.bio,
  });

  /// Create Artist from Supabase JSON
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Artist',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      followers: json['followers'] ?? 0,
      bio: json['bio'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'followers': followers,
      'bio': bio,
    };
  }

  /// Format followers count
  String get formattedFollowers {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }

  Artist copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? followers,
    String? bio,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      followers: followers ?? this.followers,
      bio: bio ?? this.bio,
    );
  }

  @override
  String toString() => 'Artist(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
