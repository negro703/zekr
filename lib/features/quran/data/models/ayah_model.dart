import '../../domain/entities/entities.dart';

/// Data model for a single ayah of the Quran.
///
/// Extends [AyahEntity] and adds JSON serialization support.
/// The JSON format follows a flat, page-indexed structure
/// optimized for efficient parsing and PageView rendering.
class AyahModel extends AyahEntity {
  const AyahModel({
    required super.id,
    required super.ayahNumber,
    required super.text,
    required super.pageNumber,
    required super.surahNumber,
    required super.surahName,
    required super.juzNumber,
  });

  /// Creates an [AyahModel] from a JSON map.
  ///
  /// The expected JSON keys are:
  /// - `id` (int, required) — global ayah identifier
  /// - `surahNumber` (int, required) — surah number 1–114
  /// - `surahName` (String, required) — surah name in Arabic
  /// - `ayahNumber` (int, required) — ayah number within surah
  /// - `juzNumber` (int, required) — juz number 1–30
  /// - `pageNumber` (int, required) — Mushaf page number 1–604
  /// - `text` (String, required) — Uthmani script text
  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      id: json['id'] as int,
      ayahNumber: json['ayahNumber'] as int,
      text: json['text'] as String,
      pageNumber: json['pageNumber'] as int,
      surahNumber: json['surahNumber'] as int,
      surahName: json['surahName'] as String,
      juzNumber: json['juzNumber'] as int,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ayahNumber': ayahNumber,
      'text': text,
      'pageNumber': pageNumber,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'juzNumber': juzNumber,
    };
  }

  /// Creates a model from an [AyahEntity], preserving all fields.
  factory AyahModel.fromEntity(AyahEntity entity) {
    return AyahModel(
      id: entity.id,
      ayahNumber: entity.ayahNumber,
      text: entity.text,
      pageNumber: entity.pageNumber,
      surahNumber: entity.surahNumber,
      surahName: entity.surahName,
      juzNumber: entity.juzNumber,
    );
  }
}