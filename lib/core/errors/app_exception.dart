/// Base exception for all application-level errors in Zekr.
///
/// Provides a user-friendly [message] that can be displayed directly
/// in the UI, along with an optional [code] for programmatic handling.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.cause,
  });

  /// A user-friendly, localized error message.
  final String message;

  /// An optional machine-readable error code.
  final String? code;

  /// The underlying error that caused this exception, if any.
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('AppException');
    if (code != null) buffer.write('[$code]');
    buffer.write(': $message');
    if (cause != null) buffer.write(' (cause: $cause)');
    return buffer.toString();
  }
}

/// Exception thrown when local storage (Hive/SharedPreferences) fails.
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.cause,
  });
}

/// Exception thrown when a resource (e.g., Quran JSON) fails to load.
class ResourceLoadException extends AppException {
  const ResourceLoadException({
    required super.message,
    super.code = 'RESOURCE_LOAD_ERROR',
    super.cause,
  });
}

/// Exception thrown when notification scheduling fails.
class NotificationException extends AppException {
  const NotificationException({
    required super.message,
    super.code = 'NOTIFICATION_ERROR',
    super.cause,
  });
}