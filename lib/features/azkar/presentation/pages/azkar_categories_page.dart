import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/azkar_cubit.dart';
import '../bloc/azkar_state.dart';
import 'azkar_details_page.dart';

/// Displays all Azkar categories in an attractive grid.
///
/// Material 3 Islamic styling with emerald/gold/ivory tones and
/// full RTL layout.
///
/// Loads categories automatically on first mount so the UI transitions
/// from [AzkarInitial] → [AzkarCategoriesLoading] → [AzkarCategoriesLoaded]
/// instead of hanging on the loading indicator forever.
class AzkarCategoriesPage extends StatefulWidget {
  const AzkarCategoriesPage({super.key});

  @override
  State<AzkarCategoriesPage> createState() => _AzkarCategoriesPageState();
}

class _AzkarCategoriesPageState extends State<AzkarCategoriesPage> {
  @override
  void initState() {
    super.initState();
    // Kick off the category load on the first frame so the cubit
    // transitions out of AzkarInitial and resolves the loading spinner.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AzkarCubit>();
      if (cubit.state is AzkarInitial) {
        cubit.loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        centerTitle: true,
      ),
      body: BlocBuilder<AzkarCubit, AzkarState>(
        buildWhen: (previous, current) =>
            current is AzkarCategoriesLoading ||
            current is AzkarCategoriesLoaded ||
            current is AzkarError,
        builder: (context, state) {
          switch (state) {
            case AzkarInitial():
            case AzkarCategoriesLoading():
              return const _CategoriesLoading();

            case AzkarCategoriesLoaded(:final categories):
              return _CategoriesGrid(categories: categories);

            case AzkarError(:final message):
              return _CategoriesError(
                message: message,
                onRetry: context.read<AzkarCubit>().loadCategories,
              );

            default:
              // Other states (azkar loading/loaded) shouldn't appear here,
              // but fall back to loading categories if needed.
              context.read<AzkarCubit>().loadCategories();
              return const _CategoriesLoading();
          }
        },
      ),
    );
  }
}

/// Grid of category cards.
class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({required this.categories});

  final List<AzkarCategoryEntity> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(category: category);
      },
    );
  }
}

/// A single category card with icon, title, and gradient styling.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final AzkarCategoryEntity category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;
    final title = category.title;
    final iconName = category.icon;
    final description = category.description;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Navigate to the azkar list for this category.
          // The AzkarCubit provided by HomePage's BlocProvider is
          // inherited by this new route automatically.
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AzkarDetailsPage(category: category),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                primaryColor.withValues(alpha: 0.18),
                primaryColor.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _iconColor(iconName).withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    _mapIcon(iconName),
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _iconColor(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return AppColors.gold;
      case 'nights_stay':
        return AppColors.info;
      case 'bedtime':
        return AppColors.emerald;
      case 'mosque':
        return AppColors.success;
      default:
        return AppColors.emerald;
    }
  }

  IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny_outlined;
      case 'nights_stay':
        return Icons.nights_stay_outlined;
      case 'bedtime':
        return Icons.bedtime_outlined;
      case 'mosque':
        return Icons.mosque_outlined;
      default:
        return Icons.auto_awesome;
    }
  }
}

/// Loading view for categories.
class _CategoriesLoading extends StatelessWidget {
  const _CategoriesLoading();

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
            'جاري تحميل الأذكار...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// Error view for categories.
class _CategoriesError extends StatelessWidget {
  const _CategoriesError({
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
