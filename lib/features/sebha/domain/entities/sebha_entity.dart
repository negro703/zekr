import 'package:equatable/equatable.dart';

/// Represents the state of the electronic Sebha.
///
/// Tracks the current tap count, total completed rounds, and the
/// active dhikr phrase being recited.
class SebhaEntity extends Equatable {
  const SebhaEntity({
    this.currentCount = 0,
    this.totalRounds = 0,
    this.currentDhikrIndex = 0,
    this.currentDhikrText = 'سُبْحَانَ الله',
  });

  /// The current count within the active round (0–target).
  final int currentCount;

  /// Total completed rounds (each round = [target] taps).
  final int totalRounds;

  /// Index into the shared dhikr phrases list.
  final int currentDhikrIndex;

  /// The display text of the active dhikr.
  final String currentDhikrText;

  /// Creates a copy with optional field overrides.
  SebhaEntity copyWith({
    int? currentCount,
    int? totalRounds,
    int? currentDhikrIndex,
    String? currentDhikrText,
  }) {
    return SebhaEntity(
      currentCount: currentCount ?? this.currentCount,
      totalRounds: totalRounds ?? this.totalRounds,
      currentDhikrIndex: currentDhikrIndex ?? this.currentDhikrIndex,
      currentDhikrText: currentDhikrText ?? this.currentDhikrText,
    );
  }

  @override
  List<Object?> get props => [
        currentCount,
        totalRounds,
        currentDhikrIndex,
        currentDhikrText,
      ];
}