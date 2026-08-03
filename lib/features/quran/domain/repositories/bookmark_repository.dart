import '../entities/bookmark_entity.dart';

/// A repository for managing Quran bookmarks backed by [KeyValueStorage].
abstract class BookmarkRepository {
  /// Returns all saved bookmarks, sorted newest-first.
  Future<List<BookmarkEntity>> getBookmarks();

  /// Adds a bookmark for [pageNumber]. Replaces any existing bookmark
  /// for the same page.
  Future<void> addBookmark(int pageNumber, {String? label});

  /// Removes the bookmark for [pageNumber]. No-op if absent.
  Future<void> removeBookmark(int pageNumber);

  /// Returns whether a bookmark exists for [pageNumber].
  Future<bool> hasBookmark(int pageNumber);
}