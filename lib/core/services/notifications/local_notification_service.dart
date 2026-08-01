import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../errors/errors.dart';

/// Manages local notifications for Azkar and Prayers on the Prophet.
///
/// This service is initialized during app startup. Full scheduling
/// capabilities (daily/weekly reminders with timezone support) will be
/// added in Phase 5 of the roadmap.
class LocalNotificationService {
  LocalNotificationService._internal();

  static final LocalNotificationService instance =
      LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Whether the notification service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the notification plugin.
  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _plugin.initialize(settings);
      _isInitialized = true;
    } catch (e) {
      throw NotificationException(
        message: 'Failed to initialize notifications.',
        cause: e,
      );
    }
  }

  /// Requests notification permissions from the user.
  ///
  /// Returns `true` if permissions were granted (or are not required
  /// on the current platform), `false` otherwise.
  Future<bool> requestPermissions() async {
    if (!_isInitialized) return false;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final androidGranted = await android?.requestNotificationsPermission() ??
        true;
    final iosGranted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted;
  }

  /// Cancels a scheduled notification by [id].
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}