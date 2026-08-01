import 'package:equatable/equatable.dart';

/// Represents a single ayah (verse) of the Quran.
///
/// Contains both the metadata and the Uthmani script text needed
/// for rendering within the Quran reader PageView.
class AyahEntity extends Equatable {
  const AyahEntity({
    required this.id,
    required this.ayahNumber,
    required this.text,
    required this.pageNumber,
    required this.surahNumber,
    required this.surahName,
    required this.juzNumber,
  });

  /// Unique global identifier for the ayah
  /// (e.g., 1-based sequential index across the entire Quran: 1–6236).
  final int id;

  /// The ayah's number within its surah (1-based).
  final int ayahNumber;

  /// The Uthmani script text of the ayah.
  final String text;

  /// The Mushaf page number (1–604) this ayah appears on.
  final int pageNumber;

  /// The surah number (1–114) this ayah belongs to.
  final int surahNumber;

  /// The name of the surah in Arabic.
  final String surahName;

  /// The juz (part) number (1–30) this ayah belongs to.
  final int juzNumber;

  /// A copy of this entity with optional field overrides.
  AyahEntity copyWith({
    int? id,
    int? ayahNumber,
    String? text,
    int? pageNumber,
    int? surahNumber,
    String? surahName,
    int? juzNumber,
  }) {
    return AyahEntity(
      id: id ?? this.id,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      text: text ?? this.text,
      pageNumber: pageNumber ?? this.pageNumber,
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      juzNumber: juzNumber ?? this.juzNumber,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ayahNumber,
        text,
        pageNumber,
        surahNumber,
        surahName,
        juzNumber,
      ];
}