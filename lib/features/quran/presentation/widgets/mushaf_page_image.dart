import 'package:flutter/material.dart';

/// Renders a single Medina Mushaf page image (001.png – 604.png).
///
/// The page image is displayed with a fixed light/white background so that
/// the transparent Uthmani-script text remains perfectly legible even when
/// the device is in system-wide Dark Mode.
class MushafPageImage extends StatefulWidget {
  const MushafPageImage({
    super.key,
    required this.pageNumber,
    this.backgroundColor,
  });

  /// The Mushaf page number (1–604).
  final int pageNumber;

  /// Optional background color behind the page image.
  final Color? backgroundColor;

  /// Builds the asset path for [pageNumber], e.g. `assets/pages/001.png`.
  static String assetPathFor(int pageNumber) {
    final padded = pageNumber.toString().padLeft(3, '0');
    return 'assets/pages/$padded.png';
  }

  @override
  State<MushafPageImage> createState() => _MushafPageImageState();
}

class _MushafPageImageState extends State<MushafPageImage> {
  @override
  Widget build(BuildContext context) {
    // Always use the user-selected background or fall back to a warm parchment
    // tone. DO NOT switch to a dark background in Dark Mode because the
    // Mushaf pages are transparent PNGs with black text — a dark background
    // would render the text invisible.
    final bg = widget.backgroundColor ?? const Color(0xFFFDF8EE);

    return Container(
      color: bg,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Image.asset(
          MushafPageImage.assetPathFor(widget.pageNumber),
          fit: BoxFit.contain,
          // High-quality rendering for the Uthmani script.
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            // Graceful fallback if a page image is missing.
            return _MissingPagePlaceholder(
              pageNumber: widget.pageNumber,
            );
          },
        ),
      ),
    );
  }
}

/// Shown when a page image asset is missing (e.g., during development
/// before all 604 images are bundled).
class _MissingPagePlaceholder extends StatelessWidget {
  const _MissingPagePlaceholder({
    required this.pageNumber,
  });

  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = Color(0xFF0E7A5F);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 64, color: accent),
          const SizedBox(height: 12),
          Text(
            'صفحة ${_toArabicDigits(pageNumber)}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'صورة المصحف غير متوفرة بعد',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _toArabicDigits(int value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return value.toString().split('').map((c) {
      final d = int.parse(c);
      return arabic[d];
    }).join();
  }
}