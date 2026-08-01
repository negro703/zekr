/// Abstraction for simple key-value persistence.
///
/// Implemented by [LocalStorageService] and used by features that
/// need to persist lightweight settings (e.g., last-read page,
/// bookmarks, theme mode) without depending on the concrete
/// storage implementation.
abstract interface class KeyValueStorage {
  /// Reads a [String] value by [key], or [defaultValue] if absent.
  String? getString(String key, {String? defaultValue});

  /// Writes a [String] value by [key].
  Future<void> setString(String key, String value);

  /// Reads an [int] value by [key], or [defaultValue] if absent.
  int? getInt(String key, {int? defaultValue});

  /// Writes an [int] value by [key].
  Future<void> setInt(String key, int value);

  /// Reads a [bool] value by [key], or [defaultValue] if absent.
  bool? getBool(String key, {bool? defaultValue});

  /// Writes a [bool] value by [key].
  Future<void> setBool(String key, bool value);

  /// Removes the value stored under [key].
  Future<void> remove(String key);
}