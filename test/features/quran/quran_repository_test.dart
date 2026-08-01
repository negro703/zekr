import 'package:flutter_test/flutter_test.dart';
import 'package:zekr/features/quran/quran.dart';

void main() {
  group('AyahModel', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'id': 1,
        'surahNumber': 1,
        'surahName': 'سُورَةُ الفَاتِحَة',
        'ayahNumber': 1,
        'juzNumber': 1,
        'pageNumber': 1,
        'text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      };

      final ayah = AyahModel.fromJson(json);

      expect(ayah.id, 1);
      expect(ayah.surahNumber, 1);
      expect(ayah.surahName, 'سُورَةُ الفَاتِحَة');
      expect(ayah.ayahNumber, 1);
      expect(ayah.juzNumber, 1);
      expect(ayah.pageNumber, 1);
      expect(ayah.text, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
    });

    test('toJson round-trips correctly', () {
      final original = AyahModel(
        id: 7,
        ayahNumber: 7,
        text: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ',
        pageNumber: 1,
        surahNumber: 1,
        surahName: 'سُورَةُ الفَاتِحَة',
        juzNumber: 1,
      );

      final json = original.toJson();
      final restored = AyahModel.fromJson(json);

      expect(restored, original);
    });

    test('fromEntity preserves all fields', () {
      final entity = AyahEntity(
        id: 8,
        ayahNumber: 1,
        text: 'الم',
        pageNumber: 2,
        surahNumber: 2,
        surahName: 'سُورَةُ البَقَرَة',
        juzNumber: 1,
      );

      final model = AyahModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.ayahNumber, entity.ayahNumber);
      expect(model.text, entity.text);
      expect(model.pageNumber, entity.pageNumber);
      expect(model.surahNumber, entity.surahNumber);
      expect(model.surahName, entity.surahName);
      expect(model.juzNumber, entity.juzNumber);
    });
  });

  group('QuranPageModel', () {
    test('fromJson parses page with ayahs correctly', () {
      final json = {
        'pageNumber': 1,
        'juzNumber': 1,
        'surahName': 'سُورَةُ الفَاتِحَة',
        'ayahs': [
          {
            'id': 1,
            'surahNumber': 1,
            'surahName': 'سُورَةُ الفَاتِحَة',
            'ayahNumber': 1,
            'juzNumber': 1,
            'pageNumber': 1,
            'text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          }
        ],
      };

      final page = QuranPageModel.fromJson(json);

      expect(page.pageNumber, 1);
      expect(page.juzNumber, 1);
      expect(page.surahName, 'سُورَةُ الفَاتِحَة');
      expect(page.ayahs, hasLength(1));
      expect(page.ayahs.first, isA<AyahModel>());
      expect(page.ayahs.first.text, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
    });

    test('fromJson handles empty ayahs list', () {
      final json = {
        'pageNumber': 1,
        'juzNumber': 1,
        'surahName': null,
        'ayahs': <dynamic>[],
      };

      final page = QuranPageModel.fromJson(json);

      expect(page.pageNumber, 1);
      expect(page.ayahs, isEmpty);
      expect(page.surahName, isNull);
    });

    test('toJson round-trips correctly', () {
      final original = QuranPageModel(
        pageNumber: 1,
        juzNumber: 1,
        surahName: 'سُورَةُ الفَاتِحَة',
        ayahs: const [
          AyahModel(
            id: 1,
            ayahNumber: 1,
            text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            pageNumber: 1,
            surahNumber: 1,
            surahName: 'سُورَةُ الفَاتِحَة',
            juzNumber: 1,
          ),
        ],
      );

      final json = original.toJson();
      final restored = QuranPageModel.fromJson(json);

      expect(restored, original);
    });
  });

  group('QuranRepositoryImpl', () {
    late QuranRepositoryImpl repository;

    setUp(() {
      repository = QuranRepositoryImpl();
    });

    testWidgets('loads pages from asset and parses correctly',
        (tester) async {
      final pages = await tester.runAsync(() => repository.getAllPages());

      expect(pages, isNotEmpty);
      expect(pages!.length, 2); // Sample dataset has 2 pages
    });

    testWidgets('getPage returns the correct page', (tester) async {
      final page = await tester.runAsync(() => repository.getPage(1));

      expect(page, isNotNull);
      expect(page!.pageNumber, 1);
      expect(page.ayahs, isNotEmpty);
    });

    testWidgets('getPage returns null for non-existent page', (tester) async {
      final page = await tester.runAsync(() => repository.getPage(999));

      expect(page, isNull);
    });

    testWidgets('getPagesInRange returns clamped range', (tester) async {
      final pages = await tester.runAsync(
        () => repository.getPagesInRange(1, 2),
      );

      expect(pages, hasLength(2));
      expect(pages!.first.pageNumber, 1);
      expect(pages.last.pageNumber, 2);
    });

    testWidgets('getTotalPages returns metadata-declared total',
        (tester) async {
      final total = await tester.runAsync(() => repository.getTotalPages());

      expect(total, 604); // From meta.totalPages in sample dataset
    });
  });
}