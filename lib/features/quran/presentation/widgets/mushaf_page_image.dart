import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Renders a single Medina Mushaf page image (001.png – 604.png).
///
/// The page image is a transparent PNG with black Uthmani-script text.
/// In light mode it is rendered on a parchment background exactly as-is.
/// In dark mode the widget supports two strategies:
/// 1. **Mushaf-friendly dark background** ([useDarkParchment] = true):
///    renders on a dark parchment and applies a translucent white overlay
///    tint so the dark script remains legible against the darkened page.
/// 2. **Keep light page** ([useDarkParchment] = false): renders on the
///    usual light parchment even when the rest of the app is dark —
///    the reader keeps 100% contrast.
class MushafPageImage extends StatefulWidget {
  const MushafPageImage({
    super.key,
    required this.pageNumber,
    this.backgroundColor,
    this.useDarkParchment = false,
  });

  /// The Mushaf page number (1–604).
  final int pageNumber;

  /// Optional background color behind the page image.
  final Color? backgroundColor;

  /// Whether to use the dark parchment palette (with a white tint overlay)
  /// so the transparent text stays visible on a darkened page.
  final bool useDarkParchment;

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
    // Light parchment palette (default). The transparent black text
    // remains perfectly legible.
    final bg = widget.backgroundColor ?? const Color(0xFFFDF8EE);

    // Dark parchment palette with a translucent white overlay so the
    // Uthmani script stays visible on the darkened page.
    final darkBg = widget.backgroundColor ?? const Color(0xFF1A2422);
    final effectiveBg = widget.useDarkParchment ? darkBg : bg;

    return Container(
      color: effectiveBg,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Image.asset(
              MushafPageImage.assetPathFor(widget.pageNumber),
              fit: BoxFit.contain,
              // High-quality rendering for the Uthmani script.
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
              // When the dark parchment is active, apply a subtle white
              // tint over the image so the black text is lifted against
              // the dark background (makes it appear as soft white text
              // rather than invisible black-on-black).
              color: widget.useDarkParchment
                  ? Colors.white.withValues(alpha: 0.28)
                  : null,
              colorBlendMode: widget.useDarkParchment
                  ? BlendMode.lighten
                  : BlendMode.srcOver,
              errorBuilder: (context, error, stackTrace) {
                // Graceful fallback if a page image is missing.
                return _MissingPagePlaceholder(
                  pageNumber: widget.pageNumber,
                  useDarkParchment: widget.useDarkParchment,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when a page image asset is missing (e.g., during development
/// before all 604 images are bundled).
class _MissingPagePlaceholder extends StatelessWidget {
  const _MissingPagePlaceholder({
    required this.pageNumber,
    this.useDarkParchment = false,
  });

  final int pageNumber;
  final bool useDarkParchment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = useDarkParchment
        ? AppColors.emeraldLight
        : const Color(0xFF0E7A5F);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 64, color: accent),
          const SizedBox(height: 12),
          Text(
            _toArabicDigits(pageNumber),
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