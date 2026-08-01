import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

/// Fake repository for testing without real asset I/O.
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

/// Wrapper that provides the cubit to the reader page.
Widget _wrap({
  required QuranCubit cubit,
  required Widget child,
}) {
  return MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: BlocProvider<QuranCubit>(
      create: (_) => cubit,
      child: child,
    ),
  );
}

/// Opens the drawer via the menu icon.
Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

/// Scrolls the already-open drawer so [text] becomes visible.
Future<void> _scrollDrawerTo(
  WidgetTester tester, {
  required String text,
  bool tapAfterScroll = false,
}) async {
  final drawerScrollable = find.descendant(
    of: find.byType(Drawer),
    matching: find.byType(Scrollable),
  ).first;

  await tester.scrollUntilVisible(
    find.text(text),
    100,
    scrollable: drawerScrollable,
  );
  await tester.pumpAndSettle();

  if (tapAfterScroll) {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }
}

void main() {
  late _MemoryKeyValueStorage storage;

  setUp(() {
    storage = _MemoryKeyValueStorage();
  });

  group('QuranReaderPage', () {
    testWidgets('displays loading then loaded page', (tester) async {
      final pages = [_buildPage(1), _buildPage(2)];
      final cubit = QuranCubit(
        repository: _FakeQuranRepository(pages: pages, totalPages: 2),
        keyValueStorage: storage,
      );

      await tester.pumpWidget(_wrap(cubit: cubit, child: const QuranReaderPage()));

      // Initial frame shows loading.
      expect(find.text('جاري تحميل المصحف الشريف...'), findsOneWidget);

      // Wait for async load to complete.
      await tester.pumpAndSettle();

      // Loaded state shows app bar and page content.
      expect(find.text('المصحف الشريف'), findsWidgets);
      expect(find.text('سُورَةُ الفَاتِحَة'), findsWidgets);
      expect(find.textContaining('نص الآية للصفحة'), findsWidgets);

      cubit.close();
    });

    testWidgets('shows error state when repository fails', (tester) async {
      final cubit = QuranCubit(
        repository: _FakeQuranRepository(
          pages: const [],
          totalPages: 0,
          error: const ResourceLoadException(
            message: 'Failed to load Quran data.',
          ),
        ),
        keyValueStorage: storage,
      );

      await tester.pumpWidget(_wrap(cubit: cubit, child: const QuranReaderPage()));

      await tester.pumpAndSettle();

      expect(find.text('Failed to load Quran data.'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);

      cubit.close();
    });

    testWidgets('drawer opens with header and section titles',
        (tester) async {
      final pages = [_buildPage(1), _buildPage(2)];
      final cubit = QuranCubit(
        repository: _FakeQuranRepository(pages: pages, totalPages: 2),
        keyValueStorage: storage,
      );

      await tester.pumpWidget(_wrap(cubit: cubit, child: const QuranReaderPage()));
      await tester.pumpAndSettle();

      // Open the drawer via the menu icon.
      await _openDrawer(tester);

      // Verify drawer header and visible section titles are present.
      expect(find.text('المصحف الشريف'), findsWidgets);
      expect(find.text('أدوات القراءة'), findsOneWidget);
      expect(find.text('التنقل'), findsOneWidget);

      // Scroll to the bookmark and extra tools sections (drawer stays open).
      await _scrollDrawerTo(tester, text: 'العلامات المرجعية');
      expect(find.text('العلامات المرجعية'), findsOneWidget);

      // Reset scroll to top, then scroll to extra tools section.
      final drawerScrollable = find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ).first;
      await tester.drag(drawerScrollable, const Offset(0, 500));
      await tester.pumpAndSettle();

      await _scrollDrawerTo(tester, text: 'أدوات إضافية');
      expect(find.text('أدوات إضافية'), findsOneWidget);

      cubit.close();
    });

    testWidgets('bookmark quick action saves and shows snackbar',
        (tester) async {
      final pages = [_buildPage(1), _buildPage(2)];
      final cubit = QuranCubit(
        repository: _FakeQuranRepository(pages: pages, totalPages: 2),
        keyValueStorage: storage,
      );

      await tester.pumpWidget(_wrap(cubit: cubit, child: const QuranReaderPage()));
      await tester.pumpAndSettle();

      // Open drawer.
      await _openDrawer(tester);

      // Tap quick action "حفظ علامة" (visible at the top of the drawer).
      await tester.tap(find.text('حفظ علامة'));
      await tester.pumpAndSettle();

      // Verify bookmark was saved and snackbar shown.
      expect(storage.getInt(AppConstants.quranBookmarkPrefKey), 1);
      expect(find.textContaining('تم حفظ العلامة'), findsOneWidget);

      cubit.close();
    });

    testWidgets('page navigation grid jumps to selected page',
        (tester) async {
      final pages = [_buildPage(1), _buildPage(2)];
      final cubit = QuranCubit(
        repository: _FakeQuranRepository(pages: pages, totalPages: 2),
        keyValueStorage: storage,
      );

      await tester.pumpWidget(_wrap(cubit: cubit, child: const QuranReaderPage()));
      await tester.pumpAndSettle();

      // Open drawer, then scroll to and tap "الصفحات".
      await _openDrawer(tester);
      await _scrollDrawerTo(tester, text: 'الصفحات', tapAfterScroll: true);

      // The pages sheet should now be open. Tap page 2 in the grid.
      expect(find.text('انتقال إلى صفحة'), findsOneWidget);
      await tester.tap(find.text('٢').last);
      await tester.pumpAndSettle();

      // Cubit should now be on page 2.
      final loaded = cubit.state as QuranLoaded;
      expect(loaded.currentPageNumber, 2);

      cubit.close();
    });
  });
}