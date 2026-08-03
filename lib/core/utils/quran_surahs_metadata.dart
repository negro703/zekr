import 'quran_page_metadata.dart';

/// Metadata for a single Surah used by the Quran Index.
class SurahMetadata {
  const SurahMetadata({
    required this.number,
    required this.name,
    required this.startPage,
    required this.ayahCount,
    required this.isMakki,
  });

  /// 1-based surah number (1–114).
  final int number;

  /// Arabic name (e.g. 'الفاتحة').
  final String name;

  /// Mushaf page where this surah begins (1–604).
  final int startPage;

  /// Number of ayat in this surah.
  final int ayahCount;

  /// Whether the surah was revealed in Makkah (`true`) or Madinah (`false`).
  final bool isMakki;
}

/// The full list of 114 Surahs with authentic Mushaf pagination,
/// Ayah counts, and Makki/Madani classification.
///
/// Reference: Madinah Uthmani Mushaf pagination + traditional tafsir
/// classification.
const List<SurahMetadata> kQuranSurahs = <SurahMetadata>[
  SurahMetadata(number: 1, name: 'الفاتحة', startPage: 1, ayahCount: 7, isMakki: true),
  SurahMetadata(number: 2, name: 'البقرة', startPage: 2, ayahCount: 286, isMakki: false),
  SurahMetadata(number: 3, name: 'آل عمران', startPage: 50, ayahCount: 200, isMakki: false),
  SurahMetadata(number: 4, name: 'النساء', startPage: 77, ayahCount: 176, isMakki: false),
  SurahMetadata(number: 5, name: 'المائدة', startPage: 106, ayahCount: 120, isMakki: false),
  SurahMetadata(number: 6, name: 'الأنعام', startPage: 128, ayahCount: 165, isMakki: true),
  SurahMetadata(number: 7, name: 'الأعراف', startPage: 151, ayahCount: 206, isMakki: true),
  SurahMetadata(number: 8, name: 'الأنفال', startPage: 177, ayahCount: 75, isMakki: false),
  SurahMetadata(number: 9, name: 'التوبة', startPage: 187, ayahCount: 129, isMakki: false),
  SurahMetadata(number: 10, name: 'يونس', startPage: 208, ayahCount: 109, isMakki: true),
  SurahMetadata(number: 11, name: 'هود', startPage: 221, ayahCount: 123, isMakki: true),
  SurahMetadata(number: 12, name: 'يوسف', startPage: 235, ayahCount: 111, isMakki: true),
  SurahMetadata(number: 13, name: 'الرعد', startPage: 249, ayahCount: 43, isMakki: false),
  SurahMetadata(number: 14, name: 'إبراهيم', startPage: 255, ayahCount: 52, isMakki: true),
  SurahMetadata(number: 15, name: 'الحجر', startPage: 262, ayahCount: 99, isMakki: true),
  SurahMetadata(number: 16, name: 'النحل', startPage: 267, ayahCount: 128, isMakki: true),
  SurahMetadata(number: 17, name: 'الإسراء', startPage: 282, ayahCount: 111, isMakki: true),
  SurahMetadata(number: 18, name: 'الكهف', startPage: 293, ayahCount: 110, isMakki: true),
  SurahMetadata(number: 19, name: 'مريم', startPage: 305, ayahCount: 98, isMakki: true),
  SurahMetadata(number: 20, name: 'طه', startPage: 312, ayahCount: 135, isMakki: true),
  SurahMetadata(number: 21, name: 'الأنبياء', startPage: 322, ayahCount: 112, isMakki: true),
  SurahMetadata(number: 22, name: 'الحج', startPage: 332, ayahCount: 78, isMakki: false),
  SurahMetadata(number: 23, name: 'المؤمنون', startPage: 342, ayahCount: 118, isMakki: true),
  SurahMetadata(number: 24, name: 'النور', startPage: 350, ayahCount: 64, isMakki: false),
  SurahMetadata(number: 25, name: 'الفرقان', startPage: 359, ayahCount: 77, isMakki: true),
  SurahMetadata(number: 26, name: 'الشعراء', startPage: 367, ayahCount: 227, isMakki: true),
  SurahMetadata(number: 27, name: 'النمل', startPage: 377, ayahCount: 93, isMakki: true),
  SurahMetadata(number: 28, name: 'القصص', startPage: 385, ayahCount: 88, isMakki: true),
  SurahMetadata(number: 29, name: 'العنكبوت', startPage: 396, ayahCount: 69, isMakki: true),
  SurahMetadata(number: 30, name: 'الروم', startPage: 404, ayahCount: 60, isMakki: true),
  SurahMetadata(number: 31, name: 'لقمان', startPage: 411, ayahCount: 34, isMakki: true),
  SurahMetadata(number: 32, name: 'السجدة', startPage: 415, ayahCount: 30, isMakki: true),
  SurahMetadata(number: 33, name: 'الأحزاب', startPage: 418, ayahCount: 73, isMakki: false),
  SurahMetadata(number: 34, name: 'سبأ', startPage: 428, ayahCount: 54, isMakki: true),
  SurahMetadata(number: 35, name: 'فاطر', startPage: 434, ayahCount: 45, isMakki: true),
  SurahMetadata(number: 36, name: 'يس', startPage: 440, ayahCount: 83, isMakki: true),
  SurahMetadata(number: 37, name: 'الصافات', startPage: 446, ayahCount: 182, isMakki: true),
  SurahMetadata(number: 38, name: 'ص', startPage: 453, ayahCount: 88, isMakki: true),
  SurahMetadata(number: 39, name: 'الزمر', startPage: 458, ayahCount: 75, isMakki: true),
  SurahMetadata(number: 40, name: 'غافر', startPage: 467, ayahCount: 85, isMakki: true),
  SurahMetadata(number: 41, name: 'فصلت', startPage: 477, ayahCount: 54, isMakki: true),
  SurahMetadata(number: 42, name: 'الشورى', startPage: 483, ayahCount: 53, isMakki: true),
  SurahMetadata(number: 43, name: 'الزخرف', startPage: 489, ayahCount: 89, isMakki: true),
  SurahMetadata(number: 44, name: 'الدخان', startPage: 496, ayahCount: 59, isMakki: true),
  SurahMetadata(number: 45, name: 'الجاثية', startPage: 500, ayahCount: 37, isMakki: true),
  SurahMetadata(number: 46, name: 'الأحقاف', startPage: 504, ayahCount: 35, isMakki: true),
  SurahMetadata(number: 47, name: 'محمد', startPage: 507, ayahCount: 38, isMakki: false),
  SurahMetadata(number: 48, name: 'الفتح', startPage: 511, ayahCount: 29, isMakki: false),
  SurahMetadata(number: 49, name: 'الحجرات', startPage: 515, ayahCount: 18, isMakki: false),
  SurahMetadata(number: 50, name: 'ق', startPage: 518, ayahCount: 45, isMakki: true),
  SurahMetadata(number: 51, name: 'الذاريات', startPage: 520, ayahCount: 60, isMakki: true),
  SurahMetadata(number: 52, name: 'الطور', startPage: 523, ayahCount: 49, isMakki: true),
  SurahMetadata(number: 53, name: 'النجم', startPage: 526, ayahCount: 62, isMakki: true),
  SurahMetadata(number: 54, name: 'القمر', startPage: 528, ayahCount: 55, isMakki: true),
  SurahMetadata(number: 55, name: 'الرحمن', startPage: 531, ayahCount: 78, isMakki: false),
  SurahMetadata(number: 56, name: 'الواقعة', startPage: 534, ayahCount: 96, isMakki: true),
  SurahMetadata(number: 57, name: 'الحديد', startPage: 537, ayahCount: 29, isMakki: false),
  SurahMetadata(number: 58, name: 'المجادلة', startPage: 542, ayahCount: 22, isMakki: false),
  SurahMetadata(number: 59, name: 'الحشر', startPage: 545, ayahCount: 24, isMakki: false),
  SurahMetadata(number: 60, name: 'الممتحنة', startPage: 549, ayahCount: 13, isMakki: false),
  SurahMetadata(number: 61, name: 'الصف', startPage: 551, ayahCount: 14, isMakki: false),
  SurahMetadata(number: 62, name: 'الجمعة', startPage: 553, ayahCount: 11, isMakki: false),
  SurahMetadata(number: 63, name: 'المنافقون', startPage: 554, ayahCount: 11, isMakki: false),
  SurahMetadata(number: 64, name: 'التغابن', startPage: 556, ayahCount: 18, isMakki: false),
  SurahMetadata(number: 65, name: 'الطلاق', startPage: 558, ayahCount: 12, isMakki: false),
  SurahMetadata(number: 66, name: 'التحريم', startPage: 560, ayahCount: 12, isMakki: false),
  SurahMetadata(number: 67, name: 'الملك', startPage: 562, ayahCount: 30, isMakki: true),
  SurahMetadata(number: 68, name: 'القلم', startPage: 564, ayahCount: 52, isMakki: true),
  SurahMetadata(number: 69, name: 'الحاقة', startPage: 566, ayahCount: 52, isMakki: true),
  SurahMetadata(number: 70, name: 'المعارج', startPage: 568, ayahCount: 44, isMakki: true),
  SurahMetadata(number: 71, name: 'نوح', startPage: 570, ayahCount: 28, isMakki: true),
  SurahMetadata(number: 72, name: 'الجن', startPage: 572, ayahCount: 28, isMakki: true),
  SurahMetadata(number: 73, name: 'المزمل', startPage: 574, ayahCount: 20, isMakki: true),
  SurahMetadata(number: 74, name: 'المدثر', startPage: 575, ayahCount: 56, isMakki: true),
  SurahMetadata(number: 75, name: 'القيامة', startPage: 577, ayahCount: 40, isMakki: true),
  SurahMetadata(number: 76, name: 'الإنسان', startPage: 578, ayahCount: 31, isMakki: true),
  SurahMetadata(number: 77, name: 'المرسلات', startPage: 580, ayahCount: 50, isMakki: true),
  SurahMetadata(number: 78, name: 'النبأ', startPage: 582, ayahCount: 40, isMakki: true),
  SurahMetadata(number: 79, name: 'النازعات', startPage: 583, ayahCount: 46, isMakki: true),
  SurahMetadata(number: 80, name: 'عبس', startPage: 585, ayahCount: 42, isMakki: true),
  SurahMetadata(number: 81, name: 'التكوير', startPage: 586, ayahCount: 29, isMakki: true),
  SurahMetadata(number: 82, name: 'الانفطار', startPage: 587, ayahCount: 19, isMakki: true),
  SurahMetadata(number: 83, name: 'المطففين', startPage: 587, ayahCount: 36, isMakki: true),
  SurahMetadata(number: 84, name: 'الانشقاق', startPage: 589, ayahCount: 25, isMakki: true),
  SurahMetadata(number: 85, name: 'البروج', startPage: 590, ayahCount: 22, isMakki: true),
  SurahMetadata(number: 86, name: 'الطارق', startPage: 591, ayahCount: 17, isMakki: true),
  SurahMetadata(number: 87, name: 'الأعلى', startPage: 591, ayahCount: 19, isMakki: true),
  SurahMetadata(number: 88, name: 'الغاشية', startPage: 592, ayahCount: 26, isMakki: true),
  SurahMetadata(number: 89, name: 'الفجر', startPage: 593, ayahCount: 30, isMakki: true),
  SurahMetadata(number: 90, name: 'البلد', startPage: 594, ayahCount: 20, isMakki: true),
  SurahMetadata(number: 91, name: 'الشمس', startPage: 595, ayahCount: 15, isMakki: true),
  SurahMetadata(number: 92, name: 'الليل', startPage: 595, ayahCount: 21, isMakki: true),
  SurahMetadata(number: 93, name: 'الضحى', startPage: 596, ayahCount: 11, isMakki: true),
  SurahMetadata(number: 94, name: 'الشرح', startPage: 596, ayahCount: 8, isMakki: true),
  SurahMetadata(number: 95, name: 'التين', startPage: 597, ayahCount: 8, isMakki: true),
  SurahMetadata(number: 96, name: 'العلق', startPage: 597, ayahCount: 19, isMakki: true),
  SurahMetadata(number: 97, name: 'القدر', startPage: 598, ayahCount: 5, isMakki: true),
  SurahMetadata(number: 98, name: 'البينة', startPage: 598, ayahCount: 8, isMakki: false),
  SurahMetadata(number: 99, name: 'الزلزلة', startPage: 599, ayahCount: 8, isMakki: true),
  SurahMetadata(number: 100, name: 'العاديات', startPage: 599, ayahCount: 11, isMakki: true),
  SurahMetadata(number: 101, name: 'القارعة', startPage: 600, ayahCount: 11, isMakki: true),
  SurahMetadata(number: 102, name: 'التكاثر', startPage: 600, ayahCount: 8, isMakki: true),
  SurahMetadata(number: 103, name: 'العصر', startPage: 601, ayahCount: 3, isMakki: true),
  SurahMetadata(number: 104, name: 'الهمزة', startPage: 601, ayahCount: 9, isMakki: true),
  SurahMetadata(number: 105, name: 'الفيل', startPage: 601, ayahCount: 5, isMakki: true),
  SurahMetadata(number: 106, name: 'قريش', startPage: 602, ayahCount: 4, isMakki: true),
  SurahMetadata(number: 107, name: 'الماعون', startPage: 602, ayahCount: 7, isMakki: true),
  SurahMetadata(number: 108, name: 'الكوثر', startPage: 602, ayahCount: 3, isMakki: true),
  SurahMetadata(number: 109, name: 'الكافرون', startPage: 603, ayahCount: 6, isMakki: true),
  SurahMetadata(number: 110, name: 'النصر', startPage: 603, ayahCount: 3, isMakki: false),
  SurahMetadata(number: 111, name: 'المسد', startPage: 603, ayahCount: 5, isMakki: true),
  SurahMetadata(number: 112, name: 'الإخلاص', startPage: 604, ayahCount: 4, isMakki: true),
  SurahMetadata(number: 113, name: 'الفلق', startPage: 604, ayahCount: 5, isMakki: true),
  SurahMetadata(number: 114, name: 'الناس', startPage: 604, ayahCount: 6, isMakki: true),
];

/// Returns the [SurahMetadata] for a given 1-based [surahNumber],
/// or `null` if the number is out of range.
SurahMetadata? surahByNumber(int surahNumber) {
  if (surahNumber < 1 || surahNumber > kQuranSurahs.length) return null;
  return kQuranSurahs[surahNumber - 1];
}

/// Returns the Surah that contains [pageNumber] (1–604), derived from
/// the surah start-page mapping.
SurahMetadata surahForMushafPage(int pageNumber) {
  for (int i = kQuranSurahs.length - 1; i >= 0; i--) {
    if (pageNumber >= kQuranSurahs[i].startPage) {
      return kQuranSurahs[i];
    }
  }
  return kQuranSurahs.first;
}

/// The 30 Juz entries exposed through [kQuranJuzStartPages].
List<int> get quranJuzStartPages => kQuranJuzStartPages;