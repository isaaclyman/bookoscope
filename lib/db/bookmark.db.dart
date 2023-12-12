import 'package:bookoscope/db/db.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'bookmark.db.g.dart';

@collection
class Bookmark {
  Id id = Isar.autoIncrement;

  String categoryName;
  String itemName;
  String itemDescription;

  Bookmark({
    required this.categoryName,
    required this.itemName,
    required this.itemDescription,
  });
}

class CBookmarkManager extends ChangeNotifier {
  Isar? _database;
  Future<List<Bookmark>> get bookmarksFuture =>
      cDatabase.then((db) => db.bookmarks.where().findAll());
  Map<(String, String), Bookmark>? bookmarksByCategoryNameItemName;
  bool get isLoaded => _database != null;

  List<VoidCallback> onDispose = [];

  CBookmarkManager() {
    bookmarksFuture.then((bookmarks) {
      bookmarksByCategoryNameItemName = {
        for (var bookmark in bookmarks)
          (bookmark.categoryName, bookmark.itemName): bookmark
      };
      notifyListeners();
    });

    cDatabase.then((db) {
      _database = db;
      final listener =
          db.bookmarks.watchLazy().listen((event) => notifyListeners());
      onDispose.add(() => listener.cancel());
    });
  }

  @override
  void dispose() {
    for (var callback in onDispose) {
      callback();
    }
    super.dispose();
  }

  bool isBookmarked({required String categoryName, required String itemName}) {
    return bookmarksByCategoryNameItemName
            ?.containsKey((categoryName, itemName)) ??
        false;
  }

  Future addBookmark(Bookmark bookmark) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.bookmarks
          .filter()
          .categoryNameEqualTo(bookmark.categoryName)
          .itemNameEqualTo(bookmark.itemName)
          .deleteAll();
      await db.bookmarks.put(bookmark);
    });

    bookmarksByCategoryNameItemName?.putIfAbsent(
        (bookmark.categoryName, bookmark.itemName), () => bookmark);
    notifyListeners();
  }

  Future removeBookmark(Bookmark bookmark) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.bookmarks
          .filter()
          .categoryNameEqualTo(bookmark.categoryName)
          .itemNameEqualTo(bookmark.itemName)
          .deleteAll();
    });

    bookmarksByCategoryNameItemName?.removeWhere(
        (key, value) => key == (bookmark.categoryName, bookmark.itemName));
    notifyListeners();
  }
}
