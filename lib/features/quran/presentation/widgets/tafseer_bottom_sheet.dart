import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/quran_surahs_metadata.dart';
import '../../data/datasources/tafseer_local_data_source.dart';

/// Bottom sheet showing the easy tafseer (التفسير الميسر) and word
/// meanings (معاني الكلمات) for the surah containing [pageNumber].
///
/// The surah is derived from the canonical Mushaf pagination metadata.
class TafseerBottomSheet extends StatelessWidget {
  const TafseerBottomSheet({super.key, required this.pageNumber});

  /// The currently active Mushaf page (1–604).
  final int pageNumber;

  /// Shows the sheet for [pageNumber].
  static Future<void> show(BuildContext context, int pageNumber) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TafseerBottomSheet(pageNumber: pageNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;
    final secondaryColor = isDark ? AppColors.goldLight : AppColors.gold;

    final surah = surahForMushafPage(pageNumber);
    final tafseer = TafseerLocalDataSource.tafseerForSurah(surah.number);
    final wordMeanings =
        TafseerLocalDataSource.wordMeaningsForSurah(surah.number);

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Header ────────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_outlined, color: secondaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'التفسير الميسر',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'سورة ${surah.name} • صفحة ${_toArabicDigits(pageNumber)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Tafseer Body ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    tafseer,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.9,
                      fontSize: 16,
                    ),
                  ),
                ),

                // ─── Word Meanings ─────────────────────────────────────────────
                if (wordMeanings.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'معاني الكلمات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: secondaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...wordMeanings.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: secondaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.key,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: secondaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
              ],
            ),
          );
        },
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