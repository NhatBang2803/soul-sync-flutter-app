class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final int followers;
  final int monthlyListeners;
  final String? bio;
  final bool isVerified;

  Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.followers = 0,
    this.monthlyListeners = 0,
    this.bio,
    this.isVerified = false,
  });

  /// Create Artist from Supabase JSON
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Artist',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      followers: json['followers'] ?? 0,
      monthlyListeners: json['monthly_listeners'] ?? json['monthlyListeners'] ?? 0,
      bio: json['bio'],
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'followers': followers,
      'monthly_listeners': monthlyListeners,
      'bio': bio,
      'is_verified': isVerified,
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

  /// Format monthly listeners count
  String get formattedMonthlyListeners {
    if (monthlyListeners >= 1000000) {
      return '${(monthlyListeners / 1000000).toStringAsFixed(1)}M người nghe hàng tháng';
    } else if (monthlyListeners >= 1000) {
      return '${(monthlyListeners / 1000).toStringAsFixed(1)}K người nghe hàng tháng';
    }
    return '$monthlyListeners người nghe hàng tháng';
  }

  Artist copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? followers,
    int? monthlyListeners,
    String? bio,
    bool? isVerified,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      followers: followers ?? this.followers,
      monthlyListeners: monthlyListeners ?? this.monthlyListeners,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
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
