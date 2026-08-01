import 'package:flutter_test/flutter_test.dart';
import 'package:zekr/core/core.dart';
import 'package:zekr/features/sebha/sebha.dart';

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

/// Fake repository that can throw and tracks saves.
class _FakeSebhaRepository implements SebhaRepository {
  _FakeSebhaRepository({
    required this.loaded,
    this.error,
  });

  final SebhaEntity loaded;
  final Object? error;

  SebhaEntity? lastSaved;

  @override
  Future<SebhaEntity> loadSebha() async {
    if (error != null) throw error!;
    return loaded;
  }

  @override
  Future<void> saveSebha(SebhaEntity sebha) async {
    lastSaved = sebha;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SebhaCubit', () {
    test('initial state is SebhaInitial', () {
      final cubit = SebhaCubit(
        repository: _FakeSebhaRepository(loaded: const SebhaEntity()),
      );

      expect(cubit.state, isA<SebhaInitial>());

      cubit.close();
    });

    test('loadSebha emits Loading then Loaded', () async {
      final cubit = SebhaCubit(
        repository: _FakeSebhaRepository(loaded: const SebhaEntity()),
      );

      final states = <SebhaState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadSebha();
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(2));
      expect(states[0], isA<SebhaLoading>());
      expect(states[1], isA<SebhaLoaded>());

      final loaded = states[1] as SebhaLoaded;
      expect(loaded.sebha.currentCount, 0);
      expect(loaded.sebha.currentDhikrText, 'سُبْحَانَ الله');

      await subscription.cancel();
      cubit.close();
    });

    test('loadSebha restores saved state from repository', () async {
      final saved = SebhaEntity(
        currentCount: 12,
        totalRounds: 3,
        currentDhikrIndex: 2,
        currentDhikrText: SebhaCubit.dhikrs[2],
      );

      final cubit = SebhaCubit(
        repository: _FakeSebhaRepository(loaded: saved),
      );

      await cubit.loadSebha();

      final loaded = cubit.state as SebhaLoaded;
      expect(loaded.sebha.currentCount, 12);
      expect(loaded.sebha.totalRounds, 3);
      expect(loaded.sebha.currentDhikrIndex, 2);
      expect(loaded.sebha.currentDhikrText, 'اللهُ أَكْبَرُ');

      cubit.close();
    });

    test('loadSebha emits Error when repository fails', () async {
      final cubit = SebhaCubit(
        repository: _FakeSebhaRepository(
          loaded: const SebhaEntity(),
          error: Exception('Storage failure'),
        ),
      );

      final states = <SebhaState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadSebha();
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(2));
      expect(states[0], isA<SebhaLoading>());
      expect(states[1], isA<SebhaError>());

      await subscription.cancel();
      cubit.close();
    });

    test('incrementCount increases count and saves', () async {
      final repo = _FakeSebhaRepository(loaded: const SebhaEntity());
      final cubit = SebhaCubit(repository: repo);

      await cubit.loadSebha();
      await cubit.incrementCount();

      final loaded = cubit.state as SebhaLoaded;
      expect(loaded.sebha.currentCount, 1);
      expect(repo.lastSaved?.currentCount, 1);

      cubit.close();
    });

    test('incrementCount resets after reaching target', () async {
      final repo = _FakeSebhaRepository(
        loaded: SebhaEntity(currentCount: SebhaCubit.target - 1),
      );
      final cubit = SebhaCubit(repository: repo);

      await cubit.loadSebha();
      await cubit.incrementCount();

      final loaded = cubit.state as SebhaLoaded;
      expect(loaded.sebha.currentCount, 0);
      expect(loaded.sebha.totalRounds, 1);
      expect(repo.lastSaved?.totalRounds, 1);

      cubit.close();
    });

    test('changeDhikr switches phrase and resets count', () async {
      final repo = _FakeSebhaRepository(
        loaded: SebhaEntity(currentCount: 10),
      );
      final cubit = SebhaCubit(repository: repo);

      await cubit.loadSebha();
      await cubit.changeDhikr(2);

      final loaded = cubit.state as SebhaLoaded;
      expect(loaded.sebha.currentDhikrIndex, 2);
      expect(loaded.sebha.currentDhikrText, 'اللهُ أَكْبَرُ');
      expect(loaded.sebha.currentCount, 0);
      expect(repo.lastSaved?.currentDhikrIndex, 2);

      cubit.close();
    });

    test('changeDhikr ignores same index', () async {
      final repo = _FakeSebhaRepository(loaded: const SebhaEntity());
      final cubit = SebhaCubit(repository: repo);

      await cubit.loadSebha();

      final states = <SebhaState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.changeDhikr(0); // Same as default.

      expect(states, isEmpty);

      await subscription.cancel();
      cubit.close();
    });

    test('changeDhikr clamps out-of-range index', () async {
      final repo = _FakeSebhaRepository(loaded: const SebhaEntity());
      final cubit = SebhaCubit(repository: repo);

      await cubit.loadSebha();
      await cubit.changeDhikr(999);

      final loaded = cubit.state as SebhaLoaded;
      expect(loaded.sebha.currentDhikrIndex, SebhaCubit.dhikrs.length - 1);
      expect(
        loaded.sebha.currentDhikrText,
        SebhaCubit.dhikrs.last,
      );

      cubit.close();
    });

    test('resetCounter resets count and saves', () async {
      final repo = _FakeSebhaRepository(
        loaded: SebhaEntity(currentCount: 15, totalRounds: 4),
      );
      final cubit = SebhaCubit(repository: repo);

      await cubit.loadSebha();
      await cubit.resetCounter();

      final loaded = cubit.state as SebhaLoaded;
      expect(loaded.sebha.currentCount, 0);
      expect(loaded.sebha.totalRounds, 4); // Rounds preserved.
      expect(repo.lastSaved?.currentCount, 0);

      cubit.close();
    });

    test('resetCounter ignores when count is already 0', () async {
      final repo = _FakeSebhaRepository(loaded: const SebhaEntity());
      final cubit = SebhaCubit(repository: repo);

      await cubit.loadSebha();

      final states = <SebhaState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.resetCounter();

      expect(states, isEmpty);

      await subscription.cancel();
      cubit.close();
    });

    test('loadSebha does not reload when already loaded', () async {
      final repo = _FakeSebhaRepository(loaded: const SebhaEntity());
      final cubit = SebhaCubit(repository: repo);

      await cubit.loadSebha();

      final states = <SebhaState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.loadSebha();

      expect(states, isEmpty);

      await subscription.cancel();
      cubit.close();
    });
  });

  group('SebhaRepositoryImpl', () {
    test('loads empty state when nothing saved', () async {
      final storage = _MemoryKeyValueStorage();
      final repo = SebhaRepositoryImpl(storage: storage);

      final sebha = await repo.loadSebha();

      expect(sebha.currentCount, 0);
      expect(sebha.totalRounds, 0);
      expect(sebha.currentDhikrIndex, 0);
      expect(sebha.currentDhikrText, 'سُبْحَانَ الله');
    });

    test('persists and restores full state', () async {
      final storage = _MemoryKeyValueStorage();
      final repo = SebhaRepositoryImpl(storage: storage);

      final toSave = SebhaEntity(
        currentCount: 21,
        totalRounds: 7,
        currentDhikrIndex: 3,
        currentDhikrText: 'أَسْتَغْفِرُ الله',
      );
      await repo.saveSebha(toSave);

      final restored = await repo.loadSebha();

      expect(restored.currentCount, 21);
      expect(restored.totalRounds, 7);
      expect(restored.currentDhikrIndex, 3);
      expect(restored.currentDhikrText, 'أَسْتَغْفِرُ الله');
    });

    test('clamps out-of-range saved values', () async {
      final storage = _MemoryKeyValueStorage();
      // Manually write invalid values.
      storage.setInt(AppConstants.sebhaCountPrefKey, 999);
      storage.setInt(AppConstants.sebhaDhikrIndexPrefKey, 99);

      final repo = SebhaRepositoryImpl(storage: storage);
      final sebha = await repo.loadSebha();

      expect(sebha.currentCount, SebhaCubit.target);
      expect(sebha.currentDhikrIndex, SebhaCubit.dhikrs.length - 1);
    });
  });
}