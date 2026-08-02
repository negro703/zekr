/// Abstraction for scheduling local notifications.
///
/// Implemented by [LocalNotificationService] and used by features that
/// need to schedule/cancel reminders without depending on the concrete
/// platform plugin implementation (enables unit testing).
abstract interface class NotificationScheduler {
  /// Schedules a daily repeating notification at [hour]:[minute].
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  });

  /// Schedules a periodic interval notification.
  Future<void> schedulePeriodic({
    required int id,
    required String title,
    required String body,
    required Duration interval,
  });

  /// Cancels a scheduled notification by [id].
  Future<void> cancelNotification(int id);
}