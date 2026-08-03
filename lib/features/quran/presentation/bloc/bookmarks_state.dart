import 'package:equatable/equatable.dart';

import '../../domain/entities/bookmark_entity.dart';

/// Base state for the bookmarks feature.
sealed class BookmarksState extends Equatable {
  const BookmarksState();

  @override
  List<Object?> get props => [];
}

/// Initial state before bookmarks are loaded.
final class BookmarksInitial extends BookmarksState {
  const BookmarksInitial();
}

/// State while bookmarks are being loaded.
final class BookmarksLoading extends BookmarksState {
  const BookmarksLoading();
}

/// State when bookmarks have been successfully loaded.
final class BookmarksLoaded extends BookmarksState {
  const BookmarksLoaded({required this.bookmarks});

  /// All saved bookmarks, newest-first.
  final List<BookmarkEntity> bookmarks;

  /// Whether a bookmark exists for [pageNumber].
  bool hasBookmark(int pageNumber) =>
      bookmarks.any((b) => b.pageNumber == pageNumber);

  @override
  List<Object?> get props => [bookmarks];
}

/// State when an error occurred.
final class BookmarksError extends BookmarksState {
  const BookmarksError({required this.message});

  /// User-friendly error message.
  final String message;

  @override
  List<Object?> get props => [message];
}