import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/azkar_cubit.dart';
import '../bloc/azkar_state.dart';

/// Displays the list of Azkar for a selected category.
///
/// Each Zekr card has its own tap counter. Tapping the card increments
/// the counter with haptic feedback, and visual feedback (gold ring +
/// checkmark) appears when the target count is reached.
class AzkarDetailsPage extends StatefulWidget {
  const AzkarDetailsPage({super.key, required this.category});

  final AzkarCategoryEntity category;

  @override
  State<AzkarDetailsPage> createState() => _AzkarDetailsPageState();
}

class _AzkarDetailsPageState extends State<AzkarDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AzkarCubit>().loadAzkar(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.title), centerTitle: true),
      body: BlocBuilder<AzkarCubit, AzkarState>(
        buildWhen: (prev, cur) =>
            (cur is AzkarLoaded && cur.categoryId == widget.category.id) ||
            cur is AzkarLoading ||
            cur is AzkarError,
        builder: (context, state) {
          switch (state) {
            case AzkarLoading():
              return const _AzkarListLoading();
            case AzkarError(:final message):
              return _AzkarListError(
                message: message,
                onRetry: () =>
                    context.read<AzkarCubit>().loadAzkar(widget.category.id),
              );
            case AzkarLoaded(:final azkar, :final progress):
              if (azkar.isEmpty) {
                return const Center(child: Text('لا توجد أذكار في هذه الفئة.'));
              }
              return _AzkarList(azkar: azkar, progress: progress);
            default:
              // Never trigger side effects during build; just render the
              // loading placeholder — the cubit was already kicked off in
              // initState and will emit a new state asynchronously.
              return const _AzkarListLoading();
          }
        },
      ),
    );
  }
}

/// Scrollable list of Zekr cards.
class _AzkarList extends StatelessWidget {
  const _AzkarList({required this.azkar, required this.progress});

  final List<ZekrEntity> azkar;
  final Map<String, int> progress;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AzkarCubit>();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: azkar.length,
      itemBuilder: (context, index) {
        final zekr = azkar[index];
        return _ZekrCard(
          zekr: zekr,
          currentCount: progress[zekr.id] ?? 0,
          onTap: () => cubit.tapZekr(zekr.id),
          onLongPress: () => cubit.resetZekr(zekr.id),
        );
      },
    );
  }
}

/// A single Zekr card with tap counter and completion feedback.
class _ZekrCard extends StatelessWidget {
  const _ZekrCard({
    required this.zekr,
    required this.currentCount,
    required this.onTap,
    required this.onLongPress,
  });

  final ZekrEntity zekr;
  final int currentCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  bool get _isComplete => currentCount >= zekr.count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;
    final goldColor = isDark ? AppColors.goldLight : AppColors.gold;
    final accentColor = _isComplete ? goldColor : primaryColor;

    return Opacity(
      opacity: _isComplete ? 0.95 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'العدد: ${_toArabicDigits(zekr.count)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isComplete
                          ? Icon(
                              Icons.check_circle,
                              color: goldColor,
                              size: 24,
                              key: const ValueKey('complete'),
                            )
                          : Icon(
                              Icons.touch_app_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 24,
                              key: const ValueKey('incomplete'),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  zekr.text,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    height: 1.8,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (zekr.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    zekr.description!,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: zekr.count > 0
                              ? (currentCount / zekr.count).clamp(0.0, 1.0)
                              : 0,
                          minHeight: 6,
                          color: accentColor,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_toArabicDigits(currentCount)} / ${_toArabicDigits(zekr.count)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

/// Loading view.
class _AzkarListLoading extends StatelessWidget {
  const _AzkarListLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.emeraldLight : AppColors.emerald;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: accent),
          const SizedBox(height: 16),
          Text('جاري تحميل الأذكار...',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// Error view.
class _AzkarListError extends StatelessWidget {
  const _AzkarListError({required this.message, required this.onRetry});

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
            Text(message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge),
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