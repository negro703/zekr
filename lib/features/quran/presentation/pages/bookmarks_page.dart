import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/quran_surahs_metadata.dart';
import '../../domain/entities/bookmark_entity.dart';
import '../bloc/bookmarks_cubit.dart';
import '../bloc/bookmarks_state.dart';
import '../bloc/quran_cubit.dart';

/// Full-screen page listing all saved Quran bookmarks.
///
/// Tapping a bookmark jumps the reader to that page and closes the page.
/// Each bookmark can be removed with the delete icon.
class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العلامات المرجعية'),
        centerTitle: true,
      ),
      body: BlocBuilder<BookmarksCubit, BookmarksState>(
        buildWhen: (prev, cur) =>
            cur is BookmarksLoading ||
            cur is BookmarksLoaded ||
            cur is BookmarksError,
        builder: (context, state) {
          switch (state) {
            case BookmarksInitial():
            case BookmarksLoading():
              return const _BookmarksLoading();
            case BookmarksError(:final message):
              return _BookmarksError(
                message: message,
                onRetry: context.read<BookmarksCubit>().loadBookmarks,
              );
            case BookmarksLoaded(:final bookmarks):
              if (bookmarks.isEmpty) {
                return const _EmptyBookmarks();
              }
              return _BookmarksList(bookmarks: bookmarks);
          }
        },
      ),
    );
  }
}

/// List of bookmark tiles.
class _BookmarksList extends StatelessWidget {
  const _BookmarksList({required this.bookmarks});

  final List<BookmarkEntity> bookmarks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        final pageNumber = bookmark.pageNumber;
        final surah = surahForMushafPage(pageNumber);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () {
              context.read<QuranCubit>().changePage(pageNumber);
              Navigator.of(context).pop();
            },
            leading: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.12),
              ),
              child: Text(
                _toArabicDigits(pageNumber),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              'صفحة ${_toArabicDigits(pageNumber)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              'سورة ${surah.name}',
              style: theme.textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              tooltip: 'حذف العلامة',
              onPressed: () =>
                  context.read<BookmarksCubit>().removeBookmark(pageNumber),
            ),
          ),
        );
      },
    );
  }
}

/// Loading view.
class _BookmarksLoading extends StatelessWidget {
  const _BookmarksLoading();

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
          Text('جاري تحميل العلامات...',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// Error view.
class _BookmarksError extends StatelessWidget {
  const _BookmarksError({required this.message, required this.onRetry});

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

/// Empty state when no bookmarks exist.
class _EmptyBookmarks extends StatelessWidget {
  const _EmptyBookmarks();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border,
              size: 72, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'لا توجد علامات مرجعية بعد',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "حفظ علامة" من قائمة المصحف لإضافة صفحة هنا',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('العودة للمصحف'),
            style: FilledButton.styleFrom(backgroundColor: primaryColor),
          ),
        ],
      ),
    );
  }
}

String _toArabicDigits(int value) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  return value.toString().split('').map((c) {
    final d = int.parse(c);
    return arabic[d];
  }).join();
}