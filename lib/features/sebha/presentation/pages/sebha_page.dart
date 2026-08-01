import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme.dart';
import '../bloc/sebha_cubit.dart';
import '../bloc/sebha_state.dart';

/// Interactive Electronic Sebha page.
///
/// Features:
/// - Large central tap-to-count circle with scale animations
/// - Haptic feedback on every tap (handled by [SebhaCubit])
/// - Dhikr phrase selector dropdown
/// - Round counter and total rounds display
/// - Full RTL layout matching the Islamic Material 3 theme
class SebhaPage extends StatelessWidget {
  const SebhaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السُّبْحَة'),
        centerTitle: true,
      ),
      body: BlocBuilder<SebhaCubit, SebhaState>(
        buildWhen: (previous, current) =>
            previous is SebhaLoading ||
            current is SebhaLoading ||
            current is SebhaError ||
            (current is SebhaLoaded &&
                (previous is! SebhaLoaded || previous.sebha != current.sebha)),
        builder: (context, state) {
          switch (state) {
            case SebhaInitial():
            case SebhaLoading():
              return const _SebhaLoadingView();

            case SebhaError(:final message):
              return _SebhaErrorView(
                message: message,
                onRetry: context.read<SebhaCubit>().loadSebha,
              );

            case SebhaLoaded(:final sebha):
              final cubit = context.read<SebhaCubit>();
              return _SebhaContentView(
                cubit: cubit,
                count: sebha.currentCount,
                totalRounds: sebha.totalRounds,
                dhikrText: sebha.currentDhikrText,
                dhikrIndex: sebha.currentDhikrIndex,
              );
          }
        },
      ),
    );
  }
}

/// Main interactive content when the Sebha is loaded.
class _SebhaContentView extends StatelessWidget {
  const _SebhaContentView({
    required this.cubit,
    required this.count,
    required this.totalRounds,
    required this.dhikrText,
    required this.dhikrIndex,
  });

  final SebhaCubit cubit;
  final int count;
  final int totalRounds;
  final String dhikrText;
  final int dhikrIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;
    final secondaryColor = isDark ? AppColors.goldLight : AppColors.gold;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ─── Dhikr Selector ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: dhikrIndex,
                  isDense: true,
                  isExpanded: false,
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: theme.colorScheme.surface,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: secondaryColor,
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedItemBuilder: (context) {
                    return List.generate(
                      SebhaCubit.dhikrs.length,
                      (i) => Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          SebhaCubit.dhikrs[i],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                  items: List.generate(
                    SebhaCubit.dhikrs.length,
                    (i) => DropdownMenuItem<int>(
                      value: i,
                      child: Text(
                        SebhaCubit.dhikrs[i],
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) cubit.changeDhikr(value);
                  },
                ),
              ),
            ),

            const Spacer(),

            // ─── Large Counter Circle ───────────────────────────────────────────
            _CounterCircle(
              key: ValueKey(count), // Re-trigger animation on count change.
              count: count,
              target: SebhaCubit.target,
              dhikrText: dhikrText,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              onTap: cubit.incrementCount,
            ),

            const Spacer(),

            // ─── Round Info ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoPill(
                  icon: Icons.loop,
                  label: 'الجولة',
                  value: _toArabicDigits(totalRounds),
                  color: secondaryColor,
                ),
                const SizedBox(width: 12),
                _InfoPill(
                  icon: Icons.track_changes,
                  label: 'الهدف',
                  value: _toArabicDigits(SebhaCubit.target),
                  color: primaryColor,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ─── Reset Button ───────────────────────────────────────────────────
            TextButton.icon(
              onPressed: cubit.resetCounter,
              icon: const Icon(Icons.restart_alt),
              label: const Text('تصفير العدّاد'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
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

/// The large tap-to-count circle with scale animation.
class _CounterCircle extends StatefulWidget {
  const _CounterCircle({
    super.key,
    required this.count,
    required this.target,
    required this.dhikrText,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  final int count;
  final int target;
  final String dhikrText;
  final Color primaryColor;
  final Color secondaryColor;
  final Future<void> Function() onTap;

  @override
  State<_CounterCircle> createState() => _CounterCircleState();
}

class _CounterCircleState extends State<_CounterCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.92).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 50,
      ),
    ]).animate(_scaleController);
  }

  @override
  void didUpdateWidget(covariant _CounterCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Play the tap animation when the count changes.
    if (oldWidget.count != widget.count) {
      _scaleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isComplete = widget.count == widget.target;

    // Determine ring color based on completion.
    final ringColor = isComplete ? AppColors.gold : widget.primaryColor;

    // Circular progress: what fraction of the round is completed.
    final progress = widget.target > 0 ? widget.count / widget.target : 0.0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(0, -0.4),
              colors: [
                ringColor.withValues(alpha: 0.28),
                ringColor.withValues(alpha: 0.10),
              ],
            ),
            border: Border.all(
              color: ringColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: ringColor.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress ring.
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  color: ringColor,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),

              // ─── Center Content (Dhikr + Count) ─────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dhikr text.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      widget.dhikrText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Count.
                  Text(
                    _toArabicDigits(widget.count),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 76,
                      fontWeight: FontWeight.w900,
                      color: ringColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // "TAP" hint.
                  Text(
                    'اضغط للتسبيح',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

/// Round info pill (e.g., الجولة / الهدف).
class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.goldLight : AppColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading view for the Sebha.
class _SebhaLoadingView extends StatelessWidget {
  const _SebhaLoadingView();

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
            'جاري تحميل السبحة...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// Error view for the Sebha.
class _SebhaErrorView extends StatelessWidget {
  const _SebhaErrorView({
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
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
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
              style: FilledButton.styleFrom(backgroundColor: accent),
            ),
          ],
        ),
      ),
    );
  }
}

