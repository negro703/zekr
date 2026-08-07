import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/services.dart';
import 'app_settings_state.dart';

/// Cubit managing the app-wide user preferences: language and theme.
///
/// Responsibilities:
/// - Load persisted language/theme synchronously via [KeyValueStorage]
/// - Persist user choices immediately when changed
/// - Expose the active [Locale] and [ThemeMode] to the [MaterialApp]
class AppSettingsCubit extends Cubit<AppSettings> {
  AppSettingsCubit({
    KeyValueStorage? keyValueStorage,
  })  : _storage = keyValueStorage ?? LocalStorageService.instance,
        super(const AppSettings());

  final KeyValueStorage _storage;

  /// Loads persisted settings synchronously.
  ///
  /// Called once during app startup. If the theme key uses the legacy
  /// boolean scheme (true=dark), it is migrated to the new enum string.
  AppSettings loadSettings() {
    final language = AppLanguage.fromCode(
      _storage.getString(AppConstants.languagePrefKey),
    );

    var themeMode = AppThemeMode.fromCode(
      _storage.getString(AppConstants.themeModePrefKey),
    );

    // Legacy migration: previously the theme was stored as a bool.
    // `1`/`true` → dark, otherwise keep system default.
    final legacyBool = _storage.getBool(AppConstants.themeModePrefKey);
    if (legacyBool != null && themeMode == AppThemeMode.system) {
      themeMode = legacyBool ? AppThemeMode.dark : AppThemeMode.light;
    }

    final settings = AppSettings(
      language: language,
      themeMode: themeMode,
      mushafDarkBackground:
          _storage.getBool(AppConstants.quranMushafDarkPrefKey) ?? false,
    );

    emit(settings);
    return settings;
  }

  /// The active locale derived from the current settings.
  Locale get locale => state.language.locale;

  /// The active theme mode derived from the current settings.
  ThemeMode get themeMode => state.themeMode.mode;

  /// Sets the app language and persists it.
  Future<void> setLanguage(AppLanguage language) async {
    if (language == state.language) return;

    final updated = state.copyWith(language: language);
    emit(updated);

    unawaited(
      _storage
          .setString(AppConstants.languagePrefKey, language.code)
          .catchError((_) {}),
    );
  }

  /// Sets the theme mode and persists it.
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (mode == state.themeMode) return;

    final updated = state.copyWith(themeMode: mode);
    emit(updated);

    unawaited(
      _storage
          .setString(AppConstants.themeModePrefKey, mode.code)
          .catchError((_) {}),
    );
  }

  /// Toggles whether the Quran Mushaf page uses a dark parchment
  /// background when the app is in dark mode.
  Future<void> setMushafDarkBackground(bool enabled) async {
    if (enabled == state.mushafDarkBackground) return;

    final updated = state.copyWith(mushafDarkBackground: enabled);
    emit(updated);

    unawaited(
      _storage
          .setBool(AppConstants.quranMushafDarkPrefKey, enabled)
          .catchError((_) {}),
    );
  }

  /// Reads the Mushaf background preference directly.
  ///
  /// Keeps the reader page in sync even when the page is rendered outside
  /// of this cubit's rebuild scope.
  bool get preferMushafDarkBackground {
    return _storage.getBool(AppConstants.quranMushafDarkPrefKey) ?? false;
  }
}