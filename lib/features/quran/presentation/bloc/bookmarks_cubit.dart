import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/bookmark_repository.dart';
import 'bookmarks_state.dart';

/// Cubit managing the Quran bookmarks list.
///
/// Responsibilities:
/// - Load the saved bookmarks from [BookmarkRepository]
/// - Add / remove bookmarks with optimistic UI updates
/// - Expose helper `isBookmarked(page)` for the reader UI
class BookmarksCubit extends Cubit<BookmarksState> {
  BookmarksCubit({required this.repository}) : super(const BookmarksInitial());

  /// The repository backing bookmark persistence.
  final BookmarkRepository repository;

  /// Loads all saved bookmarks from storage.
  Future<void> loadBookmarks() async {
    emit(const BookmarksLoading());

    try {
      final bookmarks = await repository.getBookmarks();
      emit(BookmarksLoaded(bookmarks: bookmarks));
    } catch (_) {
      emit(const BookmarksError(message: 'تعذر تحميل العلامات المرجعية.'));
    }
  }

  /// Adds a bookmark for [pageNumber], then reloads the list.
  Future<void> addBookmark(int pageNumber, {String? label}) async {
    if (state is! BookmarksLoaded) return;

    await repository.addBookmark(pageNumber, label: label);
    await loadBookmarks();
  }

  /// Removes the bookmark for [pageNumber], then reloads the list.
  Future<void> removeBookmark(int pageNumber) async {
    if (state is! BookmarksLoaded) return;

    await repository.removeBookmark(pageNumber);
    await loadBookmarks();
  }

  /// Toggles a bookmark: removes it if present, otherwise adds it.
  Future<void> toggleBookmark(int pageNumber, {String? label}) async {
    if (state is! BookmarksLoaded) return;

    final loaded = state as BookmarksLoaded;
    if (loaded.hasBookmark(pageNumber)) {
      await removeBookmark(pageNumber);
    } else {
      await addBookmark(pageNumber, label: label);
    }
  }

  /// Returns whether [pageNumber] is currently bookmarked.
  bool isBookmarked(int pageNumber) {
    final state = this.state;
    return state is BookmarksLoaded && state.hasBookmark(pageNumber);
  }
}