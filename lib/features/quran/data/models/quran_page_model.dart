import '../../domain/entities/entities.dart';
import 'ayah_model.dart';

/// Data model for a single Mushaf page.
///
/// Extends [QuranPageEntity] and adds JSON serialization support.
class QuranPageModel extends QuranPageEntity {
  const QuranPageModel({
    required super.pageNumber,
    required super.ayahs,
    required super.juzNumber,
    super.surahName,
  });

  /// Creates a [QuranPageModel] from a JSON map.
  ///
  /// The expected JSON keys are:
  /// - `pageNumber` (int, required) — Mushaf page number 1–604
  /// - `juzNumber` (int, required) — juz number 1–30
  /// - `surahName` (String, optional) — primary surah name in Arabic
  /// - `ayahs` (`List<Map<String, dynamic>>`, required) — list of ayah JSON objects
  factory QuranPageModel.fromJson(Map<String, dynamic> json) {
    final rawAyahs = json['ayahs'] as List<dynamic>? ?? const [];
    final ayahs = rawAyahs
        .map((e) => AyahModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return QuranPageModel(
      pageNumber: json['pageNumber'] as int,
      ayahs: ayahs,
      juzNumber: json['juzNumber'] as int,
      surahName: json['surahName'] as String?,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'ayahs': ayahs.map((e) => (e as AyahModel).toJson()).toList(),
      'juzNumber': juzNumber,
      'surahName': surahName,
    };
  }

  /// Creates a model from a [QuranPageEntity], mapping all ayahs
  /// to [AyahModel] instances.
  factory QuranPageModel.fromEntity(QuranPageEntity entity) {
    return QuranPageModel(
      pageNumber: entity.pageNumber,
      ayahs: entity.ayahs.map(AyahModel.fromEntity).toList(),
      juzNumber: entity.juzNumber,
      surahName: entity.surahName,
    );
  }
}