import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';

/// Paints a single Quran page's Uthmani script content.
///
/// Uses a warm parchment background appropriate for long reading sessions.
/// Displays the surah name as a header, the ayahs in a flowing column,
/// and the page number + juz number at the footer.
class PageContentWidget extends StatelessWidget {
  const PageContentWidget({
    super.key,
    required this.page,
    this.backgroundColor,
    this.fontSize = 24,
  });

  /// The Quran page entity to render.
  final QuranPageEntity page;

  /// Optional custom background color (for the page background feature).
  final Color? backgroundColor;

  /// Text size for the Uthmani script (user-adjustable).
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default to parchment-like colors matching the theme.
    final bg = backgroundColor ??
        (isDark ? AppColors.darkSurface : const Color(0xFFFDF8EE));

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Surah Name Header ───────────────────────────────────────────────
          if (page.surahName != null) ...[
            Text(
              page.surahName!,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDark ? AppColors.goldLight : AppColors.emerald,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Container(
                width: 48,
                height: 2,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.goldLight : AppColors.gold,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ─── Scrollable Ayah Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: page.ayahs.map((ayah) {
                  return _AyahRow(
                    ayah: ayah,
                    fontSize: fontSize,
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Page Footer (Juz + Page Number) ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Juz number
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.goldLight : AppColors.gold)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'الجزء ${_toArabicDigits(page.juzNumber)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.goldLight : AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Page number
                Text(
                  'صفحة ${_toArabicDigits(page.pageNumber)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Converts Western digits to Arabic-Indic digits for display.
  String _toArabicDigits(int value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return value.toString().split('').map((c) {
      final d = int.parse(c);
      return arabic[d];
    }).join();
  }
}

/// Renders a single ayah with its Uthmani text and ayah-number marker.
class _AyahRow extends StatelessWidget {
  const _AyahRow({
    required this.ayah,
    required this.fontSize,
  });

  final AyahEntity ayah;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: ayah.text,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: 'Cairo',
                height: 1.9,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            // Ayah number as a small golden marker.
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _AyahNumberBadge(
                  number: ayah.ayahNumber,
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

/// A circular badge showing an ayah number, reminiscent of printed Mushaf.
class _AyahNumberBadge extends StatelessWidget {
  const _AyahNumberBadge({
    required this.number,
    required this.isDark,
  });

  final int number;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.goldLight : AppColors.gold;

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}