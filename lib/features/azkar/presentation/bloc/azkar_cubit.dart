import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/azkar_repository.dart';
import 'azkar_state.dart';

/// Cubit managing the Azkar feature.
///
/// Responsibilities:
/// - Fetch Azkar categories and their contents from [AzkarRepository]
/// - Track per-zekr tap progress with visual completion detection
/// - Trigger haptic feedback on each tap and when a zekr completes
class AzkarCubit extends Cubit<AzkarState> {
  AzkarCubit({required this.repository}) : super(const AzkarInitial());

  /// The repository providing Azkar data.
  final AzkarRepository repository;

  /// Loads all Azkar categories.
  Future<void> loadCategories() async {
    emit(const AzkarCategoriesLoading());

    try {
      final categories = await repository.getCategories();
      emit(AzkarCategoriesLoaded(categories: categories));
    } catch (e) {
      emit(
        AzkarError(message: 'تعذر تحميل الأذكار. حاول مرة أخرى.'),
      );
    }
  }

  /// Loads the azkar for a specific [categoryId].
  Future<void> loadAzkar(String categoryId) async {
    emit(AzkarLoading(categoryId: categoryId));

    try {
      final azkar = await repository.getAzkarByCategory(categoryId);
      emit(AzkarLoaded(categoryId: categoryId, azkar: azkar));
    } catch (e) {
      emit(
        AzkarError(message: 'تعذر تحميل الأذكار. حاول مرة أخرى.'),
      );
    }
  }

  /// Records a tap on the zekr identified by [zekrId].
  ///
  /// Increments the per-zekr counter, plays haptic feedback, and
  /// marks the zekr as complete when its target is reached.
  void tapZekr(String zekrId) {
    if (state is! AzkarLoaded) return;

    final loaded = state as AzkarLoaded;
    final zekr = _findZekr(loaded, zekrId);
    if (zekr == null) return;

    final current = loaded.countFor(zekrId);
    if (current >= zekr.count) return; // Already complete.

    final nextCount = current + 1;
    final isComplete = nextCount >= zekr.count;

    // Light haptic on each tap; medium haptic when the zekr completes.
    if (isComplete) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    final updatedProgress = Map<String, int>.from(loaded.progress)
      ..[zekrId] = nextCount;

    emit(loaded.copyWith(progress: updatedProgress));
  }

  /// Resets the tap counter for a single zekr.
  void resetZekr(String zekrId) {
    if (state is! AzkarLoaded) return;

    final loaded = state as AzkarLoaded;
    if (!loaded.progress.containsKey(zekrId)) return;

    final updatedProgress = Map<String, int>.from(loaded.progress)
      ..remove(zekrId);

    emit(loaded.copyWith(progress: updatedProgress));
  }

  /// Resets all tap counters in the current category.
  void resetCategory() {
    if (state is! AzkarLoaded) return;

    final loaded = state as AzkarLoaded;
    if (loaded.progress.isEmpty) return;

    emit(loaded.copyWith(progress: const {}));
  }

  /// Finds a zekr by [id] within the loaded list.
  ZekrEntity? _findZekr(AzkarLoaded loaded, String id) {
    for (final zekr in loaded.azkar) {
      if (zekr.id == id) return zekr;
    }
    return null;
  }
}