import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/services.dart';
import 'notifications_state.dart';

/// Cubit managing notification preferences and scheduling.
///
/// Responsibilities:
/// - Load/save user preferences synchronously via [KeyValueStorage]
/// - Schedule/cancel Morning & Evening Azkar daily reminders
/// - Schedule/cancel periodic Salawat (Prayers on the Prophet) reminders
///
/// Preferences are read synchronously from the key-value store so the
/// settings UI renders instantly with zero flicker or hanging spinners.
/// Scheduling happens in the background and can never block loading.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    KeyValueStorage? keyValueStorage,
    NotificationScheduler? scheduler,
  })  : _storage = keyValueStorage ?? LocalStorageService.instance,
        _scheduler = scheduler ?? LocalNotificationService.instance,
        super(const NotificationsInitial());

  final KeyValueStorage _storage;
  final NotificationScheduler _scheduler;
  bool _preferencesLoaded = false;

  /// Whether preferences have been loaded at least once.
  bool get preferencesLoaded => _preferencesLoaded;

  /// Loads preferences synchronously from storage and applies schedules.
  ///
  /// Reading from [KeyValueStorage] is a synchronous, non-hanging
  /// operation. Scheduling is fire-and-forget with errors swallowed so a
  /// platform-level failure can never leave the UI stuck on a spinner.
  ///
  /// Backwards-compatible: if an old `salawat_interval_hours` value is
  /// found, it is migrated to minutes (×60) so existing users keep their
  /// chosen interval.
  Future<void> loadPreferences() async {
    // Already loaded — re-emit cached state without a loading flash.
    if (_preferencesLoaded && state is NotificationsLoaded) {
      await _applySchedulesSafe((state as NotificationsLoaded).preferences);
      return;
    }

    emit(const NotificationsLoading());

    // Synchronous local read — instant, no async gap.
    final savedMinutes =
        _storage.getInt(AppConstants.salawatIntervalMinutesPrefKey);
    final savedHours =
        _storage.getInt(AppConstants.salawatIntervalHoursPrefKey);

    // Prefer minutes; fall back to legacy hours (migrated ×60).
    final salawatMinutes = savedMinutes ??
        ((savedHours ?? 1) * 60).clamp(1, 24 * 60).toInt();

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
      salawatIntervalMinutes: salawatMinutes,
    );

    _preferencesLoaded = true;
    emit(NotificationsLoaded(preferences: prefs));

    // Best-effort scheduling; never blocks the loaded state.
    await _applySchedulesSafe(prefs);
  }

  /// Toggles the Morning Azkar reminder.
  Future<void> setMorningEnabled(bool enabled) async {
    await _updatePrefs((p) => p.copyWith(morningEnabled: enabled));
  }

  /// Sets the Morning Azkar reminder time.
  Future<void> setMorningTime(int hour, int minute) async {
    await _updatePrefs(
      (p) => p.copyWith(morningHour: hour, morningMinute: minute),
    );
  }

  /// Toggles the Evening Azkar reminder.
  Future<void> setEveningEnabled(bool enabled) async {
    await _updatePrefs((p) => p.copyWith(eveningEnabled: enabled));
  }

  /// Sets the Evening Azkar reminder time.
  Future<void> setEveningTime(int hour, int minute) async {
    await _updatePrefs(
      (p) => p.copyWith(eveningHour: hour, eveningMinute: minute),
    );
  }

  /// Toggles periodic Salawat reminders.
  Future<void> setSalawatEnabled(bool enabled) async {
    await _updatePrefs((p) => p.copyWith(salawatEnabled: enabled));
  }

  /// Sets the Salawat reminder interval (in minutes).
  Future<void> setSalawatInterval(int minutes) async {
    final safe = minutes.clamp(1, 24 * 60).toInt();
    await _updatePrefs((p) => p.copyWith(salawatIntervalMinutes: safe));
  }

  /// Persists updated preferences and re-applies all schedules.
  Future<void> _updatePrefs(
    NotificationPreferences Function(NotificationPreferences) update,
  ) async {
    if (state is! NotificationsLoaded) return;

    final current = (state as NotificationsLoaded).preferences;
    final updated = update(current);

    // Emit immediately for instant UI feedback.
    emit((state as NotificationsLoaded).copyWith(preferences: updated));

    // Persist synchronously (fire-and-forget for platform writes).
    unawaited(
      _storage
          .setBool(
            AppConstants.morningAzkarEnabledPrefKey,
            updated.morningEnabled,
          )
          .catchError((_) {}),
    );
    unawaited(
      _storage
          .setInt(
            AppConstants.morningAzkarHourPrefKey,
            updated.morningHour,
          )
          .catchError((_) {}),
    );
    unawaited(
      _storage
          .setInt(
            AppConstants.morningAzkarMinutePrefKey,
            updated.morningMinute,
          )
          .catchError((_) {}),
    );
    unawaited(
      _storage
          .setBool(
            AppConstants.eveningAzkarEnabledPrefKey,
            updated.eveningEnabled,
          )
          .catchError((_) {}),
    );
    unawaited(
      _storage
          .setInt(AppConstants.eveningAzkarHourPrefKey, updated.eveningHour)
          .catchError((_) {}),
    );
    unawaited(
      _storage
          .setInt(
            AppConstants.eveningAzkarMinutePrefKey,
            updated.eveningMinute,
          )
          .catchError((_) {}),
    );
    unawaited(
      _storage
          .setBool(AppConstants.salawatEnabledPrefKey, updated.salawatEnabled)
          .catchError((_) {}),
    );
    unawaited(
      _storage
          .setInt(
            AppConstants.salawatIntervalMinutesPrefKey,
            updated.salawatIntervalMinutes,
          )
          .catchError((_) {}),
    );
    // Clear the legacy hours key once we're on the minutes scheme.
    unawaited(
      _storage.remove(AppConstants.salawatIntervalHoursPrefKey).catchError(
            (_) {},
          ),
    );

    await _applySchedulesSafe(updated);
  }

  /// Applies all notification schedules based on the given [prefs],
  /// swallowing any platform-level errors so the UI never hangs.
  Future<void> _applySchedulesSafe(NotificationPreferences prefs) async {
    try {
      if (prefs.morningEnabled) {
        await _scheduler.scheduleDaily(
          id: AppConstants.morningAzkarNotificationId,
          title: NotificationPayloads.morningTitle,
          body: NotificationPayloads.morningBody,
          hour: prefs.morningHour,
          minute: prefs.morningMinute,
        );
      } else {
        await _scheduler.cancelNotification(
          AppConstants.morningAzkarNotificationId,
        );
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
        await _scheduler.cancelNotification(
          AppConstants.eveningAzkarNotificationId,
        );
      }

      if (prefs.salawatEnabled) {
        await _scheduler.schedulePeriodic(
          id: AppConstants.prayersOnProphetNotificationId,
          title: NotificationPayloads.salawatTitle,
          body: NotificationPayloads.salawatBody,
          interval: Duration(minutes: prefs.salawatIntervalMinutes),
        );
      } else {
        await _scheduler.cancelNotification(
          AppConstants.prayersOnProphetNotificationId,
        );
      }
    } catch (_) {
      // Scheduling failures must never block settings or crash the app.
    }
  }
}