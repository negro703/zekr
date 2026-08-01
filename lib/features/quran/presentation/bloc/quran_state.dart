import 'package:equatable/equatable.dart';

import '../../domain/entities/entities.dart';

/// Base state for the Quran reader.
sealed class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any loading begins.
final class QuranInitial extends QuranState {
  const QuranInitial();
}

/// State while Quran pages are being loaded.
final class QuranLoading extends QuranState {
  const QuranLoading();
}

/// State when Quran pages have been successfully loaded.
final class QuranLoaded extends QuranState {
  const QuranLoaded({
    required this.currentPageNumber,
    required this.totalPages,
    this.pages = const [],
    this.bookmarkPageNumber,
  });

  /// The currently active Mushaf page number (1–604).
  final int currentPageNumber;

  /// The total number of pages in the Mushaf (604).
  final int totalPages;

  /// All loaded pages (may be a subset when using lazy loading).
  final List<QuranPageEntity> pages;

  /// The page number saved as a bookmark, if any.
  final int? bookmarkPageNumber;

  /// Returns the [QuranPageEntity] for [pageNumber], or `null` if not loaded.
  QuranPageEntity? pageByNumber(int pageNumber) {
    if (pages.isEmpty) return null;
    // Binary search on sorted pages.
    int low = 0;
    int high = pages.length - 1;
    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final page = pages[mid];
      if (page.pageNumber == pageNumber) return page;
      if (page.pageNumber < pageNumber) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return null;
  }

  /// Creates a copy of this state with a new current page number.
  QuranLoaded copyWithPage(int newPageNumber) {
    return QuranLoaded(
      currentPageNumber: newPageNumber,
      totalPages: totalPages,
      pages: pages,
      bookmarkPageNumber: bookmarkPageNumber,
    );
  }

  /// Creates a copy of this state with a new bookmark page number.
  /// Pass `null` to clear the bookmark.
  QuranLoaded copyWithBookmark(int? newBookmark) {
    return QuranLoaded(
      currentPageNumber: currentPageNumber,
      totalPages: totalPages,
      pages: pages,
      bookmarkPageNumber: newBookmark,
    );
  }

  @override
  List<Object?> get props => [
        currentPageNumber,
        totalPages,
        pages,
        bookmarkPageNumber,
      ];
}

/// State when an error occurred while loading Quran data.
final class QuranError extends QuranState {
  const QuranError({required this.message, this.code});

  /// A user-friendly error message.
  final String message;

  /// An optional machine-readable error code.
  final String? code;

  @override
  List<Object?> get props => [message, code];
}