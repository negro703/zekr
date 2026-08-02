import '../entities/entities.dart';

/// Repository contract for retrieving Azkar categories and their contents.
///
/// Implementations provide the static Azkar data (Morning, Evening, etc.)
/// from a local data source.
abstract interface class AzkarRepository {
  /// Returns all available Azkar categories.
  Future<List<AzkarCategoryEntity>> getCategories();

  /// Returns the list of Azkar for a specific [categoryId].
  ///
  /// Returns an empty list if the category does not exist.
  Future<List<ZekrEntity>> getAzkarByCategory(String categoryId);
}