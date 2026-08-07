import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/services/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/quran_page_metadata.dart';
import '../../../../core/utils/quran_surahs_metadata.dart';
import '../../../settings/settings.dart';
import '../bloc/quran_cubit.dart';
import '../bloc/quran_state.dart';
import '../widgets/mushaf_page_image.dart';
import '../widgets/quran_drawer.dart';

/// The main Quran Reader page.
///
/// Displays the Quran as a horizontally scrollable [PageView] of
/// Uthmani-script pages, with an advanced drawer for navigation,
/// bookmarks, and reading tools.
///
/// The reader is **immersive by default**: the AppBar and metadata bars
/// are hidden so the Mushaf page fills 100% of the screen. Tapping the
/// screen toggles the bars on/off. A smooth page-turn animation mimics
/// flipping physical pages of the Mushaf.
class QuranReaderPage extends StatefulWidget {
  const QuranReaderPage({super.key});

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController? _pageController;
  late final QuranCubit _cubit;

  /// Whether the AppBar and metadata bars are visible.
  bool _controlsVisible = false;

  /// Timer to auto-hide the controls after a short delay.
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<QuranCubit>();
    // Load pages on startup.
    _cubit.loadQuranPages();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  /// Toggles the visibility of the AppBar and metadata bars.
  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    _scheduleAutoHide();
  }

  /// Schedules auto-hiding of the controls after a short delay.
  void _scheduleAutoHide() {
    _hideTimer?.cancel();
    if (!_controlsVisible) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  /// Lazily creates the [PageController] pinned to the cubit's restored
  /// page index.
  ///
  /// Initializing the controller with the exact saved index (rather than
  /// defaulting to page 0) guarantees the [PageView] renders the user's
  /// last-read page on the very first frame — keeping the AppBar, the
  /// Mushaf metadata bars, and the page content 100% in sync.
  PageController _ensurePageController() {
    final existing = _pageController;
    if (existing != null) return existing;

    final controller = PageController(initialPage: _cubit.currentPageIndex);
    _pageController = controller;
    return controller;
  }

  /// Syncs the PageView with the cubit when the current page changes
  /// (e.g., via drawer navigation or bookmark jump).
  void _syncPageView(QuranLoaded loaded) {
    final pageController = _pageController;
    if (pageController == null || !pageController.hasClients) return;

    final desiredIndex = _currentIndexFor(loaded);
    final currentIndex = pageController.page?.round() ?? 0;
    if (currentIndex != desiredIndex) {
      pageController.jumpToPage(desiredIndex);
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
      // ─── App Bar (Drawer Trigger) — hidden by default ───────────────────────
      appBar: _controlsVisible
          ? AppBar(
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
                  final strings = AppStrings.of(context);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.quranReaderTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isDark
                              ? AppColors.goldLight
                              : AppColors.emerald,
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
                          color: (isDark
                                  ? AppColors.goldLight
                                  : AppColors.gold)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          strings.pageNumber(pageNumber),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.goldLight
                                : AppColors.goldDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          : null,

      // ─── Body: State-driven PageView with Mushaf metadata overlay ───────────
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
              // Create the controller pinned to the restored page index so
              // the PageView renders the saved page from the first frame.
              final pageController = _ensurePageController();

              // Sync remaining PageView moves (e.g., drawer/bookmark jumps).
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _syncPageView(state);
              });

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleControls,
                child: Stack(
                  children: [
                    // ─── PageView (fills 100% of the screen) ─────────────────
                    Positioned.fill(
                      child: _QuranPageView(
                        pageController: pageController,
                        loaded: state,
                        useDarkParchment: context
                            .select<AppSettingsCubit, bool>(
                              (c) => c.state.mushafDarkBackground,
                            ),
                        onPageChanged: (index) {
                          // Convert PageView index → Mushaf page number.
                          final pageNumber = index + 1;
                          _cubit.changePage(pageNumber);
                        },
                      ),
                    ),

                    // ─── Top Mushaf Metadata Bar (animated) ──────────────────
                    if (_controlsVisible)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _AnimatedMushafBar(
                          visible: _controlsVisible,
                          child: _MushafMetadataBar(
                            pageNumber: state.currentPageNumber,
                            alignment: _MushafBarAlignment.top,
                          ),
                        ),
                      ),

                    // ─── Bottom Mushaf Metadata Bar (animated) ───────────────
                    if (_controlsVisible)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _AnimatedMushafBar(
                          visible: _controlsVisible,
                          child: _MushafMetadataBar(
                            pageNumber: state.currentPageNumber,
                            alignment: _MushafBarAlignment.bottom,
                          ),
                        ),
                      ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

/// Animated wrapper for the Mushaf metadata bars.
class _AnimatedMushafBar extends StatelessWidget {
  const _AnimatedMushafBar({
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
    );
  }
}

/// Alignment of the Mushaf metadata bar.
enum _MushafBarAlignment { top, bottom }

/// A clean, elegant bar displaying authentic Mushaf metadata for the
/// current page: Surah name, Juz number, and Hizb/Quarter info.
class _MushafMetadataBar extends StatelessWidget {
  const _MushafMetadataBar({
    required this.pageNumber,
    required this.alignment,
  });

  final int pageNumber;
  final _MushafBarAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;
    final goldColor = isDark ? AppColors.goldLight : AppColors.gold;

    // Resolve authentic metadata for the current page.
    // Only Juz and Hizb are shown — the quarter overlay was removed
    // because it divided the Hizb span into equal parts, which does NOT
    // match the authentic Medina Mushaf quarter markers.
    final surah = surahForMushafPage(pageNumber);
    final juz = juzForPage(pageNumber);
    final hizb = hizbForPage(pageNumber);

    final isTop = alignment == _MushafBarAlignment.top;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        border: Border(
          bottom: isTop
              ? BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)
              : BorderSide.none,
          top: isTop
              ? BorderSide.none
              : BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ─── Surah Name ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'سورة ${surah.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'صفحة ${_toArabicDigits(pageNumber)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Juz ──────────────────────────────────────────────────────────
            _MetadataChip(
              icon: Icons.auto_stories_outlined,
              label: 'الجزء ${_toArabicDigits(juz)}',
              color: goldColor,
            ),

            const SizedBox(width: 8),

            // ─── Hizb ─────────────────────────────────────────────────────────
            _MetadataChip(
              icon: Icons.bookmark_border,
              label: 'حزب ${_toArabicDigits(hizb)}',
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  /// Converts Western digits to Arabic-Indic digits for display.
  static String _toArabicDigits(int value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return value.toString().split('').map((c) {
      final d = int.parse(c);
      return arabic[d];
    }).join();
  }
}

/// A compact metadata chip used in the Mushaf bar.
class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// The horizontal PageView of Quran pages with a smooth page-turn effect.
class _QuranPageView extends StatelessWidget {
  const _QuranPageView({
    required this.pageController,
    required this.loaded,
    required this.onPageChanged,
    this.useDarkParchment = false,
  });

  final PageController pageController;
  final QuranLoaded loaded;
  final ValueChanged<int> onPageChanged;

  /// Whether the Mushaf page should use the dark parchment palette
  /// (with a white tint overlay so the script stays visible).
  final bool useDarkParchment;

  @override
  Widget build(BuildContext context) {
    // Light parchment palette (default).
    final backgrounds = AppColors.quranPageBackgrounds;

    // Dark parchment palette designed for night reading.
    final darkBackgrounds = AppColors.quranPageBackgroundsDark;

    // Use the saved page background preference (fall back to index 0).
    final bgIndex = (LocalStorageService.instance
                .getInt(AppConstants.quranPageBackgroundPrefKey,
                    defaultValue: 0) ??
            0)
        .clamp(0, backgrounds.length - 1);

    // Choose the correct palette based on the user's Mushaf preference.
    final backgroundColor = useDarkParchment
        ? darkBackgrounds[bgIndex]
        : backgrounds[bgIndex];

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.horizontal,
      // Smooth page-turn physics with a natural flip feel.
      physics: const PageScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      onPageChanged: onPageChanged,
      itemCount: loaded.totalPages,
      // Optimize with a viewport pre-cache for smooth swiping.
      allowImplicitScrolling: true,
      itemBuilder: (context, index) {
        // Mushaf page number = index + 1 (1–604).
        final pageNumber = index + 1;

        // Render the official Medina Mushaf page image with the chosen
        // background. When the dark parchment is active, a white overlay
        // tint keeps the Uthmani script visible.
        return MushafPageImage(
          pageNumber: pageNumber,
          backgroundColor: backgroundColor,
          useDarkParchment: useDarkParchment,
        );
      },
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
    final strings = AppStrings.of(context);

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
            strings.quranLoading,
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