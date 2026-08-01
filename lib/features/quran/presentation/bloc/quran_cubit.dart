import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/errors.dart';
import '../../../../core/services/services.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/quran_repository.dart';
import 'quran_state.dart';

/// Cubit managing the Quran reader state.
///
/// Responsibilities:
/// - Load Quran pages from the [QuranRepository]
/// - Track the currently active page in the PageView
/// - Persist and restore the last-read page via [KeyValueStorage]
/// - Restore and jump to a saved bookmark
class QuranCubit extends Cubit<QuranState> {
  QuranCubit({
    required this.repository,
    KeyValueStorage? keyValueStorage,
  })  : keyValueStorage = keyValueStorage ?? LocalStorageService.instance,
        super(const QuranInitial());

  /// The repository used to load Quran pages.
  final QuranRepository repository;

  /// Key-value storage for persisting reading state.
  final KeyValueStorage keyValueStorage;

  /// The currently loaded page index in the PageView (0-based).
  int _currentPageIndex = 0;

  /// Total pages declared by the dataset metadata.
  int _totalPages = AppConstants.totalPages;

  /// Loads all Quran pages from the repository.
  ///
  /// Restores the last-read page and bookmark from local storage
  /// once pages are loaded.
  Future<void> loadQuranPages() async {
    // Don't reload if already loaded successfully.
    if (state is QuranLoaded) return;

    emit(const QuranLoading());

    try {
      // Fetch total pages and all pages in parallel.
      final results = await Future.wait([
        repository.getTotalPages(),
        repository.getAllPages(),
      ]);

      _totalPages = results[0] as int;
      final pages = results[1] as List<QuranPageEntity>;

      if (pages.isEmpty) {
        emit(
          const QuranError(
            message: 'لا توجد صفحات متاحة في المصحف.',
            code: 'EMPTY_QURAN',
          ),
        );
        return;
      }

      // Restore last-read page from local storage.
      final savedPage = _readLastReadPage();
      // Restore bookmark from local storage.
      final savedBookmark = _readBookmarkPage();

      // Clamp saved page to valid range.
      final restoredPage = (savedPage != null && savedPage >= 1)
          ? savedPage.clamp(1, _totalPages).toInt()
          : pages.first.pageNumber;

      // Find the index of the restored page in the loaded list.
      _currentPageIndex = pages.indexWhere((p) => p.pageNumber == restoredPage);
      if (_currentPageIndex < 0) {
        _currentPageIndex = 0;
      }

      emit(
        QuranLoaded(
          currentPageNumber: restoredPage,
          totalPages: _totalPages,
          pages: pages,
          bookmarkPageNumber: savedBookmark,
        ),
      );
    } on AppException catch (e) {
      emit(QuranError(message: e.message, code: e.code));
    } catch (e) {
      emit(
        QuranError(
          message: 'تعذر تحميل صفحات القرآن الكريم.',
          code: 'QURAN_LOAD_ERROR',
        ),
      );
    }
  }

  /// Changes the active page in the reader.
  ///
  /// Persists the new page to local storage so reading
  /// resumes from the same page on next app launch.
  void changePage(int pageNumber) {
    if (state is! QuranLoaded) return;

    final loaded = state as QuranLoaded;

    // Clamp to valid range.
    final safePage = pageNumber.clamp(1, loaded.totalPages).toInt();
    if (safePage == loaded.currentPageNumber) return;

    // Persist last-read page.
    keyValueStorage.setInt(AppConstants.lastReadPagePrefKey, safePage);

    // Find the index in the pages list.
    final newIndex = loaded.pages.indexWhere((p) => p.pageNumber == safePage);
    if (newIndex >= 0) {
      _currentPageIndex = newIndex;
    } else {
      _currentPageIndex = safePage - 1;
    }

    emit(loaded.copyWithPage(safePage));
  }

  /// Jumps to the saved bookmark page, or the first page if none exists.
  ///
  /// If no bookmark is set, the cubit falls back to the current page.
  void jumpToBookmark() {
    if (state is! QuranLoaded) return;

    final loaded = state as QuranLoaded;
    final bookmark = loaded.bookmarkPageNumber;

    if (bookmark == null) {
      // No bookmark — fall back to the first page.
      final firstPage = loaded.pages.isNotEmpty
          ? loaded.pages.first.pageNumber
          : 1;
      changePage(firstPage);
      return;
    }

    changePage(bookmark);
  }

  /// Sets (or clears) the current bookmark at [pageNumber].
  ///
  /// Pass `null` to clear the bookmark. Persists to local storage.
  void setBookmark(int? pageNumber) {
    if (state is! QuranLoaded) return;

    final loaded = state as QuranLoaded;

    if (pageNumber != null) {
      final safePage = pageNumber.clamp(1, loaded.totalPages).toInt();
      keyValueStorage.setInt(AppConstants.quranBookmarkPrefKey, safePage);
      emit(loaded.copyWithBookmark(safePage));
    } else {
      keyValueStorage.remove(AppConstants.quranBookmarkPrefKey);
      emit(loaded.copyWithBookmark(null));
    }
  }

  /// Returns the 0-based page index for the PageView controller.
  int get currentPageIndex => _currentPageIndex;

  // ─── Local Storage Helpers ──────────────────────────────────────────────────

  int? _readLastReadPage() {
    final saved = keyValueStorage.getInt(AppConstants.lastReadPagePrefKey);
    if (saved == null || saved < 1) return null;
    return saved;
  }

  int? _readBookmarkPage() {
    final saved = keyValueStorage.getInt(AppConstants.quranBookmarkPrefKey);
    if (saved == null || saved < 1) return null;
    return saved;
  }
}