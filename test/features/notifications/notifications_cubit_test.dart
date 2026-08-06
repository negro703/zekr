import 'package:flutter_test/flutter_test.dart';
import 'package:zekr/core/core.dart';
import 'package:zekr/features/notifications/notifications.dart';

/// In-memory [KeyValueStorage] for testing.
class _MemoryStorage implements KeyValueStorage {
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

/// Fake scheduler that records calls.
class _FakeScheduler implements NotificationScheduler {
  final List<int> scheduledDaily = [];
  final List<int> scheduledPeriodic = [];
  final List<int> cancelled = [];

  @override
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    scheduledDaily.add(id);
  }

  @override
  Future<void> schedulePeriodic({
    required int id,
    required String title,
    required String body,
    required Duration interval,
  }) async {
    scheduledPeriodic.add(id);
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationsCubit', () {
    late _MemoryStorage storage;
    late _FakeScheduler scheduler;

    setUp(() {
      storage = _MemoryStorage();
      scheduler = _FakeScheduler();
    });

    NotificationsCubit buildCubit() => NotificationsCubit(
          keyValueStorage: storage,
          scheduler: scheduler,
        );

    test('initial state is NotificationsInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<NotificationsInitial>());
      cubit.close();
    });

    test('loadPreferences emits Loading then Loaded with defaults', () async {
      final cubit = buildCubit();
      final states = <NotificationsState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadPreferences();
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(2));
      expect(states[0], isA<NotificationsLoading>());
      expect(states[1], isA<NotificationsLoaded>());

      final loaded = states[1] as NotificationsLoaded;
      expect(loaded.preferences.morningEnabled, isFalse);
      expect(loaded.preferences.morningHour, 6);
      expect(loaded.preferences.salawatIntervalMinutes, 60);

      await sub.cancel();
      cubit.close();
    });

    test('setMorningEnabled schedules daily notification', () async {
      final cubit = buildCubit();
      await cubit.loadPreferences();

      await cubit.setMorningEnabled(true);

      expect(scheduler.scheduledDaily, contains(AppConstants.morningAzkarNotificationId));
      expect(storage.getBool(AppConstants.morningAzkarEnabledPrefKey), isTrue);

      cubit.close();
    });

    test('setMorningEnabled(false) cancels notification', () async {
      final cubit = buildCubit();
      await cubit.loadPreferences();
      await cubit.setMorningEnabled(true);
      scheduler.scheduledDaily.clear();

      await cubit.setMorningEnabled(false);

      expect(scheduler.cancelled, contains(AppConstants.morningAzkarNotificationId));

      cubit.close();
    });

    test('setEveningEnabled schedules daily notification', () async {
      final cubit = buildCubit();
      await cubit.loadPreferences();

      await cubit.setEveningEnabled(true);

      expect(scheduler.scheduledDaily, contains(AppConstants.eveningAzkarNotificationId));

      cubit.close();
    });

    test('setSalawatEnabled schedules periodic notification', () async {
      final cubit = buildCubit();
      await cubit.loadPreferences();

      await cubit.setSalawatEnabled(true);

      expect(scheduler.scheduledPeriodic, contains(AppConstants.prayersOnProphetNotificationId));

      cubit.close();
    });

    test('setSalawatInterval persists minutes', () async {
      final cubit = buildCubit();
      await cubit.loadPreferences();

      await cubit.setSalawatInterval(25);

      final loaded = cubit.state as NotificationsLoaded;
      expect(loaded.preferences.salawatIntervalMinutes, 25);
      expect(storage.getInt(AppConstants.salawatIntervalMinutesPrefKey), 25);

      cubit.close();
    });

    test('setSalawatInterval clamps to valid range', () async {
      final cubit = buildCubit();
      await cubit.loadPreferences();

      await cubit.setSalawatInterval(0); // below min (1)
      final loaded = cubit.state as NotificationsLoaded;
      expect(loaded.preferences.salawatIntervalMinutes, 1);

      await cubit.setSalawatInterval(99999); // above max (1440)
      final loaded2 = cubit.state as NotificationsLoaded;
      expect(loaded2.preferences.salawatIntervalMinutes, 1440);

      cubit.close();
    });

    test('legacy hours are migrated to minutes on load', () async {
      storage.setInt(AppConstants.salawatIntervalHoursPrefKey, 2);

      final cubit = buildCubit();
      await cubit.loadPreferences();

      final loaded = cubit.state as NotificationsLoaded;
      expect(loaded.preferences.salawatIntervalMinutes, 120);

      cubit.close();
    });

    test('setMorningTime persists time', () async {
      final cubit = buildCubit();
      await cubit.loadPreferences();

      await cubit.setMorningTime(7, 30);

      final loaded = cubit.state as NotificationsLoaded;
      expect(loaded.preferences.morningHour, 7);
      expect(loaded.preferences.morningMinute, 30);

      cubit.close();
    });
  });
}