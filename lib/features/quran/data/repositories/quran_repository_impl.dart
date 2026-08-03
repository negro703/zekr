import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/errors/errors.dart';
import '../../../../core/utils/quran_page_metadata.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/quran_repository.dart';
import '../models/models.dart';

/// Implementation of [QuranRepository] that loads Quran data from
/// a local JSON asset containing Uthmani script text.
///
/// ## Performance Optimizations
/// - **Lazy loading**: The JSON asset is parsed once on first access and
///   results are cached in memory.
/// - **Page-level cache**: [getPage] serves from an in-memory [Map] with
///   O(1) lookup — no repeated file I/O during PageView scrolling.
/// - **Batch loading**: [getPagesInRange] supports pre-loading adjacent
///   pages without re-parsing the full dataset.
class QuranRepositoryImpl implements QuranRepository {
  QuranRepositoryImpl({this.assetPath = defaultAssetPath});

  /// Default path to the Quran JSON asset (sample pages 1–604).
  ///
  /// Expected structure:
  /// ```json
  /// {
  ///   "meta": { "totalPages": 604 },
  ///   "pages": [
  ///     {
  ///       "pageNumber": 1,
  ///       "juzNumber": 1,
  ///       "surahName": "الفاتحة",
  ///       "ayahs": [
  ///         { "id": 1, "surahNumber": 1, "surahName": "الفاتحة",
  ///           "ayahNumber": 1, "juzNumber": 1, "pageNumber": 1,
  ///           "text": "بِسْمِ اللَّهِ..." }
  ///       ]
  ///     }
  ///   ]
  /// }
  /// ```
  static const String defaultAssetPath = 'assets/data/quran.json';

  /// Path to the Quran JSON asset bundle.
  final String assetPath;

  /// In-memory cache of all parsed pages, keyed by page number.
  Map<int, QuranPageModel>? _pagesCache;

  /// Total page count (cached after first load).
  int? _totalPages;

  @override
  Future<List<QuranPageEntity>> getAllPages() async {
    final pages = await _loadAllPages();
    return List<QuranPageEntity>.unmodifiable(pages.values);
  }

  @override
  Future<QuranPageEntity?> getPage(int pageNumber) async {
    final pages = await _loadAllPages();
    final page = pages[pageNumber];
    if (page != null) return page;

    // For valid Mushaf pages (1–604) that aren't present in the JSON
    // sample dataset, return a structural placeholder with the correct
    // Juz number so the reader footer renders accurately.
    if (pageNumber >= 1 && pageNumber <= kTotalMushafPages) {
      return QuranPageModel(
        pageNumber: pageNumber,
        juzNumber: juzForPage(pageNumber),
        surahName: null,
        ayahs: const [],
      );
    }
    return null; // Outside the 604-page Mushaf range.
  }

  @override
  Future<List<QuranPageEntity>> getPagesInRange(
    int startPage,
    int endPage,
  ) async {
    final pages = await _loadAllPages();

    final clampedStart = startPage.clamp(1, pages.length).toInt();
    final clampedEnd = endPage.clamp(1, pages.length).toInt();

    if (clampedStart > clampedEnd) {
      return const [];
    }

    return List<QuranPageEntity>.unmodifiable(
      List.generate(
        clampedEnd - clampedStart + 1,
        (index) => pages[clampedStart + index]!,
      ),
    );
  }

  @override
  Future<int> getTotalPages() async {
    if (_totalPages != null) return _totalPages!;
    await _loadAllPages();
    // Fall back to the canonical Mushaf page count if the dataset
    // did not declare one.
    return _totalPages ?? kTotalMushafPages;
  }

  // ─── Internal Helpers ────────────────────────────────────────────────────────

  /// Loads and parses the full Quran dataset once, caching the result.
  ///
  /// Subsequent calls return the in-memory cache (O(1) access).
  Future<Map<int, QuranPageModel>> _loadAllPages() async {
    if (_pagesCache != null) return _pagesCache!;

    try {
      // Load the raw JSON string from the Flutter asset bundle.
      final rawJson = await rootBundle.loadString(assetPath);

      // Decode the top-level JSON object.
      final decoded = json.decode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid Quran JSON structure.');
      }

      final rawPages = decoded['pages'];
      if (rawPages is! List) {
        throw const FormatException('Missing "pages" array in Quran JSON.');
      }

      // Parse all page models.
      final pages = <int, QuranPageModel>{};
      for (final rawPage in rawPages) {
        final page = QuranPageModel.fromJson(rawPage as Map<String, dynamic>);
        pages[page.pageNumber] = page;
      }

      // Determine the expected page count from metadata when available.
      final meta = decoded['meta'];
      if (meta is Map<String, dynamic>) {
        final declaredTotal = meta['totalPages'];
        if (declaredTotal is int && declaredTotal > 0) {
          _totalPages = declaredTotal;
        }
      }

      // Cache the result.
      _pagesCache = pages;
      return pages;
    } on AppException {
      rethrow;
    } on FormatException catch (e) {
      throw ResourceLoadException(
        message: 'Quran data is corrupted or malformed.',
        cause: e,
      );
    } catch (e) {
      throw ResourceLoadException(
        message: 'Failed to load Quran data from assets.',
        cause: e,
      );
    }
  }
}
