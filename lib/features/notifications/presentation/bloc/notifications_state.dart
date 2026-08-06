import 'package:equatable/equatable.dart';

/// Base state for the notifications settings feature.
sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before preferences are loaded.
final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// State while preferences are being loaded.
final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// Immutable notification preference snapshot.
class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.morningEnabled = false,
    this.morningHour = 6,
    this.morningMinute = 0,
    this.eveningEnabled = false,
    this.eveningHour = 17,
    this.eveningMinute = 0,
    this.salawatEnabled = false,
    this.salawatIntervalMinutes = 60,
  });

  final bool morningEnabled;
  final int morningHour;
  final int morningMinute;
  final bool eveningEnabled;
  final int eveningHour;
  final int eveningMinute;
  final bool salawatEnabled;

  /// The periodic Salawat reminder interval in **minutes**.
  ///
  /// Allows the user to set an exact custom interval (e.g. 15, 30, 45,
  /// 90 minutes) rather than being limited to whole hours.
  final int salawatIntervalMinutes;

  NotificationPreferences copyWith({
    bool? morningEnabled,
    int? morningHour,
    int? morningMinute,
    bool? eveningEnabled,
    int? eveningHour,
    int? eveningMinute,
    bool? salawatEnabled,
    int? salawatIntervalMinutes,
  }) {
    return NotificationPreferences(
      morningEnabled: morningEnabled ?? this.morningEnabled,
      morningHour: morningHour ?? this.morningHour,
      morningMinute: morningMinute ?? this.morningMinute,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      eveningHour: eveningHour ?? this.eveningHour,
      eveningMinute: eveningMinute ?? this.eveningMinute,
      salawatEnabled: salawatEnabled ?? this.salawatEnabled,
      salawatIntervalMinutes:
          salawatIntervalMinutes ?? this.salawatIntervalMinutes,
    );
  }

  @override
  List<Object?> get props => [
        morningEnabled,
        morningHour,
        morningMinute,
        eveningEnabled,
        eveningHour,
        eveningMinute,
        salawatEnabled,
        salawatIntervalMinutes,
      ];
}

/// State when preferences have been loaded.
final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({required this.preferences});

  final NotificationPreferences preferences;

  NotificationsLoaded copyWith({NotificationPreferences? preferences}) {
    return NotificationsLoaded(preferences: preferences ?? this.preferences);
  }

  @override
  List<Object?> get props => [preferences];
}

/// State when an error occurred.
final class NotificationsError extends NotificationsState {
  const NotificationsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}