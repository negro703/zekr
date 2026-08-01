import 'package:equatable/equatable.dart';

import 'ayah_entity.dart';

/// Represents a single page of the Mushaf (Quran book) — pages 1 to 604.
///
/// Each page contains zero or more ayahs rendered in Uthmani script.
/// The page is the primary unit rendered in the Quran reader PageView.
class QuranPageEntity extends Equatable {
  const QuranPageEntity({
    required this.pageNumber,
    required this.ayahs,
    required this.juzNumber,
    this.surahName,
  });

  /// The Mushaf page number (1–604).
  final int pageNumber;

  /// The ayahs that appear on this page, in order.
  final List<AyahEntity> ayahs;

  /// The juz (part) number (1–30) this page belongs to.
  final int juzNumber;

  /// Primary surah name shown on this page (Arabic).
  /// May be null for pages that continue from a previous surah.
  final String? surahName;

  /// A copy of this entity with optional field overrides.
  QuranPageEntity copyWith({
    int? pageNumber,
    List<AyahEntity>? ayahs,
    int? juzNumber,
    String? surahName,
  }) {
    return QuranPageEntity(
      pageNumber: pageNumber ?? this.pageNumber,
      ayahs: ayahs ?? this.ayahs,
      juzNumber: juzNumber ?? this.juzNumber,
      surahName: surahName ?? this.surahName,
    );
  }

  @override
  List<Object?> get props => [pageNumber, ayahs, juzNumber, surahName];
}