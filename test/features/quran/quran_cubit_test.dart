import 'package:flutter_test/flutter_test.dart';
import 'package:zekr/core/core.dart';
import 'package:zekr/features/quran/quran.dart';

/// In-memory [KeyValueStorage] for testing without platform plugins.
class _MemoryKeyValueStorage implements KeyValueStorage {
  final Map<String, Object> _store = {};

  @override
  String? getString(String key, {String? defaultValue}) =>
      _store[key] as String? ?? defaultValue;

  @override
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  @override
  int? getInt(String key, {int? defaultValue}) =>
      _store[key] as int? ?? defaultValue;

  @override
  Future<void> setInt(String key, int value) async {
    _store[key] = value;
  }

  @override
  bool? getBool(String key, {bool? defaultValue}) =>
      _store[key] as bool? ?? defaultValue;

  @override
  Future<void> setBool(String key, bool value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }
}

/// Fake repository for testing the cubit without real asset I/O.
class _FakeQuranRepository implements QuranRepository {
  _FakeQuranRepository({
    required this.pages,
    required this.totalPages,
    this.error,
  });

  final List<QuranPageEntity> pages;
  final int totalPages;
  final Object? error;

  @override
  Future<List<QuranPageEntity>> getAllPages() async {
    if (error != null) throw error!;
    return pages;
  }

  @override
  Future<QuranPageEntity?> getPage(int pageNumber) async {
    if (error != null) throw error!;
    for (final page in pages) {
      if (page.pageNumber == pageNumber) return page;
    }
    return null;
  }

  @override
  Future<List<QuranPageEntity>> getPagesInRange(
    int startPage,
    int endPage,
  ) async {
    if (error != null) throw error!;
    return pages
        .where((p) => p.pageNumber >= startPage && p.pageNumber <= endPage)
        .toList();
  }

  @override
  Future<int> getTotalPages() async {
    if (error != null) throw error!;
    return totalPages;
  }
}

/// Builds a simple test page with one ayah.
QuranPageModel _buildPage(int pageNumber, {int juzNumber = 1}) {
  return QuranPageModel(
    pageNumber: pageNumber,
    juzNumber: juzNumber,
    surahName: 'سُورَةُ الفَاتِحَة',
    ayahs: [
      AyahModel(
        id: pageNumber * 10,
        ayahNumber: 1,
        text: 'نص الآية للصفحة $pageNumber',
        pageNumber: pageNumber,
        surahNumber: 1,
        surahName: 'سُورَةُ الفَاتِحَة',
        juzNumber: juzNumber,
      ),
    ],
  );
}

void main() {
  late List<QuranPageEntity> testPages;
  late _MemoryKeyValueStorage storage;

  setUp(() {
    testPages = [_buildPage(1), _buildPage(2), _buildPage(3)];
    storage = _MemoryKeyValueStorage();
  });

  /// Helper to create a cubit with the shared storage and repo.
  QuranCubit buildCubit({Object? error}) {
    return QuranCubit(
      repository: _FakeQuranRepository(
        pages: testPages,
        totalPages: 3,
        error: error,
      ),
      keyValueStorage: storage,
    );
  }

  group('QuranCubit', () {
    test('initial state is QuranInitial', () {
      final cubit = buildCubit();

      expect(cubit.state, isA<QuranInitial>());
      expect(cubit.currentPageIndex, 0);

      cubit.close();
    });

    test('loadQuranPages emits Loading then Loaded', () async {
      final cubit = buildCubit();

      final states = <QuranState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadQuranPages();
      // Flush microtasks so the broadcast stream delivers both states.
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(2));
      expect(states[0], isA<QuranLoading>());
      expect(states[1], isA<QuranLoaded>());

      final loaded = states[1] as QuranLoaded;
      expect(loaded.currentPageNumber, 1);
      expect(loaded.totalPages, 3);
      expect(loaded.pages, hasLength(3));
      expect(loaded.bookmarkPageNumber, isNull);

      await subscription.cancel();
      cubit.close();
    });

    test('loadQuranPages restores last-read page from storage', () async {
      storage.setInt(AppConstants.lastReadPagePrefKey, 2);

      final cubit = buildCubit();
      await cubit.loadQuranPages();

      final loaded = cubit.state as QuranLoaded;
      expect(loaded.currentPageNumber, 2);
      expect(cubit.currentPageIndex, 1);

      cubit.close();
    });

    test('loadQuranPages restores bookmark from storage', () async {
      storage.setInt(AppConstants.quranBookmarkPrefKey, 3);

      final cubit = buildCubit();
      await cubit.loadQuranPages();

      final loaded = cubit.state as QuranLoaded;
      expect(loaded.bookmarkPageNumber, 3);

      cubit.close();
    });

    test('loadQuranPages emits Error when repository fails', () async {
      final cubit = buildCubit(
        error: const ResourceLoadException(
          message: 'Failed to load Quran data.',
        ),
      );

      final states = <QuranState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadQuranPages();
      // Flush microtasks so the broadcast stream delivers both states.
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(2));
      expect(states[0], isA<QuranLoading>());
      expect(states[1], isA<QuranError>());

      final error = states[1] as QuranError;
      expect(error.message, 'Failed to load Quran data.');
      expect(error.code, 'RESOURCE_LOAD_ERROR');

      await subscription.cancel();
      cubit.close();
    });

    test('changePage updates current page and persists to storage', () async {
      final cubit = buildCubit();
      await cubit.loadQuranPages();

      cubit.changePage(2);

      final loaded = cubit.state as QuranLoaded;
      expect(loaded.currentPageNumber, 2);
      expect(cubit.currentPageIndex, 1);

      // Verify persistence.
      final saved = storage.getInt(AppConstants.lastReadPagePrefKey);
      expect(saved, 2);

      cubit.close();
    });

    test('changePage clamps out-of-range values', () async {
      final cubit = buildCubit();
      await cubit.loadQuranPages();

      cubit.changePage(999);

      final loaded = cubit.state as QuranLoaded;
      expect(loaded.currentPageNumber, 3);

      cubit.changePage(0);

      final loadedAfterZero = cubit.state as QuranLoaded;
      expect(loadedAfterZero.currentPageNumber, 1);

      cubit.close();
    });

    test('changePage ignores same page', () async {
      final cubit = buildCubit();
      await cubit.loadQuranPages();

      final states = <QuranState>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.changePage(1); // Same as current page.

      expect(states, isEmpty); // No new state emitted.

      await subscription.cancel();
      cubit.close();
    });

    test('setBookmark sets and persists bookmark', () async {
      final cubit = buildCubit();
      await cubit.loadQuranPages();

      cubit.setBookmark(2);

      final loaded = cubit.state as QuranLoaded;
      expect(loaded.bookmarkPageNumber, 2);

      final saved = storage.getInt(AppConstants.quranBookmarkPrefKey);
      expect(saved, 2);

      cubit.close();
    });

    test('setBookmark(null) clears bookmark', () async {
      storage.setInt(AppConstants.quranBookmarkPrefKey, 2);

      final cubit = buildCubit();
      await cubit.loadQuranPages();

      cubit.setBookmark(null);

      final loaded = cubit.state as QuranLoaded;
      expect(loaded.bookmarkPageNumber, isNull);

      final saved = storage.getInt(AppConstants.quranBookmarkPrefKey);
      expect(saved, isNull);

      cubit.close();
    });

    test('jumpToBookmark jumps to saved bookmark', () async {
      storage.setInt(AppConstants.quranBookmarkPrefKey, 3);

      final cubit = buildCubit();
      await cubit.loadQuranPages();

      cubit.jumpToBookmark();

      final loaded = cubit.state as QuranLoaded;
      expect(loaded.currentPageNumber, 3);
      expect(cubit.currentPageIndex, 2);

      cubit.close();
    });

    test('jumpToBookmark falls back to first page when no bookmark', () async {
      final cubit = buildCubit();
      await cubit.loadQuranPages();

      // Move to page 2 first.
      cubit.changePage(2);

      // No bookmark set — should jump to first page.
      cubit.jumpToBookmark();

      final loaded = cubit.state as QuranLoaded;
      expect(loaded.currentPageNumber, 1);

      cubit.close();
    });

    test('loadQuranPages does not reload when already loaded', () async {
      final cubit = buildCubit();
      await cubit.loadQuranPages();

      final states = <QuranState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadQuranPages();

      expect(states, isEmpty); // No new states emitted.

      await subscription.cancel();
      cubit.close();
    });
  });
}