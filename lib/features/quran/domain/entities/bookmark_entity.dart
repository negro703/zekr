/// A bookmark for a specific Quran page.
class BookmarkEntity {
  const BookmarkEntity({
    required this.pageNumber,
    required this.createdAt,
    this.label,
  });

  /// The Mushaf page number (1–604).
  final int pageNumber;

  /// Timestamp (milliseconds since epoch) when the bookmark was created.
  final int createdAt;

  /// Optional user-facing label.
  final String? label;

  /// Creates a [BookmarkEntity] from a JSON map.
  factory BookmarkEntity.fromJson(Map<String, dynamic> json) {
    return BookmarkEntity(
      pageNumber: json['pageNumber'] as int,
      createdAt: json['createdAt'] as int? ?? 0,
      label: json['label'] as String?,
    );
  }

  /// Serializes this bookmark to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'createdAt': createdAt,
      if (label != null) 'label': label,
    };
  }

  BookmarkEntity copyWith({int? pageNumber, int? createdAt, String? label}) {
    return BookmarkEntity(
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt ?? this.createdAt,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BookmarkEntity && other.pageNumber == pageNumber;

  @override
  int get hashCode => pageNumber.hashCode;
}