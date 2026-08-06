/// Authentic Uthmani Mushaf pagination metadata.
///
/// Provides the canonical mapping between the 604 Mushaf page numbers
/// and the 30 Juz (parts), 60 Hizb (half-parts), and the starting page
/// of each of the 114 Surahs. Derived from the printed Uthmani Mushaf
/// (Madinah edition).
///
/// This allows every page (1–604) to render its correct Juz number,
/// Hizb, and determine which Surah banner appears at the top.
library;

/// The total number of pages in the standard Uthmani Mushaf.
const int kTotalMushafPages = 604;

/// The first Mushaf page (1–604) on which each of the 30 Juz begins.
///
/// These are the **authentic Medina Mushaf** Juz boundaries:
/// - Juz 1 starts on page 1, Juz 2 on page 22, Juz 3 on page 42, …
/// - Juz 30 starts on page 582.
///
/// Each Juz spans 20 pages (except Juz 30 which spans 582–604 = 22
/// pages). Every page belongs to exactly one Juz.
const List<int> kQuranJuzStartPages = <int>[
  1, 22, 42, 62, 82, 102, 122, 142, // Juz 1-8
  162, 182, 202, 222, 242, 262, 282, 302, // Juz 9-16
  322, 342, 362, 382, 402, 422, 442, 462, // Juz 17-24
  482, 502, 522, 542, 562, 582, // Juz 25-30
];

/// The first Mushaf page (1–604) on which each of the 60 Hizb begins.
///
/// Each Juz is split into two Hizb of 10 pages each (Juz 30's second
/// Hizb spans 592–604 = 13 pages). The boundaries below are aligned
/// with the [kQuranJuzStartPages] so that every page (1–604) maps to
/// exactly one Hizb (1–60).
const List<int> kQuranHizbStartPages = <int>[
  1, 11, 22, 32, 42, 52, 62, 72, 82, 92, // Hizb 1-10
  102, 112, 122, 132, 142, 152, 162, 172, 182, 192, // Hizb 11-20
  202, 212, 222, 232, 242, 252, 262, 272, 282, 292, // Hizb 21-30
  302, 312, 322, 332, 342, 352, 362, 372, 382, 392, // Hizb 31-40
  402, 412, 422, 432, 442, 452, 462, 472, 482, 492, // Hizb 41-50
  502, 512, 522, 532, 542, 552, 562, 572, 582, 592, // Hizb 51-60
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

/// Returns the Hizb (1–60) for a given [pageNumber] (1–604).
///
/// Walks backwards through [kQuranHizbStartPages]; the Hizb whose
/// start page is ≤ [pageNumber] is the correct one.
int hizbForPage(int pageNumber) {
  for (int i = kQuranHizbStartPages.length - 1; i >= 0; i--) {
    if (pageNumber >= kQuranHizbStartPages[i]) {
      return i + 1; // Hizb numbers are 1-based.
    }
  }
  return 1; // Fallback for page 0 or invalid.
}