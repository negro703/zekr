import '../../domain/entities/entities.dart';
import '../../domain/repositories/azkar_repository.dart';
import '../datasources/azkar_local_data_source.dart';

/// Implementation of [AzkarRepository] backed by [AzkarLocalDataSource].
///
/// Provides static Azkar data (Morning, Evening, Sleep, Post-Prayer)
/// with authentic Arabic texts and repetition targets.
class AzkarRepositoryImpl implements AzkarRepository {
  const AzkarRepositoryImpl();

  @override
  Future<List<AzkarCategoryEntity>> getCategories() async {
    return AzkarLocalDataSource.categories;
  }

  @override
  Future<List<ZekrEntity>> getAzkarByCategory(String categoryId) async {
    return AzkarLocalDataSource.azkarFor(categoryId);
  }
}