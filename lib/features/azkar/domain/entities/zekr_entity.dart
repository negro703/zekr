import 'package:equatable/equatable.dart';

/// Represents a single Zekr (remembrance phrase) within a category.
///
/// Contains the text to recite, its virtue/description, and the
/// repetition target count.
class ZekrEntity extends Equatable {
  const ZekrEntity({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.count,
    this.description,
  });

  /// Unique identifier for this Zekr.
  final String id;

  /// The category this Zekr belongs to (e.g., 'morning').
  final String categoryId;

  /// The Arabic text of the Zekr.
  final String text;

  /// The repetition target (e.g., 3, 7, 33, 100).
  final int count;

  /// Optional virtue/description (فضل الذكر).
  final String? description;

  /// Creates a copy with optional field overrides.
  ZekrEntity copyWith({
    String? id,
    String? categoryId,
    String? text,
    int? count,
    String? description,
  }) {
    return ZekrEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      text: text ?? this.text,
      count: count ?? this.count,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, categoryId, text, count, description];
}