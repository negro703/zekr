import '../entities/entities.dart';

/// Repository contract for retrieving Quran data.
///
/// Implementations load and parse Quran pages from the Uthmani
/// script data source (JSON asset, local storage, or network).
abstract interface class QuranRepository {
  /// Returns all 604 Mushaf pages.
  ///
  /// For large datasets, this should be loaded lazily or batched
  /// to avoid excessive memory usage. The default implementation
  /// loads all pages once and caches them in memory.
  Future<List<QuranPageEntity>> getAllPages();

  /// Fetches a single page by its Mushaf [pageNumber] (1–604).
  ///
  /// Returns `null` if the page does not exist.
  Future<QuranPageEntity?> getPage(int pageNumber);

  /// Fetches a range of pages between [startPage] and [endPage] (inclusive).
  ///
  /// This is optimized for pre-loading pages adjacent to the
  /// currently visible page in the reader PageView.
  Future<List<QuranPageEntity>> getPagesInRange(int startPage, int endPage);

  /// Returns the total number of pages (604 for the standard Mushaf).
  Future<int> getTotalPages();
}