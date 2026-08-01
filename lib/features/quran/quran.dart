/// Quran Reader Feature.
///
/// Phase 2: Quran Reader & Advanced Drawer Feature.
/// This module contains:
/// - Domain entities (Ayah, QuranPage) and repository contract
/// - Data models with JSON serialization for Uthmani script
/// - Repository implementation with lazy-loading and in-memory caching
/// - PageView BLoC (upcoming)
/// - Drawer options (upcoming: Tafseer, Index, Bookmarks, Screen Brightness,
///   Page Backgrounds)
library;

export 'data/data.dart';
export 'domain/domain.dart';