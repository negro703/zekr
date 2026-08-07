/// Localization delegate + strings for the Zekr app.
///
/// Supports Arabic (default) and English. The app switches layout
/// direction automatically based on the active locale (RTL for Arabic,
/// LTR for English).
library;

import 'package:flutter/widgets.dart';

/// Base class holding all UI strings. Subclasses provide the actual
/// translated values for a given locale.
abstract class AppStrings {
  const AppStrings();

  /// Resolves the correct [AppStrings] for the nearest [BuildContext].
  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        const ArabicStrings();
  }

  // ─── App Identity ─────────────────────────────────────────────────────────
  String get appName;

  // ─── Home Navigation ──────────────────────────────────────────────────────
  String get navQuran;
  String get navAzkar;
  String get navSebha;
  String get navSettings;

  // ─── Common ───────────────────────────────────────────────────────────────
  String get retry;
  String get loading;
  String get cancel;
  String get close;

  // ─── Settings ─────────────────────────────────────────────────────────────
  String get settingsTitle;
  String get settingsSubtitle;
  String get sectionLanguage;
  String get sectionTheme;
  String get sectionNotifications;
  String get arabic;
  String get english;
  String get systemDefault;
  String get lightMode;
  String get darkMode;
  String get languageLabel;
  String get languageDialogTitle;
  String get themeDialogTitle;
  String get languageChanged;
  String get themeChanged;
  String get appLanguageDescription;
  String get themeDescription;

  // ─── Quran Reader ─────────────────────────────────────────────────────────
  String get quranLoading;
  String get quranReaderTitle;
  String get drawerReadingTools;
  String get drawerVirtueTitle;
  String get drawerNavigation;
  String get drawerIndex;
  String get drawerJuz;
  String get drawerPages;
  String get drawerExtraTools;
  String get drawerCompletionDua;
  String get drawerChangeBackground;
  String get virtueOfReadingQuran;
  String get duaOfCompletion;
  String get goToPage;
  String get changePageBackground;
  String get chooseBackgroundColor;
  String get bookmarkSaved;
  String get bookmarkGoTo;
  String get bookmarkNone;
  String get saveBookmark;
  String get surah;
  String get page;
  String get juz;
  String get hizb;
  String juzNumber(int number);
  String hizbNumber(int number);
  String pageNumber(int number);
  String ayahsCount(int count);
  String get makki;
  String get madani;
  String get indexTitle;
  String get surahsTab;
  String get juzTab;
  String get missingPageImage;
  String get errorLoadingQuran;
  String get noPagesAvailable;

  // ─── Azkar ────────────────────────────────────────────────────────────────
  String get azkarTitle;
  String get azkarLoading;

  // ─── Sebha ────────────────────────────────────────────────────────────────
  String get sebhaTitle;

  // ─── Notifications / Settings page ────────────────────────────────────────
  String get remindersTitle;
  String get mushafDarkBackground;
  String get mushafDarkBackgroundDescription;
  String get morningAzkar;
  String get eveningAzkar;
  String get salawatTitle;
  String get morningAzkarEnabled;
  String get eveningAzkarEnabled;
  String get salawatEnabled;
  String get reminderTime;
  String get intervalTitle;
  String intervalSubtitle(int minutes);
  String get customInterval;
  String get customIntervalHint;
  String get applyCustomInterval;
  String get chooseInterval;
  String get settingsLoading;
  String get settingsError;
  String morningReminderAt(int hour, int minute);
  String eveningReminderAt(int hour, int minute);
  String everyMinutes(int minutes);
  String everyHour(int hours);
  String everyHoursAndMinutes(int hours, int minutes);
  String everyMinuteAbbrev(int minutes);
  String everyHourAbbrev(int hours);
  String everyHourMinuteAbbrev(int hours, int minutes);
  String get minutesUnit;
  String errorIntervalRange(int min, int max);
}

/// Arabic (default) strings.
class ArabicStrings extends AppStrings {
  const ArabicStrings();

  @override
  String get appName => 'ذِكر';

  @override
  String get navQuran => 'القرآن';
  @override
  String get navAzkar => 'الأذكار';
  @override
  String get navSebha => 'السبحة';
  @override
  String get navSettings => 'الإعدادات';

  @override
  String get retry => 'إعادة المحاولة';
  @override
  String get loading => 'جاري التحميل...';
  @override
  String get cancel => 'إلغاء';
  @override
  String get close => 'إغلاق';

  @override
  String get settingsTitle => 'الإعدادات';
  @override
  String get settingsSubtitle => 'خيارات اللغة والمظهر والتذكيرات';
  @override
  String get sectionLanguage => 'اللغة';
  @override
  String get sectionTheme => 'المظهر';
  @override
  String get sectionNotifications => 'التذكيرات';
  @override
  String get arabic => 'العربية';
  @override
  String get english => 'English';
  @override
  String get systemDefault => 'حسب النظام';
  @override
  String get lightMode => 'الوضع الفاتح';
  @override
  String get darkMode => 'الوضع الداكن';
  @override
  String get languageLabel => 'لغة التطبيق';
  @override
  String get languageDialogTitle => 'اختر اللغة';
  @override
  String get themeDialogTitle => 'اختر المظهر';
  @override
  String get languageChanged => 'تم تغيير اللغة';
  @override
  String get themeChanged => 'تم تغيير المظهر';
  @override
  String get appLanguageDescription => 'اختر لغة العرض للتطبيق';
  @override
  String get themeDescription => 'تحكم في مظهر التطبيق';

  @override
  String get quranLoading => 'جاري تحميل المصحف الشريف...';
  @override
  String get quranReaderTitle => 'المصحف الشريف';
  @override
  String get drawerReadingTools => 'أدوات القراءة';
  @override
  String get drawerVirtueTitle => 'فضل قراءة القرآن';
  @override
  String get drawerNavigation => 'التنقل';
  @override
  String get drawerIndex => 'الفهرس';
  @override
  String get drawerJuz => 'الأجزاء';
  @override
  String get drawerPages => 'الصفحات';
  @override
  String get drawerExtraTools => 'أدوات إضافية';
  @override
  String get drawerCompletionDua => 'دعاء الختم';
  @override
  String get drawerChangeBackground => 'تغيير خلفية الصفحة';
  @override
  String get virtueOfReadingQuran => 'فضل قراءة القرآن الكريم';
  @override
  String get duaOfCompletion => 'دعاء ختم القرآن الكريم';
  @override
  String get goToPage => 'انتقال إلى صفحة';
  @override
  String get changePageBackground => 'تغيير خلفية الصفحة';
  @override
  String get chooseBackgroundColor => 'اختر لوناً مريحاً للقراءة الليلية';
  @override
  String get bookmarkSaved => 'تم حفظ العلامة في صفحة ';
  @override
  String get bookmarkGoTo => 'اذهب للعلامة';
  @override
  String get bookmarkNone => 'لا توجد علامة';
  @override
  String get saveBookmark => 'حفظ علامة';
  @override
  String get surah => 'سورة';
  @override
  String get page => 'صفحة';
  @override
  String get juz => 'الجزء';
  @override
  String get hizb => 'حزب';
  @override
  String juzNumber(int number) => 'الجزء ${_toArabicDigits(number)}';
  @override
  String hizbNumber(int number) => 'حزب ${_toArabicDigits(number)}';
  @override
  String pageNumber(int number) => 'صفحة ${_toArabicDigits(number)}';
  @override
  String ayahsCount(int count) => '${_toArabicDigits(count)} آية';
  @override
  String get makki => 'مكية';
  @override
  String get madani => 'مدنية';
  @override
  String get indexTitle => 'الفهرس';
  @override
  String get surahsTab => 'السور';
  @override
  String get juzTab => 'الأجزاء';
  @override
  String get missingPageImage => 'صورة المصحف غير متوفرة بعد';
  @override
  String get errorLoadingQuran => 'تعذر تحميل صفحات القرآن الكريم.';
  @override
  String get noPagesAvailable => 'لا توجد صفحات متاحة في المصحف.';

  @override
  String get azkarTitle => 'الأذكار';
  @override
  String get azkarLoading => 'جاري تحميل الأذكار...';

  @override
  String get sebhaTitle => 'السبحة';

  @override
  String get remindersTitle => 'إعدادات التذكيرات';
  @override
  String get mushafDarkBackground => 'خلفية مصحف داكنة';
  @override
  String get mushafDarkBackgroundDescription =>
      'استخدم خلفية داكنة لصفحات المصحف مع نصوص واضحة للقراءة الليلية';
  @override
  String get morningAzkar => 'أذكار الصباح';
  @override
  String get eveningAzkar => 'أذكار المساء';
  @override
  String get salawatTitle => 'الصلاة على النبي ﷺ';
  @override
  String get morningAzkarEnabled => 'تفعيل تذكير أذكار الصباح';
  @override
  String get eveningAzkarEnabled => 'تفعيل تذكير أذكار المساء';
  @override
  String get salawatEnabled => 'تفعيل التذكير الدوري';
  @override
  String get reminderTime => 'وقت التذكير';
  @override
  String get intervalTitle => 'الفاصل الزمني';
  @override
  String intervalSubtitle(int minutes) => _formatInterval(minutes);
  @override
  String get customInterval => 'فاصل مخصص بالدقائق';
  @override
  String get customIntervalHint => 'مثال: 25';
  @override
  String get applyCustomInterval => 'تطبيق الفاصل المخصص';
  @override
  String get chooseInterval => 'اختر فاصل زمني للصلاة على النبي ﷺ';
  @override
  String get settingsLoading => 'جاري تحميل الإعدادات...';
  @override
  String get settingsError => 'حدث خطأ أثناء تحميل الإعدادات';
  @override
  String morningReminderAt(int hour, int minute) =>
      'تذكير يومي في ${_formatTime(hour, minute)}';
  @override
  String eveningReminderAt(int hour, int minute) =>
      'تذكير يومي في ${_formatTime(hour, minute)}';
  @override
  String everyMinutes(int minutes) => 'كل ${_toArabicDigits(minutes)} دقيقة';
  @override
  String everyHour(int hours) => 'كل ${_toArabicDigits(hours)} ساعة';
  @override
  String everyHoursAndMinutes(int hours, int minutes) =>
      'كل ${_toArabicDigits(hours)} ساعة و ${_toArabicDigits(minutes)} دقيقة';
  @override
  String everyMinuteAbbrev(int minutes) => '${_toArabicDigits(minutes)} د';
  @override
  String everyHourAbbrev(int hours) => '${_toArabicDigits(hours)} س';
  @override
  String everyHourMinuteAbbrev(int hours, int minutes) =>
      '${_toArabicDigits(hours)}س ${_toArabicDigits(minutes)}د';
  @override
  String get minutesUnit => 'دقيقة';
  @override
  String errorIntervalRange(int min, int max) =>
      'أدخل قيمة بين ${_toArabicDigits(min)} و ${_toArabicDigits(max)} دقيقة';

  static String _toArabicDigits(int value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return value.toString().split('').map((c) {
      final d = int.parse(c);
      return arabic[d];
    }).join();
  }

  static String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return everyMinutes(minutes);
    if (minutes % 60 == 0) return everyHour(minutes ~/ 60);
    return everyHoursAndMinutes(minutes ~/ 60, minutes % 60);
  }
}

/// English strings.
class EnglishStrings extends AppStrings {
  const EnglishStrings();

  @override
  String get appName => 'Zekr';

  @override
  String get navQuran => 'Quran';
  @override
  String get navAzkar => 'Azkar';
  @override
  String get navSebha => 'Sebha';
  @override
  String get navSettings => 'Settings';

  @override
  String get retry => 'Retry';
  @override
  String get loading => 'Loading...';
  @override
  String get cancel => 'Cancel';
  @override
  String get close => 'Close';

  @override
  String get settingsTitle => 'Settings';
  @override
  String get settingsSubtitle => 'Language, appearance & reminders';
  @override
  String get sectionLanguage => 'Language';
  @override
  String get sectionTheme => 'Theme';
  @override
  String get sectionNotifications => 'Reminders';
  @override
  String get arabic => 'العربية';
  @override
  String get english => 'English';
  @override
  String get systemDefault => 'System Default';
  @override
  String get lightMode => 'Light Mode';
  @override
  String get darkMode => 'Dark Mode';
  @override
  String get languageLabel => 'App Language';
  @override
  String get languageDialogTitle => 'Choose Language';
  @override
  String get themeDialogTitle => 'Choose Theme';
  @override
  String get languageChanged => 'Language changed';
  @override
  String get themeChanged => 'Theme changed';
  @override
  String get appLanguageDescription => 'Select the display language for the app';
  @override
  String get themeDescription => 'Control the app appearance';

  @override
  String get quranLoading => 'Loading the Holy Mushaf...';
  @override
  String get quranReaderTitle => 'The Holy Mushaf';
  @override
  String get drawerReadingTools => 'Reading Tools';
  @override
  String get drawerVirtueTitle => 'Virtue of Reading Quran';
  @override
  String get drawerNavigation => 'Navigation';
  @override
  String get drawerIndex => 'Index';
  @override
  String get drawerJuz => 'Juz';
  @override
  String get drawerPages => 'Pages';
  @override
  String get drawerExtraTools => 'Extra Tools';
  @override
  String get drawerCompletionDua => 'Dua of Completion';
  @override
  String get drawerChangeBackground => 'Change Page Background';
  @override
  String get virtueOfReadingQuran => 'Virtue of Reading the Holy Quran';
  @override
  String get duaOfCompletion => 'Dua for Completing the Holy Quran';
  @override
  String get goToPage => 'Go to page';
  @override
  String get changePageBackground => 'Change Page Background';
  @override
  String get chooseBackgroundColor => 'Choose a comfortable color for night reading';
  @override
  String get bookmarkSaved => 'Bookmark saved on page ';
  @override
  String get bookmarkGoTo => 'Go to bookmark';
  @override
  String get bookmarkNone => 'No bookmark';
  @override
  String get saveBookmark => 'Save bookmark';
  @override
  String get surah => 'Surah';
  @override
  String get page => 'Page';
  @override
  String get juz => 'Juz';
  @override
  String get hizb => 'Hizb';
  @override
  String juzNumber(int number) => 'Juz $number';
  @override
  String hizbNumber(int number) => 'Hizb $number';
  @override
  String pageNumber(int number) => 'Page $number';
  @override
  String ayahsCount(int count) => '$count verses';
  @override
  String get makki => 'Makki';
  @override
  String get madani => 'Madani';
  @override
  String get indexTitle => 'Index';
  @override
  String get surahsTab => 'Surahs';
  @override
  String get juzTab => 'Juz';
  @override
  String get missingPageImage => 'Mushaf image not available yet';
  @override
  String get errorLoadingQuran => 'Could not load Quran pages.';
  @override
  String get noPagesAvailable => 'No pages available in the Mushaf.';

  @override
  String get azkarTitle => 'Azkar';
  @override
  String get azkarLoading => 'Loading azkar...';

  @override
  String get sebhaTitle => 'Sebha';

  @override
  String get remindersTitle => 'Reminders Settings';
  @override
  String get mushafDarkBackground => 'Dark Mushaf Background';
  @override
  String get mushafDarkBackgroundDescription =>
      'Use a dark background for Mushaf pages with clear text for night reading';
  @override
  String get morningAzkar => 'Morning Azkar';
  @override
  String get eveningAzkar => 'Evening Azkar';
  @override
  String get salawatTitle => 'Prayers on the Prophet ﷺ';
  @override
  String get morningAzkarEnabled => 'Enable Morning Azkar reminder';
  @override
  String get eveningAzkarEnabled => 'Enable Evening Azkar reminder';
  @override
  String get salawatEnabled => 'Enable periodic reminder';
  @override
  String get reminderTime => 'Reminder time';
  @override
  String get intervalTitle => 'Interval';
  @override
  String intervalSubtitle(int minutes) => _formatInterval(minutes);
  @override
  String get customInterval => 'Custom interval in minutes';
  @override
  String get customIntervalHint => 'e.g. 25';
  @override
  String get applyCustomInterval => 'Apply custom interval';
  @override
  String get chooseInterval => 'Choose an interval to pray upon the Prophet ﷺ';
  @override
  String get settingsLoading => 'Loading settings...';
  @override
  String get settingsError => 'An error occurred while loading settings';
  @override
  String morningReminderAt(int hour, int minute) =>
      'Daily reminder at ${_formatTime(hour, minute)}';
  @override
  String eveningReminderAt(int hour, int minute) =>
      'Daily reminder at ${_formatTime(hour, minute)}';
  @override
  String everyMinutes(int minutes) => 'Every $minutes minutes';
  @override
  String everyHour(int hours) =>
      'Every $hours hour${hours == 1 ? '' : 's'}';
  @override
  String everyHoursAndMinutes(int hours, int minutes) =>
      'Every $hours hour${hours == 1 ? '' : 's'} and '
      '$minutes minute${minutes == 1 ? '' : 's'}';
  @override
  String everyMinuteAbbrev(int minutes) => '${minutes}m';
  @override
  String everyHourAbbrev(int hours) => '${hours}h';
  @override
  String everyHourMinuteAbbrev(int hours, int minutes) => '${hours}h ${minutes}m';
  @override
  String get minutesUnit => 'minutes';
  @override
  String errorIntervalRange(int min, int max) =>
      'Enter a value between $min and $max minutes';

  static String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return everyMinutes(minutes);
    if (minutes % 60 == 0) return everyHour(minutes ~/ 60);
    return everyHoursAndMinutes(minutes ~/ 60, minutes % 60);
  }
}

/// Picks the correct [AppStrings] implementation for [locale].
AppStrings stringsFor(Locale locale) {
  return locale.languageCode == 'en' ? const EnglishStrings() : const ArabicStrings();
}

/// Locale extension helpers.
extension AppLocaleX on Locale {
  /// The display name of this locale in its own language.
  String get nativeName {
    return languageCode == 'en' ? 'English' : 'العربية';
  }
}