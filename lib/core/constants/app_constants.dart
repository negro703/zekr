import 'package:flutter/material.dart';

/// Application-wide constants for the Zekr app.
abstract final class AppConstants {
  // ─── App Identity ────────────────────────────────────────────────────────────
  static const String appName = 'Zekr';
  static const String appNameArabic = 'ذِكر';
  static const String appDescription =
      'تطبيق إسلامي شامل للقرآن الكريم والأذكار والسبحة';

  // ─── Localization ────────────────────────────────────────────────────────────
  /// The app defaults to Arabic and supports English.
  static const Locale defaultLocale = Locale('ar');
  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  // ─── Storage Keys ────────────────────────────────────────────────────────────
  static const String themeModePrefKey = 'theme_mode';
  static const String languagePrefKey = 'app_language';
  static const String fontSizePrefKey = 'font_size';
  static const String quranPageBackgroundPrefKey = 'quran_page_background';
  static const String quranMushafDarkPrefKey = 'quran_mushaf_dark';
  static const String lastReadPagePrefKey = 'last_read_page';
  static const String lastReadSurahPrefKey = 'last_read_surah';
  static const String lastReadAyahPrefKey = 'last_read_ayah';
  static const String quranBookmarkPrefKey = 'quran_bookmark_page';
  static const String sebhaCountPrefKey = 'sebha_count';
  static const String sebhaTotalRoundsPrefKey = 'sebha_total_rounds';
  static const String sebhaDhikrIndexPrefKey = 'sebha_dhikr_index';
  static const String azkarProgressPrefKey = 'azkar_progress';
  static const String morningAzkarEnabledPrefKey = 'morning_azkar_enabled';
  static const String morningAzkarHourPrefKey = 'morning_azkar_hour';
  static const String morningAzkarMinutePrefKey = 'morning_azkar_minute';
  static const String eveningAzkarEnabledPrefKey = 'evening_azkar_enabled';
  static const String eveningAzkarHourPrefKey = 'evening_azkar_hour';
  static const String eveningAzkarMinutePrefKey = 'evening_azkar_minute';
  static const String salawatEnabledPrefKey = 'salawat_enabled';
  static const String salawatIntervalHoursPrefKey = 'salawat_interval_hours';
  static const String salawatIntervalMinutesPrefKey = 'salawat_interval_minutes';
  static const String salawatIntervalIdPrefKey = 'salawat_interval_id';
  static const int defaultMorningHour = 6;
  static const int defaultEveningHour = 17;
  static const int defaultSalawatIntervalHours = 1;
  static const int defaultSalawatIntervalMinutes = 60;
  static const int minSalawatIntervalMinutes = 1;
  static const int maxSalawatIntervalMinutes = 24 * 60;

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

  /// The default set of dhikr phrases cycled through in the Sebha.
  static const List<String> defaultDhikrs = [
    'سُبْحَانَ الله',
    'الْحَمْدُ لِلَّهِ',
    'اللهُ أَكْبَرُ',
    'أَسْتَغْفِرُ الله',
    'لَا إِلَهَ إِلَّا الله',
    'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
    'سُبْحَانَ اللهِ الْعَظِيمِ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِالله',
  ];

  // ─── Layout ──────────────────────────────────────────────────────────────────
  static const double defaultPagePadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
}