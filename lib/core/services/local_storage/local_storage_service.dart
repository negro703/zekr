import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart';
import 'key_value_storage.dart';

/// Central local storage service managing both Hive boxes and
/// SharedPreferences key-value storage.
///
/// - Hive: Used for structured data (Quran pages, bookmarks, azkar progress,
///   sebha state) stored in strongly-typed boxes.
/// - SharedPreferences: Used for lightweight app settings (theme mode,
///   font size, notification preferences).
class LocalStorageService implements KeyValueStorage {
  LocalStorageService._internal();

  static final LocalStorageService instance = LocalStorageService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  /// Initializes both Hive and SharedPreferences backends.
  ///
  /// Must be called once during app startup before any other service
  /// interacts with local storage.
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    _prefs = await SharedPreferences.getInstance();

    _isInitialized = true;
  }

  // ─── SharedPreferences (App Settings) ───────────────────────────────────────

  /// Reads a [String] setting by [key], or [defaultValue] if absent.
  @override
  String? getString(String key, {String? defaultValue}) =>
      _prefs?.getString(key) ?? defaultValue;

  /// Writes a [String] setting by [key].
  @override
  Future<void> setString(String key, String value) =>
      _prefs?.setString(key, value) ?? Future.value();

  /// Reads an [int] setting by [key], or [defaultValue] if absent.
  @override
  int? getInt(String key, {int? defaultValue}) =>
      _prefs?.getInt(key) ?? defaultValue;

  /// Writes an [int] setting by [key].
  @override
  Future<void> setInt(String key, int value) =>
      _prefs?.setInt(key, value) ?? Future.value();

  /// Reads a [bool] setting by [key], or [defaultValue] if absent.
  @override
  bool? getBool(String key, {bool? defaultValue}) =>
      _prefs?.getBool(key) ?? defaultValue;

  /// Writes a [bool] setting by [key].
  @override
  Future<void> setBool(String key, bool value) =>
      _prefs?.setBool(key, value) ?? Future.value();

  /// Removes a setting by [key].
  @override
  Future<void> remove(String key) => _prefs?.remove(key) ?? Future.value();

  /// Clears all SharedPreferences settings.
  Future<void> clearSettings() async {
    await _prefs?.clear();
  }

  // ─── Hive Boxes (Structured Data) ───────────────────────────────────────────

  /// Opens (or returns an already-open) Hive box by [name].
  Future<Box<dynamic>> openBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box(name);
    }
    return Hive.openBox(name);
  }

  /// Reads a value from a Hive box by [key].
  dynamic readFromBox(String boxName, String key) {
    final box = Hive.isBoxOpen(boxName) ? Hive.box(boxName) : null;
    return box?.get(key);
  }

  /// Writes a value to a Hive box by [key].
  Future<void> writeToBox(String boxName, String key, dynamic value) async {
    final box = await openBox(boxName);
    await box.put(key, value);
  }

  /// Deletes a key from a Hive box.
  Future<void> deleteFromBox(String boxName, String key) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  /// Clears all entries in a Hive box.
  Future<void> clearBox(String boxName) async {
    final box = await openBox(boxName);
    await box.clear();
  }

  /// Compatibility getter for pre-existing box names from [AppConstants].
  Box<dynamic> get settingsBox => Hive.box(AppConstants.settingsBox);
  Box<dynamic> get quranBox => Hive.box(AppConstants.quranBox);
  Box<dynamic> get bookmarksBox => Hive.box(AppConstants.bookmarksBox);
  Box<dynamic> get azkarBox => Hive.box(AppConstants.azkarBox);
  Box<dynamic> get sebhaBox => Hive.box(AppConstants.sebhaBox);
}