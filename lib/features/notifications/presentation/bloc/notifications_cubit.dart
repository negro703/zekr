import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/services.dart';
import 'notifications_state.dart';

/// Cubit managing notification preferences and scheduling.
///
/// Responsibilities:
/// - Load/save user preferences via [KeyValueStorage]
/// - Schedule/cancel Morning & Evening Azkar daily reminders
/// - Schedule/cancel periodic Salawat (Prayers on the Prophet) reminders
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    KeyValueStorage? keyValueStorage,
    NotificationScheduler? scheduler,
  })  : _storage = keyValueStorage ?? LocalStorageService.instance,
        _scheduler = scheduler ?? LocalNotificationService.instance,
        super(const NotificationsInitial());

  final KeyValueStorage _storage;
  final NotificationScheduler _scheduler;

  /// Loads preferences from storage and applies scheduled notifications.
  Future<void> loadPreferences() async {
    emit(const NotificationsLoading());

    final prefs = NotificationPreferences(
      morningEnabled:
          _storage.getBool(AppConstants.morningAzkarEnabledPrefKey) ?? false,
      morningHour:
          _storage.getInt(AppConstants.morningAzkarHourPrefKey) ?? 6,
      morningMinute:
          _storage.getInt(AppConstants.morningAzkarMinutePrefKey) ?? 0,
      eveningEnabled:
          _storage.getBool(AppConstants.eveningAzkarEnabledPrefKey) ?? false,
      eveningHour:
          _storage.getInt(AppConstants.eveningAzkarHourPrefKey) ?? 17,
      eveningMinute:
          _storage.getInt(AppConstants.eveningAzkarMinutePrefKey) ?? 0,
      salawatEnabled:
          _storage.getBool(AppConstants.salawatEnabledPrefKey) ?? false,
      salawatIntervalHours:
          _storage.getInt(AppConstants.salawatIntervalHoursPrefKey) ?? 1,
    );

    emit(NotificationsLoaded(preferences: prefs));
    await _applySchedules(prefs);
  }

  /// Toggles the Morning Azkar reminder.
  Future<void> setMorningEnabled(bool enabled) async {
    await _updatePrefs((p) => p.copyWith(morningEnabled: enabled));
  }

  /// Sets the Morning Azkar reminder time.
  Future<void> setMorningTime(int hour, int minute) async {
    await _updatePrefs((p) => p.copyWith(morningHour: hour, morningMinute: minute));
  }

  /// Toggles the Evening Azkar reminder.
  Future<void> setEveningEnabled(bool enabled) async {
    await _updatePrefs((p) => p.copyWith(eveningEnabled: enabled));
  }

  /// Sets the Evening Azkar reminder time.
  Future<void> setEveningTime(int hour, int minute) async {
    await _updatePrefs((p) => p.copyWith(eveningHour: hour, eveningMinute: minute));
  }

  /// Toggles periodic Salawat reminders.
  Future<void> setSalawatEnabled(bool enabled) async {
    await _updatePrefs((p) => p.copyWith(salawatEnabled: enabled));
  }

  /// Sets the Salawat reminder interval (in hours).
  Future<void> setSalawatInterval(int hours) async {
    await _updatePrefs((p) => p.copyWith(salawatIntervalHours: hours));
  }

  /// Persists updated preferences and re-applies all schedules.
  Future<void> _updatePrefs(
    NotificationPreferences Function(NotificationPreferences) update,
  ) async {
    if (state is! NotificationsLoaded) return;

    final current = (state as NotificationsLoaded).preferences;
    final updated = update(current);

    emit((state as NotificationsLoaded).copyWith(preferences: updated));

    await _storage.setBool(AppConstants.morningAzkarEnabledPrefKey, updated.morningEnabled);
    await _storage.setInt(AppConstants.morningAzkarHourPrefKey, updated.morningHour);
    await _storage.setInt(AppConstants.morningAzkarMinutePrefKey, updated.morningMinute);
    await _storage.setBool(AppConstants.eveningAzkarEnabledPrefKey, updated.eveningEnabled);
    await _storage.setInt(AppConstants.eveningAzkarHourPrefKey, updated.eveningHour);
    await _storage.setInt(AppConstants.eveningAzkarMinutePrefKey, updated.eveningMinute);
    await _storage.setBool(AppConstants.salawatEnabledPrefKey, updated.salawatEnabled);
    await _storage.setInt(AppConstants.salawatIntervalHoursPrefKey, updated.salawatIntervalHours);

    await _applySchedules(updated);
  }

  /// Applies all notification schedules based on the given [prefs].
  Future<void> _applySchedules(NotificationPreferences prefs) async {
    if (prefs.morningEnabled) {
      await _scheduler.scheduleDaily(
        id: AppConstants.morningAzkarNotificationId,
        title: NotificationPayloads.morningTitle,
        body: NotificationPayloads.morningBody,
        hour: prefs.morningHour,
        minute: prefs.morningMinute,
      );
    } else {
      await _scheduler.cancelNotification(AppConstants.morningAzkarNotificationId);
    }

    if (prefs.eveningEnabled) {
      await _scheduler.scheduleDaily(
        id: AppConstants.eveningAzkarNotificationId,
        title: NotificationPayloads.eveningTitle,
        body: NotificationPayloads.eveningBody,
        hour: prefs.eveningHour,
        minute: prefs.eveningMinute,
      );
    } else {
      await _scheduler.cancelNotification(AppConstants.eveningAzkarNotificationId);
    }

    if (prefs.salawatEnabled) {
      await _scheduler.schedulePeriodic(
        id: AppConstants.prayersOnProphetNotificationId,
        title: NotificationPayloads.salawatTitle,
        body: NotificationPayloads.salawatBody,
        interval: Duration(hours: prefs.salawatIntervalHours),
      );
    } else {
      await _scheduler.cancelNotification(AppConstants.prayersOnProphetNotificationId);
    }
  }
}