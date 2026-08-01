/// Quran Reader Feature.
///
/// Phase 2: Quran Reader & Advanced Drawer Feature.
/// This module contains:
/// - Domain entities (Ayah, QuranPage) and repository contract
/// - Data models with JSON serialization for Uthmani script
/// - Repository implementation with lazy-loading and in-memory caching
/// - QuranCubit state management (loading, page switching, bookmarks,
///   last-read persistence)
/// - Drawer options (upcoming: Tafseer, Index, Bookmarks, Screen Brightness,
///   Page Backgrounds)
library;

export 'data/data.dart';
export 'domain/domain.dart';
export 'presentation/presentation.dart';