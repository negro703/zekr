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
///
/// On Android 13+ the `SCHEDULE_EXACT_ALARM` permission must be granted by
/// the user at runtime; on Android 14+ the `USE_FULL_SCREEN_INTENT`
/// permission is revoked by default for non-calling/alarm apps. Both are
/// requested here so exact alarms and heads-up popups work on locked screens.
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
  ///
  /// On Android this also requests:
  /// - `POST_NOTIFICATIONS` (Android 13+)
  /// - `SCHEDULE_EXACT_ALARM` (Android 13+ — required for exact alarms)
  /// - `USE_FULL_SCREEN_INTENT` (Android 14+ — required for heads-up popup
  ///   on locked screens)
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

    // Request exact alarm permission (Android 13+). This is required for
    // `exactAllowWhileIdle` to work. Best-effort; never blocks.
    try {
      await android?.requestExactAlarmsPermission();
    } catch (_) {
      // Non-fatal — scheduling will fall back to inexact.
    }

    // Request full-screen intent permission (Android 14+). Required for
    // `fullScreenIntent: true` heads-up popups on locked screens.
    try {
      await android?.requestFullScreenIntentPermission();
    } catch (_) {
      // Non-fatal — notification still shows in the shade.
    }

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
  ///
  /// If exact alarms are not permitted (e.g. the user denied the
  /// `SCHEDULE_EXACT_ALARM` permission on Android 13+), it gracefully
  /// falls back to `inexactAllowWhileIdle` rather than failing silently.
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

    final scheduledDate = _nextInstanceOf(hour, minute);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
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
          scheduledDate,
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
  /// Uses `periodicallyShowWithDuration` which accepts an arbitrary
  /// [Duration] interval (e.g. every 5, 15, 30 minutes) and schedules an
  /// exact repeating alarm. This is the correct method for sub-hour
  /// intervals — `periodicallyShow` only supports fixed hourly/daily/weekly
  /// repeats and would silently round sub-hour intervals up to an hour.
  ///
  /// Falls back to `inexactAllowWhileIdle` if exact alarms are not permitted.
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
      await _plugin.periodicallyShowWithDuration(
        id,
        title,
        body,
        interval,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Fall back to inexact scheduling if exact alarms are not permitted.
      try {
        await _plugin.periodicallyShowWithDuration(
          id,
          title,
          body,
          interval,
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

  // ─── Debugging / Test Method ────────────────────────────────────────────────

  /// Shows a test notification immediately after [delay] (default 5 seconds).
  ///
  /// Use this to verify the notification pipeline works locally:
  /// - Call it from a button press or app startup.
  /// - If it appears, the channel, sound, vibration, and heads-up popup
  ///   are all working.
  /// - Then verify the recurring scheduler by enabling a reminder and
  ///   checking it fires at the scheduled time with the app closed/locked.
  ///
  /// Returns the notification id used (so callers can cancel it later).
  Future<int> showTestNotification({
    String title = '🔔 اختبار الإشعارات',
    String body = 'إذا رأيت هذا الإشعار، فإن نظام الإشعارات يعمل بشكل صحيح ✅',
    Duration delay = const Duration(seconds: 5),
  }) async {
    if (!_isInitialized) return -1;

    const testId = 999999;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'قناة الاختبار',
        channelDescription: 'قناة اختبار الإشعارات',
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

    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    try {
      await _plugin.zonedSchedule(
        testId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Fall back to inexact if exact alarms are not permitted.
      await _plugin.zonedSchedule(
        testId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    return testId;
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

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