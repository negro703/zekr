import 'package:equatable/equatable.dart';

/// Represents a category of Azkar (e.g., Morning, Evening, Sleep).
///
/// Contains the category identifier, display title, and an icon
/// reference for the UI.
class AzkarCategoryEntity extends Equatable {
  const AzkarCategoryEntity({
    required this.id,
    required this.title,
    required this.icon,
    this.description,
  });

  /// Unique identifier for the category (e.g., 'morning', 'evening').
  final String id;

  /// Display title in Arabic (e.g., 'أذكار الصباح').
  final String title;

  /// Icon name reference for the UI (e.g., 'wb_sunny', 'nights_stay').
  final String icon;

  /// Optional short description shown on the category card.
  final String? description;

  /// Creates a copy with optional field overrides.
  AzkarCategoryEntity copyWith({
    String? id,
    String? title,
    String? icon,
    String? description,
  }) {
    return AzkarCategoryEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, title, icon, description];
}