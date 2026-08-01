import 'package:equatable/equatable.dart';

import '../../domain/entities/sebha_entity.dart';

/// Base state for the Sebha feature.
sealed class SebhaState extends Equatable {
  const SebhaState();

  @override
  List<Object?> get props => [];
}

/// State while the Sebha is being loaded from storage.
final class SebhaInitial extends SebhaState {
  const SebhaInitial();
}

/// State while the saved Sebha state is being restored.
final class SebhaLoading extends SebhaState {
  const SebhaLoading();
}

/// State when the Sebha is ready and interactive.
final class SebhaLoaded extends SebhaState {
  const SebhaLoaded({required this.sebha});

  /// The current Sebha entity state (count, rounds, dhikr).
  final SebhaEntity sebha;

  /// Creates a copy with a new entity.
  SebhaLoaded copyWith({SebhaEntity? sebha}) {
    return SebhaLoaded(sebha: sebha ?? this.sebha);
  }

  @override
  List<Object?> get props => [sebha];
}

/// State when loading the Sebha failed.
final class SebhaError extends SebhaState {
  const SebhaError({required this.message});

  /// A user-friendly error message.
  final String message;

  @override
  List<Object?> get props => [message];
}