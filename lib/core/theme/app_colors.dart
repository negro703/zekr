import 'package:flutter/material.dart';

/// Central color palette for the Zekr application.
///
/// The palette is inspired by traditional Islamic art and architecture:
/// - Emerald green: The sacred color of Islam, representing paradise and life.
/// - Gold/amber: Symbolizing light, knowledge, and the divine.
/// - Deep teal: A serene, contemplative tone for dark mode surfaces.
/// - Cream/ivory: Warm, paper-like backgrounds evoking ancient manuscripts.
abstract final class AppColors {
  // ─── Brand Colors ────────────────────────────────────────────────────────────
  static const Color emerald = Color(0xFF0E7C66);
  static const Color emeraldDark = Color(0xFF0A5C4B);
  static const Color emeraldLight = Color(0xFF2E9E84);

  static const Color gold = Color(0xFFC9A227);
  static const Color goldLight = Color(0xFFE0BE5A);
  static const Color goldDark = Color(0xFF9A7B1C);

  // ─── Light Mode ──────────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFAF7F0); // Warm ivory
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1EBDF);
  static const Color lightTextPrimary = Color(0xFF1E2A2A);
  static const Color lightTextSecondary = Color(0xFF5C6B6B);
  static const Color lightDivider = Color(0xFFE3DCCB);

  // ─── Dark Mode ───────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1B1A); // Deep green-black
  static const Color darkSurface = Color(0xFF162624);
  static const Color darkSurfaceVariant = Color(0xFF1E322F);
  static const Color darkTextPrimary = Color(0xFFE8F0EC);
  static const Color darkTextSecondary = Color(0xFF9DB4AD);
  static const Color darkDivider = Color(0xFF2A3F3B);

  // ─── Semantic Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E9E84);
  static const Color warning = Color(0xFFC9A227);
  static const Color error = Color(0xFFB3261E);
  static const Color info = Color(0xFF2F6FED);

  // ─── Quran Page Backgrounds ──────────────────────────────────────────────────
  /// Traditional parchment tones for the Quran reader page backgrounds.
  static const List<Color> quranPageBackgrounds = [
    Color(0xFFFDF8EE), // Classic parchment
    Color(0xFFF5EFE0), // Aged paper
    Color(0xFFE8E0CC), // Antique beige
    Color(0xFFD9E8E3), // Soft sage
    Color(0xFFEAD9C8), // Warm sand
    Color(0xFFF0E6F2), // Pale lavender
  ];

  /// Dark parchment tones for night reading.
  static const List<Color> quranPageBackgroundsDark = [
    Color(0xFF1A2422),
    Color(0xFF202B28),
    Color(0xFF26332F),
    Color(0xFF2C3A36),
    Color(0xFF32413C),
    Color(0xFF384843),
  ];
}