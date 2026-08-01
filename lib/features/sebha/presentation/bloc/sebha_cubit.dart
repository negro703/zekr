import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/repositories/sebha_repository.dart';
import 'sebha_state.dart';

/// Cubit managing the electronic Sebha state.
///
/// Responsibilities:
/// - Load and persist the Sebha state via [SebhaRepository]
/// - Increment the count with round resets and haptic feedback
/// - Switch between dhikr phrases
/// - Reset the current round
class SebhaCubit extends Cubit<SebhaState> {
  SebhaCubit({required this.repository}) : super(const SebhaInitial());

  /// The repository used to persist and restore the Sebha state.
  final SebhaRepository repository;

  /// The default dhikr phrases available in the Sebha.
  static const List<String> dhikrs = AppConstants.defaultDhikrs;

  /// The target count per round (e.g., 33).
  static const int target = AppConstants.defaultSebhaTarget;

  /// Loads the saved Sebha state from the repository.
  Future<void> loadSebha() async {
    if (state is SebhaLoaded) return;

    emit(const SebhaLoading());

    try {
      final sebha = await repository.loadSebha();
      emit(SebhaLoaded(sebha: sebha));
    } catch (e) {
      emit(
        SebhaError(
          message: 'تعذر تحميل حالة السبحة.',
        ),
      );
    }
  }

  /// Increments the current count.
  ///
  /// - Plays light haptic feedback on each tap.
  /// - Plays medium haptic + resets the round when reaching the target.
  /// - Auto-saves the updated state to storage.
  Future<void> incrementCount() async {
    if (state is! SebhaLoaded) return;

    final loaded = state as SebhaLoaded;
    final current = loaded.sebha;

    // Light haptic on every tap.
    await HapticFeedback.lightImpact();

    if (current.currentCount + 1 >= target) {
      // Round complete: medium haptic, increment rounds, reset count.
      await HapticFeedback.mediumImpact();

      final updated = current.copyWith(
        currentCount: 0,
        totalRounds: current.totalRounds + 1,
      );
      emit(loaded.copyWith(sebha: updated));
      await repository.saveSebha(updated);
    } else {
      // Normal increment.
      final updated = current.copyWith(currentCount: current.currentCount + 1);
      emit(loaded.copyWith(sebha: updated));
      await repository.saveSebha(updated);
    }
  }

  /// Switches to a new dhikr phrase by [newIndex] into [dhikrs].
  ///
  /// Resets the current count and persists the selection.
  Future<void> changeDhikr(int newIndex) async {
    if (state is! SebhaLoaded) return;

    final loaded = state as SebhaLoaded;
    final current = loaded.sebha;

    final safeIndex = newIndex.clamp(0, dhikrs.length - 1).toInt();
    if (safeIndex == current.currentDhikrIndex) return;

    final updated = current.copyWith(
      currentCount: 0,
      currentDhikrIndex: safeIndex,
      currentDhikrText: dhikrs[safeIndex],
    );

    emit(loaded.copyWith(sebha: updated));
    await repository.saveSebha(updated);
  }

  /// Resets the current round counter to 0.
  ///
  /// Keeps total rounds and the active dhikr.
  Future<void> resetCounter() async {
    if (state is! SebhaLoaded) return;

    final loaded = state as SebhaLoaded;
    final current = loaded.sebha;

    if (current.currentCount == 0) return;

    final updated = current.copyWith(currentCount: 0);
    emit(loaded.copyWith(sebha: updated));
    await repository.saveSebha(updated);
  }
}