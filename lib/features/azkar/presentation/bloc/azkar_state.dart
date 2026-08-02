import 'package:equatable/equatable.dart';

import '../../domain/entities/entities.dart';

/// Base state for the Azkar feature.
sealed class AzkarState extends Equatable {
  const AzkarState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
final class AzkarInitial extends AzkarState {
  const AzkarInitial();
}

/// State while categories are being fetched.
final class AzkarCategoriesLoading extends AzkarState {
  const AzkarCategoriesLoading();
}

/// State when categories have been successfully loaded.
final class AzkarCategoriesLoaded extends AzkarState {
  const AzkarCategoriesLoaded({required this.categories});

  /// All available Azkar categories.
  final List<AzkarCategoryEntity> categories;

  @override
  List<Object?> get props => [categories];
}

/// State while a specific category's azkar are being fetched.
final class AzkarLoading extends AzkarState {
  const AzkarLoading({required this.categoryId});

  /// The category being loaded.
  final String categoryId;

  @override
  List<Object?> get props => [categoryId];
}

/// State when azkar for a category have been loaded.
final class AzkarLoaded extends AzkarState {
  const AzkarLoaded({
    required this.categoryId,
    required this.azkar,
    this.progress = const {},
  });

  /// The loaded category.
  final String categoryId;

  /// The list of azkar in this category.
  final List<ZekrEntity> azkar;

  /// Per-zekr tap progress, keyed by zekr `id`.
  ///
  /// Each value is the current tap count (0 → [ZekrEntity.count]).
  final Map<String, int> progress;

  /// Returns the current tap count for [zekrId], defaulting to 0.
  int countFor(String zekrId) => progress[zekrId] ?? 0;

  /// Returns whether the zekr identified by [zekrId] has reached its target.
  bool isComplete(String zekrId, int target) => countFor(zekrId) >= target;

  /// Creates a copy with the given [progress] map.
  AzkarLoaded copyWith({Map<String, int>? progress}) {
    return AzkarLoaded(
      categoryId: categoryId,
      azkar: azkar,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [categoryId, azkar, progress];
}

/// State when an error occurred.
final class AzkarError extends AzkarState {
  const AzkarError({required this.message});

  /// A user-friendly error message.
  final String message;

  @override
  List<Object?> get props => [message];
}