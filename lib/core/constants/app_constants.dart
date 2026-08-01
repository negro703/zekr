import 'package:flutter/material.dart';

/// Application-wide constants for the Zekr app.
abstract final class AppConstants {
  // ─── App Identity ────────────────────────────────────────────────────────────
  static const String appName = 'Zekr';
  static const String appNameArabic = 'ذِكر';
  static const String appDescription =
      'تطبيق إسلامي شامل للقرآن الكريم والأذكار والسبحة';

  // ─── Localization ────────────────────────────────────────────────────────────
  /// The app is Arabic-first and forces RTL layout globally.
  static const Locale defaultLocale = Locale('ar');
  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  // ─── Storage Keys ────────────────────────────────────────────────────────────
  static const String themeModePrefKey = 'theme_mode';
  static const String fontSizePrefKey = 'font_size';
  static const String quranPageBackgroundPrefKey = 'quran_page_background';
  static const String lastReadPagePrefKey = 'last_read_page';
  static const String lastReadSurahPrefKey = 'last_read_surah';
  static const String lastReadAyahPrefKey = 'last_read_ayah';
  static const String quranBookmarkPrefKey = 'quran_bookmark_page';
  static const String sebhaCountPrefKey = 'sebha_count';
  static const String azkarProgressPrefKey = 'azkar_progress';

  // ─── Hive Boxes ──────────────────────────────────────────────────────────────
  static const String settingsBox = 'settings_box';
  static const String quranBox = 'quran_box';
  static const String bookmarksBox = 'bookmarks_box';
  static const String azkarBox = 'azkar_box';
  static const String sebhaBox = 'sebha_box';

  // ─── Quran ───────────────────────────────────────────────────────────────────
  static const int totalSurahs = 114;
  static const int totalPages = 604;
  static const int quranPageSize = 15; // Lines per page in Uthmani script

  // ─── Notifications ───────────────────────────────────────────────────────────
  static const int morningAzkarNotificationId = 1001;
  static const int eveningAzkarNotificationId = 1002;
  static const int prayersOnProphetNotificationId = 1003;

  // ─── Sebha ───────────────────────────────────────────────────────────────────
  static const int defaultSebhaTarget = 33;
  static const List<int> sebhaPresets = [33, 66, 99, 100];

  // ─── Layout ──────────────────────────────────────────────────────────────────
  static const double defaultPagePadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
}