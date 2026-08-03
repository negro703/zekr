import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/quran_surahs_metadata.dart';
import '../bloc/quran_cubit.dart';
import '../bloc/quran_state.dart';

/// Full-screen Quran Index with two tabs:
///
/// - **السور**: all 114 Surahs with Makki/Madani badges, Ayah counts,
///   and starting Mushaf page numbers.
/// - **الأجزاء**: the 30 Juz with their starting pages.
///
/// Tapping any item closes the index (via [Navigator.pop]) and jumps the
/// [QuranCubit] (and thus the reader's PageView) to the matching page.
class QuranIndexPage extends StatefulWidget {
  const QuranIndexPage({super.key});

  @override
  State<QuranIndexPage> createState() => _QuranIndexPageState();
}

class _QuranIndexPageState extends State<QuranIndexPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Jumps the reader to [pageNumber] and closes this page.
  void _jumpToPage(BuildContext context, int pageNumber) {
    final cubit = context.read<QuranCubit>();
    cubit.changePage(pageNumber);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;
    final secondaryColor = isDark ? AppColors.goldLight : AppColors.gold;
    final currentPage =
        context.select((QuranCubit c) => c.state is QuranLoaded
            ? (c.state as QuranLoaded).currentPageNumber
            : 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفهرس'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: secondaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'السور'),
            Tab(text: 'الأجزاء'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SurahsTab(
            currentPage: currentPage,
            onSelected: (page) => _jumpToPage(context, page),
          ),
          _JuzTab(
            currentPage: currentPage,
            onSelected: (page) => _jumpToPage(context, page),
          ),
        ],
      ),
    );
  }
}

// ─── Surahs Tab ────────────────────────────────────────────────────────────────

class _SurahsTab extends StatelessWidget {
  const _SurahsTab({
    required this.currentPage,
    required this.onSelected,
  });

  final int currentPage;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: kQuranSurahs.length,
      itemBuilder: (context, index) {
        final surah = kQuranSurahs[index];
        final isCurrent = surah.startPage <= currentPage &&
            (index == kQuranSurahs.length - 1 ||
                kQuranSurahs[index + 1].startPage > currentPage);

        return _SurahTile(
          surah: surah,
          isCurrent: isCurrent,
          onTap: () => onSelected(surah.startPage),
        );
      },
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile({
    required this.surah,
    required this.isCurrent,
    required this.onTap,
  });

  final SurahMetadata surah;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;
    final goldColor = isDark ? AppColors.goldLight : AppColors.gold;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor.withValues(alpha: 0.12),
          border: Border.all(
            color: isCurrent ? goldColor : primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          _toArabicDigits(surah.number),
          style: theme.textTheme.titleSmall?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Row(
        children: [
          Text(
            'سورة ${surah.name}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: surah.isMakki
                  ? AppColors.emerald.withValues(alpha: 0.12)
                  : AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              surah.isMakki ? 'مكية' : 'مدنية',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: surah.isMakki
                    ? (isDark ? AppColors.emeraldLight : AppColors.emerald)
                    : (isDark ? AppColors.goldLight : AppColors.goldDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        '${_toArabicDigits(surah.ayahCount)} آية • تبدأ من صفحة ${_toArabicDigits(surah.startPage)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: isCurrent
          ? Icon(Icons.auto_stories, color: goldColor, size: 20)
          : Icon(Icons.chevron_left,
              color: theme.colorScheme.onSurfaceVariant, size: 20),
    );
  }
}

// ─── Juz Tab ───────────────────────────────────────────────────────────────────

class _JuzTab extends StatelessWidget {
  const _JuzTab({
    required this.currentPage,
    required this.onSelected,
  });

  final int currentPage;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;

    // Juz start pages (and the final page of the Mushaf).
    final List<int> startPages = List<int>.from(quranJuzStartPages);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: startPages.length,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final startPage = startPages[index];
        final isCurrent = currentPage >= startPage &&
            (index == startPages.length - 1 ||
                currentPage < startPages[index + 1]);

        return ListTile(
          onTap: () => onSelected(startPage),
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.12),
            ),
            child: Text(
              _toArabicDigits(juzNumber),
              style: theme.textTheme.titleSmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          title: Text(
            'الجزء ${_toArabicDigitsText(juzNumber)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            'يبدأ من صفحة ${_toArabicDigits(startPage)}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: isCurrent
              ? Icon(Icons.radio_button_checked,
                  color: primaryColor, size: 18)
              : Icon(Icons.chevron_left,
                  color: theme.colorScheme.onSurfaceVariant, size: 20),
        );
      },
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────────

String _toArabicDigits(int value) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  return value.toString().split('').map((c) {
    final d = int.parse(c);
    return arabic[d];
  }).join();
}

String _toArabicDigitsText(int value) => _toArabicDigits(value);