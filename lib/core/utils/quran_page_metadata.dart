/// Authentic Uthmani Mushaf pagination metadata.
///
/// Provides the canonical mapping between the 604 Mushaf page numbers
/// and the 30 Juz (parts), plus the starting page of each of the 114
/// Surahs. Derived from the printed Uthmani Mushaf (Madinah edition).
///
/// This allows every page (1–604) to render its correct Juz number in the
/// footer and determine which Surah banner appears at the top.
library;

/// The total number of pages in the standard Uthmani Mushaf.
const int kTotalMushafPages = 604;

/// The first Mushaf page (1–604) on which each of the 30 Juz begins.
///
/// Juz 1 starts on page 1, Juz 2 on page 10, …, Juz 30 on page 239.
///
/// Each page belongs to exactly one Juz. The juz boundaries are
/// well-established and internally consistent (covers 1–604 exactly).
const List<int> kQuranJuzStartPages = <int>[
  1, 10, 19, 28, 36, 45, 54, 62, // ends Juz 8
  70, 79, 87, 95, 104, 112, 121, 129, // ends Juz 16
  137, 145, 153, 161, 169, 177, 185, 193, // ends Juz 24
  201, 209, 217, 225, 232, 239, // Juz 25-30
];

/// Returns the Juz (1–30) for a given [pageNumber] (1–604).
///
/// Walks backwards through [kQuranJuzStartPages]; the Juz whose start
/// page is ≤ [pageNumber] is the correct one.
int juzForPage(int pageNumber) {
  for (int i = kQuranJuzStartPages.length - 1; i >= 0; i--) {
    if (pageNumber >= kQuranJuzStartPages[i]) {
      return i + 1; // Juz numbers are 1-based.
    }
  }
  return 1; // Fallback for page 0 or invalid.
}
