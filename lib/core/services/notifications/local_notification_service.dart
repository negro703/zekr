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
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

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
    } catch (e) {
      throw NotificationException(
        message: 'Failed to schedule daily notification.',
        cause: e,
      );
    }
  }

  /// Schedules a periodic interval notification for Salawat reminders.
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
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.hourly,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      throw NotificationException(
        message: 'Failed to schedule periodic notification.',
        cause: e,
      );
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