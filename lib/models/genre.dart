/// Genre model for music categorization
class Genre {
  final String id;
  final String name;
  final String displayName;
  final String? color;

  Genre({
    required this.id,
    required this.name,
    required this.displayName,
    this.color,
  });

  /// Create Genre from Supabase JSON
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? json['name'] ?? '',
      color: json['color'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'color': color,
    };
  }

  Genre copyWith({
    String? id,
    String? name,
    String? displayName,
    String? color,
  }) {
    return Genre(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      color: color ?? this.color,
    );
  }

  @override
  String toString() => 'Genre(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Genre && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
