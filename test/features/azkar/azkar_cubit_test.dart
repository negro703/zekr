import 'package:flutter_test/flutter_test.dart';
import 'package:zekr/features/azkar/azkar.dart';

/// Fake repository for testing the cubit without static data dependency.
class _FakeAzkarRepository implements AzkarRepository {
  _FakeAzkarRepository({
    required this.categories,
    required this.azkar,
    this.error,
  });

  final List<AzkarCategoryEntity> categories;
  final List<ZekrEntity> azkar;
  final Object? error;

  @override
  Future<List<AzkarCategoryEntity>> getCategories() async {
    if (error != null) throw error!;
    return categories;
  }

  @override
  Future<List<ZekrEntity>> getAzkarByCategory(String categoryId) async {
    if (error != null) throw error!;
    return azkar.where((z) => z.categoryId == categoryId).toList();
  }
}

/// Builds a test zekr.
ZekrEntity _zekr(String id, {int count = 3}) => ZekrEntity(
      id: id,
      categoryId: 'morning',
      text: 'نص الذكر $id',
      count: count,
    );

/// Categories for tests.
const _categories = [
  AzkarCategoryEntity(id: 'morning', title: 'أذكار الصباح', icon: 'wb_sunny'),
  AzkarCategoryEntity(id: 'evening', title: 'أذكار المساء', icon: 'nights_stay'),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AzkarCubit', () {
    late List<ZekrEntity> testAzkar;

    setUp(() {
      testAzkar = [_zekr('m1', count: 3), _zekr('m2', count: 1)];
    });

    test('initial state is AzkarInitial', () {
      final cubit = AzkarCubit(
        repository: _FakeAzkarRepository(categories: _categories, azkar: testAzkar),
      );
      expect(cubit.state, isA<AzkarInitial>());
      cubit.close();
    });

    test('loadCategories emits Loading then Loaded', () async {
      final cubit = AzkarCubit(
        repository: _FakeAzkarRepository(categories: _categories, azkar: testAzkar),
      );
      final states = <AzkarState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadCategories();
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(2));
      expect(states[0], isA<AzkarCategoriesLoading>());
      expect(states[1], isA<AzkarCategoriesLoaded>());
      expect((states[1] as AzkarCategoriesLoaded).categories, hasLength(2));

      await sub.cancel();
      cubit.close();
    });

    test('loadCategories emits Error on failure', () async {
      final cubit = AzkarCubit(
        repository: _FakeAzkarRepository(
          categories: _categories,
          azkar: testAzkar,
          error: Exception('fail'),
        ),
      );
      final states = <AzkarState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadCategories();
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(2));
      expect(states[1], isA<AzkarError>());

      await sub.cancel();
      cubit.close();
    });

    test('loadAzkar loads category azkar', () async {
      final cubit = AzkarCubit(
        repository: _FakeAzkarRepository(categories: _categories, azkar: testAzkar),
      );
      await cubit.loadAzkar('morning');
      final loaded = cubit.state as AzkarLoaded;
      expect(loaded.azkar, hasLength(2));
      expect(loaded.categoryId, 'morning');
      cubit.close();
    });

    test('tapZekr increments progress and emits updated state', () {
      final cubit = AzkarCubit(
        repository: _FakeAzkarRepository(categories: _categories, azkar: testAzkar),
      );
      // Synchronously load to simplify state access.
      cubit.emit(AzkarLoaded(categoryId: 'morning', azkar: testAzkar));

      cubit.tapZekr('m1');
      var loaded = cubit.state as AzkarLoaded;
      expect(loaded.countFor('m1'), 1);
      expect(loaded.isComplete('m1', 3), isFalse);

      cubit.tapZekr('m1');
      cubit.tapZekr('m1');
      loaded = cubit.state as AzkarLoaded;
      expect(loaded.countFor('m1'), 3);
      expect(loaded.isComplete('m1', 3), isTrue);

      cubit.close();
    });

    test('tapZekr ignores taps beyond target', () {
      final cubit = AzkarCubit(
        repository: _FakeAzkarRepository(categories: _categories, azkar: testAzkar),
      );
      cubit.emit(AzkarLoaded(categoryId: 'morning', azkar: testAzkar));

      // Tap the m2 (count 1) twice: second tap should be ignored.
      cubit.tapZekr('m2');
      cubit.tapZekr('m2');

      final loaded = cubit.state as AzkarLoaded;
      expect(loaded.countFor('m2'), 1);

      cubit.close();
    });

    test('tapZekr ignores unknown ids', () {
      final cubit = AzkarCubit(
        repository: _FakeAzkarRepository(categories: _categories, azkar: testAzkar),
      );
      cubit.emit(AzkarLoaded(categoryId: 'morning', azkar: testAzkar));
      cubit.tapZekr('unknown');
      expect((cubit.state as AzkarLoaded).progress, isEmpty);
      cubit.close();
    });

    test('resetZekr clears a single zekr progress', () {
      final cubit = AzkarCubit(
        repository: _FakeAzkarRepository(categories: _categories, azkar: testAzkar),
      );
      cubit.emit(AzkarLoaded(categoryId: 'morning', azkar: testAzkar));
      cubit.tapZekr('m1');
      cubit.resetZekr('m1');
      expect((cubit.state as AzkarLoaded).progress, isEmpty);
      cubit.close();
    });

    test('resetCategory clears all progress', () {
      final cubit = AzkarCubit(
        repository: _FakeAzkarRepository(categories: _categories, azkar: testAzkar),
      );
      cubit.emit(AzkarLoaded(categoryId: 'morning', azkar: testAzkar));
      cubit.tapZekr('m1');
      cubit.tapZekr('m2');
      cubit.resetCategory();
      expect((cubit.state as AzkarLoaded).progress, isEmpty);
      cubit.close();
    });
  });
}