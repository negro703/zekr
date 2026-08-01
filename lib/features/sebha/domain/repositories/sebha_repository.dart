import '../entities/sebha_entity.dart';

/// Repository contract for persisting the electronic Sebha state.
///
/// Implementations save and restore the current count, total rounds,
/// and active dhikr so the user's progress never resets across app restarts.
abstract interface class SebhaRepository {
  /// Loads the saved Sebha state, or returns a fresh [SebhaEntity]
  /// if nothing has been saved yet.
  Future<SebhaEntity> loadSebha();

  /// Persists the current Sebha state.
  Future<void> saveSebha(SebhaEntity sebha);
}