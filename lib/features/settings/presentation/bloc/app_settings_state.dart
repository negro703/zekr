import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Supported app languages.
enum AppLanguage {
  /// Arabic (default, RTL).
  arabic,

  /// English (LTR).
  english;

  /// The [Locale] for this language.
  Locale get locale => this == AppLanguage.english
      ? const Locale('en')
      : const Locale('ar');

  /// Restores an [AppLanguage] from its persisted [String] code.
  static AppLanguage fromCode(String? code) {
    return code == 'en' ? AppLanguage.english : AppLanguage.arabic;
  }

  /// The stable [String] code persisted to storage.
  String get code => this == AppLanguage.english ? 'en' : 'ar';
}

/// The app-wide theme preference.
enum AppThemeMode {
  /// Follow the system brightness.
  system(ThemeMode.system),

  /// Always use light mode.
  light(ThemeMode.light),

  /// Always use dark mode.
  dark(ThemeMode.dark);

  const AppThemeMode(this.mode);

  /// The Flutter [ThemeMode] equivalent.
  final ThemeMode mode;

  /// Restores an [AppThemeMode] from its persisted [String] code.
  static AppThemeMode fromCode(String? code) {
    return switch (code) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
  }

  /// The stable [String] code persisted to storage.
  String get code => switch (this) {
        AppThemeMode.system => 'system',
        AppThemeMode.light => 'light',
        AppThemeMode.dark => 'dark',
      };
}

/// Immutable snapshot of the app-wide user preferences.
class AppSettings extends Equatable {
  const AppSettings({
    this.language = AppLanguage.arabic,
    this.themeMode = AppThemeMode.system,
    this.mushafDarkBackground = false,
  });

  /// The active display language.
  final AppLanguage language;

  /// The active theme mode.
  final AppThemeMode themeMode;

  /// Whether the Quran Mushaf page should use a darkened parchment
  /// background when the app is in dark mode.
  ///
  /// When `false` (default) the Mushaf page always keeps a light parchment
  /// so the translucent Uthmani text stays perfectly legible. When `true`
  /// the page uses the dark parchment palette designed for night reading.
  final bool mushafDarkBackground;

  /// Whether the app is currently rendering in dark mode.
  bool isDark([Brightness systemBrightness = Brightness.light]) {
    return switch (themeMode) {
      AppThemeMode.light => false,
      AppThemeMode.dark => true,
      AppThemeMode.system => systemBrightness == Brightness.dark,
    };
  }

  AppSettings copyWith({
    AppLanguage? language,
    AppThemeMode? themeMode,
    bool? mushafDarkBackground,
  }) {
    return AppSettings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      mushafDarkBackground: mushafDarkBackground ?? this.mushafDarkBackground,
    );
  }

  @override
  List<Object?> get props => [language, themeMode, mushafDarkBackground];
}