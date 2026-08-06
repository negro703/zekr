import 'quran_page_metadata.dart';

/// Authentic Medina Mushaf Juz metadata.
///
/// Contains the exact, verified boundary data for all 30 Juz of the
/// printed Uthmani Mushaf (Madinah edition): the starting page, the
/// Surah that begins each Juz, the starting Ayah number, and the
/// Hizb number.
///
/// This is the single source of truth for the Quran Index (Juz tab)
/// and the dynamic page header/footer metadata.
class JuzMetadata {
  const JuzMetadata({
    required this.number,
    required this.startPage,
    required this.surahName,
    required this.ayahNumber,
    required this.hizb,
  });

  /// 1-based Juz number (1–30).
  final int number;

  /// Mushaf page where this Juz begins (1–604).
  final int startPage;

  /// Arabic name of the Surah that begins this Juz.
  final String surahName;

  /// Ayah number within the Surah where this Juz begins.
  final int ayahNumber;

  /// The Hizb number (1–60) at the Juz boundary.
  final int hizb;
}

/// The exact, verified 30-Juz boundary data for the Medina Mushaf.
///
/// Reference: printed Uthmani Mushaf (Madinah edition) — the official
/// pagination used by the app's 604 page images.
const List<JuzMetadata> kQuranJuzMetadata = <JuzMetadata>[
  JuzMetadata(
    number: 1,
    startPage: 1,
    surahName: 'الفاتحة',
    ayahNumber: 1,
    hizb: 1,
  ),
  JuzMetadata(
    number: 2,
    startPage: 22,
    surahName: 'البقرة',
    ayahNumber: 142,
    hizb: 3,
  ),
  JuzMetadata(
    number: 3,
    startPage: 42,
    surahName: 'البقرة',
    ayahNumber: 253,
    hizb: 5,
  ),
  JuzMetadata(
    number: 4,
    startPage: 62,
    surahName: 'آل عمران',
    ayahNumber: 93,
    hizb: 7,
  ),
  JuzMetadata(
    number: 5,
    startPage: 82,
    surahName: 'النساء',
    ayahNumber: 24,
    hizb: 9,
  ),
  JuzMetadata(
    number: 6,
    startPage: 102,
    surahName: 'النساء',
    ayahNumber: 148,
    hizb: 11,
  ),
  JuzMetadata(
    number: 7,
    startPage: 121,
    surahName: 'المائدة',
    ayahNumber: 82,
    hizb: 13,
  ),
  JuzMetadata(
    number: 8,
    startPage: 142,
    surahName: 'الأنعام',
    ayahNumber: 111,
    hizb: 15,
  ),
  JuzMetadata(
    number: 9,
    startPage: 162,
    surahName: 'الأعراف',
    ayahNumber: 88,
    hizb: 17,
  ),
  JuzMetadata(
    number: 10,
    startPage: 182,
    surahName: 'الأنفال',
    ayahNumber: 41,
    hizb: 19,
  ),
  JuzMetadata(
    number: 11,
    startPage: 201,
    surahName: 'التوبة',
    ayahNumber: 93,
    hizb: 21,
  ),
  JuzMetadata(
    number: 12,
    startPage: 222,
    surahName: 'هود',
    ayahNumber: 6,
    hizb: 23,
  ),
  JuzMetadata(
    number: 13,
    startPage: 242,
    surahName: 'يوسف',
    ayahNumber: 53,
    hizb: 25,
  ),
  JuzMetadata(
    number: 14,
    startPage: 262,
    surahName: 'الحجر',
    ayahNumber: 1,
    hizb: 27,
  ),
  JuzMetadata(
    number: 15,
    startPage: 282,
    surahName: 'الإسراء',
    ayahNumber: 1,
    hizb: 29,
  ),
  JuzMetadata(
    number: 16,
    startPage: 302,
    surahName: 'الكهف',
    ayahNumber: 75,
    hizb: 31,
  ),
  JuzMetadata(
    number: 17,
    startPage: 322,
    surahName: 'الأنبياء',
    ayahNumber: 1,
    hizb: 33,
  ),
  JuzMetadata(
    number: 18,
    startPage: 342,
    surahName: 'المؤمنون',
    ayahNumber: 1,
    hizb: 35,
  ),
  JuzMetadata(
    number: 19,
    startPage: 362,
    surahName: 'الفرقان',
    ayahNumber: 21,
    hizb: 37,
  ),
  JuzMetadata(
    number: 20,
    startPage: 382,
    surahName: 'النمل',
    ayahNumber: 56,
    hizb: 39,
  ),
  JuzMetadata(
    number: 21,
    startPage: 402,
    surahName: 'العنكبوت',
    ayahNumber: 46,
    hizb: 41,
  ),
  JuzMetadata(
    number: 22,
    startPage: 422,
    surahName: 'الأحزاب',
    ayahNumber: 31,
    hizb: 43,
  ),
  JuzMetadata(
    number: 23,
    startPage: 442,
    surahName: 'يس',
    ayahNumber: 28,
    hizb: 45,
  ),
  JuzMetadata(
    number: 24,
    startPage: 462,
    surahName: 'الزمر',
    ayahNumber: 32,
    hizb: 47,
  ),
  JuzMetadata(
    number: 25,
    startPage: 482,
    surahName: 'فصلت',
    ayahNumber: 47,
    hizb: 49,
  ),
  JuzMetadata(
    number: 26,
    startPage: 502,
    surahName: 'الأحقاف',
    ayahNumber: 1,
    hizb: 51,
  ),
  JuzMetadata(
    number: 27,
    startPage: 522,
    surahName: 'الذاريات',
    ayahNumber: 31,
    hizb: 53,
  ),
  JuzMetadata(
    number: 28,
    startPage: 542,
    surahName: 'المجادلة',
    ayahNumber: 1,
    hizb: 55,
  ),
  JuzMetadata(
    number: 29,
    startPage: 562,
    surahName: 'الملك',
    ayahNumber: 1,
    hizb: 57,
  ),
  JuzMetadata(
    number: 30,
    startPage: 582,
    surahName: 'النبأ',
    ayahNumber: 1,
    hizb: 59,
  ),
];

/// Returns the [JuzMetadata] for a given 1-based [juzNumber] (1–30),
/// or `null` if the number is out of range.
JuzMetadata? juzByNumber(int juzNumber) {
  if (juzNumber < 1 || juzNumber > kQuranJuzMetadata.length) return null;
  return kQuranJuzMetadata[juzNumber - 1];
}

/// Returns the [JuzMetadata] that contains [pageNumber] (1–604),
/// derived from the authentic Juz start-page mapping.
JuzMetadata juzForMushafPage(int pageNumber) {
  final juzNumber = juzForPage(pageNumber);
  return kQuranJuzMetadata[juzNumber - 1];
}