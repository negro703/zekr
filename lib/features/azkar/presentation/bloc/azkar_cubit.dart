import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage/key_value_storage.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/azkar_repository.dart';
import 'azkar_state.dart';

/// Storage key prefix for persisted Azkar progress.
const String _azkarProgressKeyPrefix = 'azkar_progress';

/// An in-memory [KeyValueStorage] fallback for when no persistent
/// storage is provided (e.g. in unit tests).
class _InMemoryStorage implements KeyValueStorage {
  final Map<String, Object> _store = {};

  @override
  String? getString(String key, {String? defaultValue}) =>
      _store[key] as String? ?? defaultValue;

  @override
  Future<void> setString(String key, String value) async =>
      _store[key] = value;

  @override
  int? getInt(String key, {int? defaultValue}) =>
      _store[key] as int? ?? defaultValue;

  @override
  Future<void> setInt(String key, int value) async =>
      _store[key] = value;

  @override
  bool? getBool(String key, {bool? defaultValue}) =>
      _store[key] as bool? ?? defaultValue;

  @override
  Future<void> setBool(String key, bool value) async =>
      _store[key] = value;

  @override
  Future<void> remove(String key) async => _store.remove(key);
}

/// Cubit managing the Azkar feature.
///
/// Responsibilities:
/// - Fetch Azkar categories and their contents from [AzkarRepository]
/// - Track per-zekr tap progress with visual completion detection
/// - Trigger haptic feedback on each tap and when a zekr completes
/// - Persist and restore tap progress across app restarts via
///   [KeyValueStorage]
///
/// All local-data access is wrapped in defensive try/catch blocks so a
/// corrupted or missing persisted payload can never crash the UI.
class AzkarCubit extends Cubit<AzkarState> {
  AzkarCubit({
    required this.repository,
    KeyValueStorage? keyValueStorage,
  })  : keyValueStorage = keyValueStorage ?? _InMemoryStorage(),
        super(const AzkarInitial());

  /// The repository providing Azkar data.
  final AzkarRepository repository;

  /// Local key-value storage for persisting tap progress.
  final KeyValueStorage keyValueStorage;

  /// Builds the storage key for a category's progress map.
  String _progressKey(String categoryId) =>
      '$_azkarProgressKeyPrefix:$categoryId';

  /// Loads all Azkar categories.
  Future<void> loadCategories() async {
    // Guard against redundant reloads.
    if (state is AzkarCategoriesLoaded) return;

    emit(const AzkarCategoriesLoading());

    try {
      final categories = await repository.getCategories();
      emit(AzkarCategoriesLoaded(categories: categories));
    } catch (e) {
      emit(
        const AzkarError(message: 'تعذر تحميل الأذكار. حاول مرة أخرى.'),
      );
    }
  }

  /// Loads the azkar for a specific [categoryId].
  ///
  /// Also restores any previously persisted tap progress for this
  /// category from [keyValueStorage] using a fully type-safe parser so
  /// corrupted data is ignored instead of throwing.
  Future<void> loadAzkar(String categoryId) async {
    // Ignore redundant loads of the same category.
    final current = state;
    if (current is AzkarLoaded && current.categoryId == categoryId) return;

    emit(AzkarLoading(categoryId: categoryId));

    try {
      final azkar = await repository.getAzkarByCategory(categoryId);
      final progress = _restoreProgress(categoryId);

      if (azkar.isEmpty) {
        // Graceful empty state: emit loaded with an empty list so the
        // UI can show a friendly "no azkar" message instead of crashing.
        emit(AzkarLoaded(categoryId: categoryId, azkar: const []));
        return;
      }

      emit(
        AzkarLoaded(
          categoryId: categoryId,
          azkar: azkar,
          progress: progress,
        ),
      );
    } catch (e) {
      // Never propagate unexpected errors to the UI layer.
      emit(
        const AzkarError(message: 'تعذر تحميل الأذكار. حاول مرة أخرى.'),
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
    if (zekr.count <= 0) return; // Defensive: avoid divide-by-zero.

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
    _persistProgress(loaded.categoryId, updatedProgress);
  }

  /// Resets the tap counter for a single zekr.
  void resetZekr(String zekrId) {
    if (state is! AzkarLoaded) return;

    final loaded = state as AzkarLoaded;
    if (!loaded.progress.containsKey(zekrId)) return;

    final updatedProgress = Map<String, int>.from(loaded.progress)
      ..remove(zekrId);

    emit(loaded.copyWith(progress: updatedProgress));
    _persistProgress(loaded.categoryId, updatedProgress);
  }

  /// Resets all tap counters in the current category.
  void resetCategory() {
    if (state is! AzkarLoaded) return;

    final loaded = state as AzkarLoaded;
    if (loaded.progress.isEmpty) return;

    emit(loaded.copyWith(progress: const {}));
    unawaited(
      keyValueStorage.remove(_progressKey(loaded.categoryId)).catchError(
            (_) {},
          ),
    );
  }

  /// Persists the current progress map for [categoryId].
  void _persistProgress(String categoryId, Map<String, int> progress) {
    unawaited(
      keyValueStorage
          .setString(_progressKey(categoryId), json.encode(progress))
          .catchError((_) { /* ignore persistence errors */ }),
    );
  }

  /// Restores the persisted progress map for [categoryId].
  ///
  /// Uses a fully type-safe parser:
  /// - Non-string keys are skipped.
  /// - Non-integer values are coerced to positive integers.
  /// - Malformed JSON or storage failures return an empty map.
  Map<String, int> _restoreProgress(String categoryId) {
    try {
      final raw = keyValueStorage.getString(_progressKey(categoryId));
      if (raw == null || raw.isEmpty) return {};

      final decoded = json.decode(raw);
      if (decoded is! Map) return {};

      final result = <String, int>{};
      for (final entry in decoded.entries) {
        if (entry.key is! String) continue;
        final value = entry.value;
        if (value is int && value > 0) {
          result[entry.key as String] = value;
        } else if (value is num && value > 0) {
          result[entry.key as String] = value.toInt();
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  /// Finds a zekr by [id] within the loaded list.
  ZekrEntity? _findZekr(AzkarLoaded loaded, String id) {
    for (final zekr in loaded.azkar) {
      if (zekr.id == id) return zekr;
    }
    return null;
  }
}