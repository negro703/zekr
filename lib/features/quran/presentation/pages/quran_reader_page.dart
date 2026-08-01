import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/services.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/quran_cubit.dart';
import '../bloc/quran_state.dart';
import '../widgets/page_content_widget.dart';
import '../widgets/quran_drawer.dart';

/// The main Quran Reader page.
///
/// Displays the Quran as a horizontally scrollable [PageView] of
/// Uthmani-script pages, with an advanced drawer for navigation,
/// bookmarks, and reading tools.
class QuranReaderPage extends StatefulWidget {
  const QuranReaderPage({super.key});

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  late final QuranCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<QuranCubit>();
    // Load pages on startup.
    _cubit.loadQuranPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Syncs the PageView with the cubit when the current page changes
  /// (e.g., via drawer navigation or bookmark jump).
  void _syncPageView(QuranLoaded loaded) {
    final desiredIndex = _currentIndexFor(loaded);
    if (!_pageController.hasClients) return;

    final currentIndex = _pageController.page?.round() ?? 0;
    if (currentIndex != desiredIndex) {
      _pageController.jumpToPage(desiredIndex);
    }
  }

  /// Computes the 0-based PageView index for the loaded state.
  int _currentIndexFor(QuranLoaded loaded) {
    // Prefer the cubit's tracked index (fast O(1)).
    final cubitIndex = _cubit.currentPageIndex;
    if (cubitIndex >= 0 && cubitIndex < loaded.pages.length) {
      return cubitIndex;
    }
    // Fallback: derive from the page number.
    final pageIndex =
        loaded.pages.indexWhere((p) => p.pageNumber == loaded.currentPageNumber);
    return pageIndex < 0 ? loaded.currentPageNumber - 1 : pageIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const QuranDrawer(),
      // ─── App Bar (Drawer Trigger) ───────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'القائمة',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: BlocBuilder<QuranCubit, QuranState>(
          buildWhen: (previous, current) =>
              current is QuranLoaded &&
              (previous is! QuranLoaded ||
                  previous.currentPageNumber != current.currentPageNumber),
          builder: (context, state) {
            final isDark = theme.brightness == Brightness.dark;
            final pageNumber = state is QuranLoaded
                ? state.currentPageNumber
                : 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المصحف الشريف',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isDark ? AppColors.goldLight : AppColors.emerald,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.goldLight : AppColors.gold)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'صفحة ${_toArabicDigits(pageNumber)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.goldLight : AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // ─── Body: State-driven PageView ────────────────────────────────────────
      body: BlocBuilder<QuranCubit, QuranState>(
        buildWhen: (previous, current) =>
            current is QuranLoading ||
            current is QuranError ||
            (current is QuranLoaded &&
                (previous is! QuranLoaded ||
                    previous.pages != current.pages ||
                    previous.currentPageNumber != current.currentPageNumber)),
        builder: (context, state) {
          switch (state) {
            case QuranInitial():
            case QuranLoading():
              return const _QuranLoadingView();

            case QuranError(:final message):
              return _QuranErrorView(
                message: message,
                onRetry: _cubit.loadQuranPages,
              );

            case QuranLoaded():
              // Sync PageView when page changes (e.g., from drawer).
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _syncPageView(state);
              });

              return _QuranPageView(
                pageController: _pageController,
                loaded: state,
                onPageChanged: (index) {
                  // Convert PageView index → Mushaf page number.
                  final pageNumber = index + 1;
                  _cubit.changePage(pageNumber);
                },
              );
          }
        },
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

/// The horizontal PageView of Quran pages.
class _QuranPageView extends StatelessWidget {
  const _QuranPageView({
    required this.pageController,
    required this.loaded,
    required this.onPageChanged,
  });

  final PageController pageController;
  final QuranLoaded loaded;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgrounds = isDark
        ? AppColors.quranPageBackgroundsDark
        : AppColors.quranPageBackgrounds;

    // Use the saved page background preference (fall back to index 0).
    final bgIndex = (LocalStorageService.instance
                .getInt(AppConstants.quranPageBackgroundPrefKey,
                    defaultValue: 0) ??
            0)
        .clamp(0, backgrounds.length - 1);

    final backgroundColor = backgrounds[bgIndex];

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      onPageChanged: onPageChanged,
      itemCount: loaded.totalPages,
      // Optimize with a viewport pre-cache for smooth swiping.
      allowImplicitScrolling: true,
      itemBuilder: (context, index) {
        // Mushaf page number = index + 1.
        final pageNumber = index + 1;
        // Prefer the loaded page; fall back to a placeholder.
        final page = loaded.pageByNumber(pageNumber);

        return PageContentWidget(
          page: page ?? _placeholderPage(pageNumber, loaded),
          backgroundColor: backgroundColor,
        );
      },
    );
  }

  /// Creates a minimal placeholder page when the entity isn't loaded yet.
  QuranPageEntity _placeholderPage(int pageNumber, QuranLoaded loaded) {
    return QuranPageEntity(
      pageNumber: pageNumber,
      juzNumber: 1,
      surahName: null,
      ayahs: const [],
    );
  }
}

/// Loading indicator view.
class _QuranLoadingView extends StatelessWidget {
  const _QuranLoadingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.emeraldLight : AppColors.emerald;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل المصحف الشريف...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// Error view with retry button.
class _QuranErrorView extends StatelessWidget {
  const _QuranErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.emeraldLight : AppColors.emerald;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}