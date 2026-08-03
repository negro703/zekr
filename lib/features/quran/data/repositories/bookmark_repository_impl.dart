import 'dart:convert';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/local_storage/key_value_storage.dart';
import '../../domain/entities/bookmark_entity.dart';
import '../../domain/repositories/bookmark_repository.dart';

/// Implementation of [BookmarkRepository] backed by [KeyValueStorage].
///
/// Bookmarks are stored as a JSON-encoded list under a single storage key
/// (`quran_bookmarks`), keyed by page number. This approach keeps the
/// storage footprint minimal while supporting an arbitrary number of
/// bookmarks.
class BookmarkRepositoryImpl implements BookmarkRepository {
  BookmarkRepositoryImpl({required this.keyValueStorage});

  /// The storage key holding the JSON-encoded bookmarks list.
  static const String _storageKey = AppConstants.bookmarksBox;

  /// The key-value storage abstraction.
  final KeyValueStorage keyValueStorage;

  @override
  Future<List<BookmarkEntity>> getBookmarks() async {
    final raw = keyValueStorage.getString(_storageKey);
    if (raw == null) return const [];

    try {
      final decoded = json.decode(raw);
      if (decoded is! List) return const [];

      final bookmarks = decoded
          .whereType<Map<String, dynamic>>()
          .map(BookmarkEntity.fromJson)
          .toList();
      // Sort newest-first.
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookmarks;
    } on FormatException {
      return const [];
    }
  }

  @override
  Future<void> addBookmark(int pageNumber, {String? label}) async {
    final bookmarks = await getBookmarks();

    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = <BookmarkEntity>[
      BookmarkEntity(pageNumber: pageNumber, createdAt: now, label: label),
      ...bookmarks.where((b) => b.pageNumber != pageNumber),
    ];

    await _save(updated);
  }

  @override
  Future<void> removeBookmark(int pageNumber) async {
    final bookmarks = await getBookmarks();
    final updated = bookmarks.where((b) => b.pageNumber != pageNumber).toList();
    await _save(updated);
  }

  @override
  Future<bool> hasBookmark(int pageNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b.pageNumber == pageNumber);
  }

  /// Persists the [bookmarks] list as JSON.
  Future<void> _save(List<BookmarkEntity> bookmarks) async {
    await keyValueStorage.setString(
      _storageKey,
      json.encode(bookmarks.map((b) => b.toJson()).toList()),
    );
  }
}