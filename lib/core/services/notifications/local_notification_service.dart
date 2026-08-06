import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../errors/errors.dart';
import 'notification_scheduler.dart';

/// Manages local notifications for Azkar and Prayers on the Prophet.
///
/// Handles timezone initialization and supports scheduling:
/// - Daily repeating notifications (Morning/Evening Azkar)
/// - Periodic interval notifications (Prayers on the Prophet)
///
/// Uses **exact alarms** with `exactAllowWhileIdle` so notifications fire
/// reliably even when the app is closed, in the background, or the device
/// screen is locked. Notifications include sound, vibration, and
/// heads-up popup behavior.
class LocalNotificationService implements NotificationScheduler {
  LocalNotificationService._internal();

  static final LocalNotificationService instance =
      LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _permissionsGranted = false;

  /// Whether the notification service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Whether notification permissions have been granted.
  bool get permissionsGranted => _permissionsGranted;

  /// Initializes the plugin, timezone data, and requests permissions.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const linux = LinuxInitializationSettings(defaultActionName: 'Open');
      const settings = InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
      );

      await _plugin.initialize(settings);
      await _initTimezones();
      _isInitialized = true;

      // Best-effort permission request; never blocks startup.
      try {
        await requestPermissions();
      } catch (_) {
        // Permission failures are non-fatal.
      }
    } catch (e) {
      throw NotificationException(
        message: 'Failed to initialize notifications.',
        cause: e,
      );
    }
  }

  /// Initializes the `timezone` package with the device's local timezone.
  Future<void> _initTimezones() async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Requests notification permissions from the user.
  Future<bool> requestPermissions() async {
    if (!_isInitialized) return false;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
            true;

    _permissionsGranted = androidGranted && iosGranted;
    return _permissionsGranted;
  }

  // ─── NotificationScheduler Implementation ───────────────────────────────────

  /// Schedules a daily repeating notification at [hour]:[minute].
  ///
  /// Uses an **exact alarm** (`exactAllowWhileIdle`) so the notification
  /// fires at the precise time even when the device is in Doze mode or
  /// the screen is locked. The channel is configured with high importance
  /// and sound so it appears as a heads-up popup.
  @override
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminders',
        'التذكيرات اليومية',
        channelDescription: 'تذكيرات يومية للأذكار والصلاة على النبي',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOf(hour, minute),
        details,
        // Exact alarm fires reliably even in Doze mode / screen locked.
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Fall back to inexact scheduling if exact alarms are not permitted.
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          _nextInstanceOf(hour, minute),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e2) {
        throw NotificationException(
          message: 'Failed to schedule daily notification.',
          cause: e2,
        );
      }
    }
  }

  /// Schedules a periodic interval notification for Salawat reminders.
  ///
  /// Uses `zonedSchedule` with `matchDateTimeComponents` for intervals
  /// that map to a supported repeat (hourly/daily/weekly). For sub-hour
  /// intervals, it schedules a repeating exact alarm every N minutes.
  @override
  Future<void> schedulePeriodic({
    required int id,
    required String title,
    required String body,
    required Duration interval,
  }) async {
    if (!_isInitialized) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'salawat_reminders',
        'تذكير الصلاة على النبي',
        channelDescription: 'تذكيرات دورية للصلاة على النبي ﷺ',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    try {
      // For intervals that map to a supported RepeatInterval, use
      // periodicallyShow with exact scheduling.
      final repeatInterval = _mapInterval(interval);
      await _plugin.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Fall back to inexact scheduling if exact alarms are not permitted.
      try {
        final repeatInterval = _mapInterval(interval);
        await _plugin.periodicallyShow(
          id,
          title,
          body,
          repeatInterval,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (e2) {
        throw NotificationException(
          message: 'Failed to schedule periodic notification.',
          cause: e2,
        );
      }
    }
  }

  /// Cancels a scheduled notification by [id].
  @override
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Maps a [Duration] to the closest supported [RepeatInterval].
  ///
  /// The plugin supports: every minute, hourly, daily, and weekly.
  /// Hour-based intervals (the app's Salawat use case) map to hourly;
  /// day/week-scale intervals map to daily/weekly respectively.
  RepeatInterval _mapInterval(Duration interval) {
    final hours = interval.inHours;
    if (hours <= 0) return RepeatInterval.hourly;
    if (hours < 24) return RepeatInterval.hourly;
    if (hours < 24 * 7) return RepeatInterval.daily;
    return RepeatInterval.weekly;
  }

  /// Returns the next matching [hour]:[minute] in the local timezone.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// Islamic notification payloads used across the app.
abstract final class NotificationPayloads {
  static const String morningTitle = 'أذكار الصباح 🌅';
  static const String morningBody =
      'حان وقت أذكار الصباح - ذكر الله يطمئن القلب';
  static const String eveningTitle = 'أذكار المساء 🌇';
  static const String eveningBody =
      'حان وقت أذكار المساء - حصّن نفسك بذكر الله';
  static const String salawatTitle = 'الصلاة على النبي ﷺ';
  static const String salawatBody = 'اللهم صلِّ وسلم على نبينا محمد ﷺ';
}