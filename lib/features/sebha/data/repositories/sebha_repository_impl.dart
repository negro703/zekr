import '../../../../core/constants/constants.dart';
import '../../../../core/services/services.dart';
import '../../domain/entities/sebha_entity.dart';
import '../../domain/repositories/sebha_repository.dart';

/// Implementation of [SebhaRepository] backed by [KeyValueStorage]
/// (SharedPreferences via our core service).
///
/// Persists:
/// - Current count (`sebha_count`)
/// - Total completed rounds (`sebha_total_rounds`)
/// - Active dhikr index (`sebha_dhikr_index`)
class SebhaRepositoryImpl implements SebhaRepository {
  SebhaRepositoryImpl({required this.storage});

  final KeyValueStorage storage;

  @override
  Future<SebhaEntity> loadSebha() async {
    final count = storage.getInt(AppConstants.sebhaCountPrefKey) ?? 0;
    final rounds = storage.getInt(AppConstants.sebhaTotalRoundsPrefKey) ?? 0;
    final dhikrIndex = storage.getInt(AppConstants.sebhaDhikrIndexPrefKey) ?? 0;

    final safeIndex =
        dhikrIndex.clamp(0, AppConstants.defaultDhikrs.length - 1).toInt();
    final text = AppConstants.defaultDhikrs[safeIndex];

    return SebhaEntity(
      currentCount: count.clamp(0, AppConstants.defaultSebhaTarget).toInt(),
      totalRounds: rounds,
      currentDhikrIndex: safeIndex,
      currentDhikrText: text,
    );
  }

  @override
  Future<void> saveSebha(SebhaEntity sebha) async {
    await storage.setInt(AppConstants.sebhaCountPrefKey, sebha.currentCount);
    await storage.setInt(
      AppConstants.sebhaTotalRoundsPrefKey,
      sebha.totalRounds,
    );
    await storage.setInt(
      AppConstants.sebhaDhikrIndexPrefKey,
      sebha.currentDhikrIndex,
    );
  }
}