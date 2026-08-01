import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/services.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/quran_cubit.dart';
import '../bloc/quran_state.dart';

/// Advanced Drawer for the Quran Reader.
///
/// Contains:
/// - Header with app title and quick bookmark actions
/// - Reading tools: سطوع الشاشة, تغيير خلفية الصفحة, حجم الخط
/// - Navigation items: الفهرس, الأجزاء, الصفحات (placeholders in Phase 2.5)
/// - Bookmarking: حفظ علامة, الذهاب إلى العلامة, التحكم بالعلامات
/// - Dua of completion and other spiritual tools
class QuranDrawer extends StatelessWidget {
  const QuranDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;
    final secondaryColor = isDark ? AppColors.goldLight : AppColors.gold;

    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        final cubit = context.read<QuranCubit>();
        final loaded = state is QuranLoaded ? state : null;
        final currentPage = loaded?.currentPageNumber;
        final hasBookmark = loaded?.bookmarkPageNumber != null;

        return Drawer(
          width: 320,
          backgroundColor: theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(24),
              right: Radius.zero,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ─── Drawer Header ──────────────────────────────────────────────
                _DrawerHeader(
                  isDark: isDark,
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),

                // ─── Quick Bookmark Actions ─────────────────────────────────────
                if (currentPage != null)
                  _QuickActionsRow(
                    cubit: cubit,
                    currentPage: currentPage,
                    hasBookmark: hasBookmark,
                    primaryColor: primaryColor,
                  ),

                // ─── Scrollable Drawer Body ─────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      // ─── Reading Tools Section ────────────────────────────────
                      _SectionTitle(
                        title: 'أدوات القراءة',
                        secondaryColor: secondaryColor,
                      ),
                      _QuranDrawerTile(
                        icon: Icons.auto_stories_outlined,
                        title: 'فضل قراءة القرآن',
                        onTap: () => _showVirtueSheet(context),
                      ),
                      _QuranDrawerTile(
                        icon: Icons.translate,
                        title: 'معاني الكلمات',
                        onTap: () => _showComingSoon(context, 'معاني الكلمات'),
                      ),
                      _QuranDrawerTile(
                        icon: Icons.menu_book_outlined,
                        title: 'التفسير الميسر',
                        onTap: () => _showComingSoon(context, 'التفسير الميسر'),
                      ),

                      // ─── Navigation Section ───────────────────────────────────
                      _SectionTitle(
                        title: 'التنقل',
                        secondaryColor: secondaryColor,
                      ),
                      _QuranDrawerTile(
                        icon: Icons.list_alt_outlined,
                        title: 'الفهرس',
                        onTap: () => _showComingSoon(context, 'الفهرس'),
                      ),
                      _QuranDrawerTile(
                        icon: Icons.grid_view_outlined,
                        title: 'الأجزاء',
                        onTap: () => _showComingSoon(context, 'الأجزاء'),
                      ),
                      _QuranDrawerTile(
                        icon: Icons.pages_outlined,
                        title: 'الصفحات',
                        onTap: () => _showPagesSheet(context),
                      ),

                      // ─── Bookmarks Section ────────────────────────────────────
                      _SectionTitle(
                        title: 'العلامات المرجعية',
                        secondaryColor: secondaryColor,
                      ),
                      _QuranDrawerTile(
                        icon: Icons.bookmark_add_outlined,
                        title: 'حفظ علامة في هذه الصفحة',
                        onTap: () {
                          if (currentPage != null) {
                            cubit.setBookmark(currentPage);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم حفظ العلامة في صفحة $_currentPageLabel(currentPage)',
                                  ),
                                ),
                              );
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      _QuranDrawerTile(
                        icon: Icons.bookmark_outlined,
                        title: 'الذهاب إلى العلامة',
                        enabled: hasBookmark,
                        subtitle: hasBookmark
                            ? 'صفحة ${_toArabicDigits(loaded!.bookmarkPageNumber!)}'
                            : null,
                        onTap: () {
                          cubit.jumpToBookmark();
                          Navigator.of(context).pop();
                        },
                      ),
                      _QuranDrawerTile(
                        icon: Icons.bookmarks_outlined,
                        title: 'التحكم بالعلامات',
                        onTap: () => _showComingSoon(context, 'التحكم بالعلامات'),
                      ),

                      // ─── Extra Tools Section ──────────────────────────────────
                      _SectionTitle(
                        title: 'أدوات إضافية',
                        secondaryColor: secondaryColor,
                      ),
                      _QuranDrawerTile(
                        icon: Icons.volunteer_activism_outlined,
                        title: 'دعاء الختم',
                        onTap: () => _showDuaSheet(context),
                      ),
                      _QuranDrawerTile(
                        icon: Icons.brightness_6_outlined,
                        title: 'سطوع الشاشة',
                        onTap: () => _showBrightnessSheet(context),
                      ),
                      _QuranDrawerTile(
                        icon: Icons.palette_outlined,
                        title: 'تغيير خلفية الصفحة',
                        onTap: () => _showBackgroundSheet(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Sheet Helpers ─────────────────────────────────────────────────────────

  void _showComingSoon(BuildContext context, String feature) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('قريباً: $feature')),
      );
  }

  void _showVirtueSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: const SizedBox(
            height: 400,
            child: _VirtueContent(),
          ),
        );
      },
    );
  }

  void _showDuaSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return const SizedBox(
          height: 380,
          child: _DuaCompletionContent(),
        );
      },
    );
  }

  void _showPagesSheet(BuildContext context) {
    final cubit = context.read<QuranCubit>();
    final state = cubit.state;

    if (state is! QuranLoaded) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'انتقال إلى صفحة',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: state.totalPages,
                    itemBuilder: (ctx, index) {
                      final pageNumber = index + 1;
                      final isCurrent = pageNumber == state.currentPageNumber;
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          cubit.changePage(pageNumber);
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? primaryColor
                                : primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _toArabicDigits(pageNumber),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isCurrent ? Colors.white : primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBrightnessSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return const _BrightnessControl();
      },
    );
  }

  void _showBackgroundSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final backgrounds = isDark
            ? AppColors.quranPageBackgroundsDark
            : AppColors.quranPageBackgrounds;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'تغيير خلفية الصفحة',
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // Color swatches
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: backgrounds.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (ctx, index) {
                      final color = backgrounds[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Store the selected background index locally.
                          LocalStorageService.instance.setInt(
                            AppConstants.quranPageBackgroundPrefKey,
                            index,
                          );
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          width: 56,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(ctx).colorScheme.outline,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر لوناً مريحاً للقراءة الليلية',
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
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

  static String _currentPageLabel(int page) => _toArabicDigits(page);
}

// ─── Private Sub-Widgets ──────────────────────────────────────────────────────

/// Drawer header with app branding.
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            primaryColor.withValues(alpha: 0.15),
            secondaryColor.withValues(alpha: 0.08),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: secondaryColor, width: 2),
              color: secondaryColor.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.auto_awesome, color: secondaryColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المصحف الشريف',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'قراءة بنص عثماني',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick actions row for bookmarking.
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.cubit,
    required this.currentPage,
    required this.hasBookmark,
    required this.primaryColor,
  });

  final QuranCubit cubit;
  final int currentPage;
  final bool hasBookmark;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: primaryColor.withValues(alpha: 0.06),
      child: Row(
        children: [
          Expanded(
            child: _QuickAction(
              icon: Icons.bookmark_add_outlined,
              label: 'حفظ علامة',
              color: primaryColor,
              onTap: () {
                cubit.setBookmark(currentPage);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text('تم حفظ العلامة في صفحة ${QuranDrawer._toArabicDigits(currentPage)}')),
                  );
                Navigator.of(context).pop();
              },
            ),
          ),
          Expanded(
            child: _QuickAction(
              icon: Icons.bookmark_outlined,
              label: hasBookmark ? 'اذهب للعلامة' : 'لا توجد علامة',
              color: hasBookmark ? theme.colorScheme.primary : theme.disabledColor,
              onTap: hasBookmark ? () {
                cubit.jumpToBookmark();
                Navigator.of(context).pop();
              } : null,
            ),
          ),
          Expanded(
            child: _QuickAction(
              icon: Icons.more_horiz_outlined,
              label: 'أخرى',
              color: theme.colorScheme.onSurfaceVariant,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section title widget.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.secondaryColor,
  });

  final String title;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: secondaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard drawer list tile.
class _QuranDrawerTile extends StatelessWidget {
  const _QuranDrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;

    return ListTile(
      enabled: enabled,
      leading: Icon(
        icon,
        color: enabled ? primaryColor : theme.disabledColor,
        size: 22,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: enabled
              ? theme.colorScheme.onSurface
              : theme.disabledColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.bodySmall)
          : null,
      trailing: Icon(
        Icons.chevron_left,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      onTap: enabled ? onTap : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      dense: true,
    );
  }
}

/// Brightness control sheet.
class _BrightnessControl extends StatefulWidget {
  const _BrightnessControl();

  @override
  State<_BrightnessControl> createState() => _BrightnessControlState();
}

class _BrightnessControlState extends State<_BrightnessControl> {
  late double _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = BrightnessService.current;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'سطوع الشاشة',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'اضبط الإضاءة للقراءة المريحة',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.brightness_low, color: theme.colorScheme.onSurfaceVariant),
                Expanded(
                  child: Slider(
                    value: _brightness,
                    onChanged: (value) {
                      setState(() => _brightness = value);
                      BrightnessService.setBrightness(value);
                    },
                    activeColor: primaryColor,
                  ),
                ),
                Icon(Icons.brightness_high, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                BrightnessService.resetBrightness();
                setState(() => _brightness = BrightnessService.current);
              },
              icon: const Icon(Icons.settings_backup_restore),
              label: const Text('استعادة السطوع الافتراضي'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Content for the virtue of reading Quran sheet.
class _VirtueContent extends StatelessWidget {
  const _VirtueContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'فضل قراءة القرآن الكريم',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'قال رسول الله ﷺ:\n\n'
            '"اقْرَءُوا الْقُرْآنَ فَإِنَّهُ يَأْتِي يَوْمَ الْقِيَامَةِ شَفِيعًا لأَصْحَابِهِ" '
            '(رواه مسلم)\n\n'
            'وقال ﷺ:\n\n'
            '"الْمَاهِرُ بِالْقُرْآنِ مَعَ السَّفَرَةِ الْكِرَامِ الْبَرَرَةِ، '
            'وَالَّذِي يَقْرَأُ الْقُرْآنَ وَيَتَتَعْتَعُ فِيهِ وَهُوَ عَلَيْهِ '
            'شَاقٌّ، لَهُ أَجْرَانِ" (متفق عليه)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Content for the dua of completing the Quran sheet.
class _DuaCompletionContent extends StatelessWidget {
  const _DuaCompletionContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'دعاء ختم القرآن الكريم',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'اللهم ارحمني بالقرآن، واجعله لي إماماً ونوراً وهدى ورحمة، '
            'اللهم ذكرني منه ما نسيت، وعلمني منه ما جهلت، وارزقني تلاوته '
            'آناء الليل وأطراف النهار، واجعله لي حجة يا رب العالمين. '
            'اللهم أصلح لي ديني الذي هو عصمة أمري، وأصلح لي دنياي التي '
            'فيها معاشي، وأصلح لي آخرتي التي فيها معادي، واجعل الحياة '
            'زيادة لي في كل خير، واجعل الموت راحة لي من كل شر.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.9,
            ),
          ),
        ],
      ),
    );
  }
}