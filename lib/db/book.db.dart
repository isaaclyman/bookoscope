import 'package:bookoscope/db/db.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'book.db.g.dart';

@collection
class Book {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('sourceId')])
  String originalId;
  int sourceId;

  String title;

  List<String> authors;

  List<String> tags;

  List<BookDownloadUrl>? downloadUrls;

  String? imageUrl;

  bool isGutenberg;

  Book({
    required this.originalId,
    required this.title,
    required this.authors,
    required this.tags,
    required this.downloadUrls,
    required this.imageUrl,
    required this.sourceId,
    required this.isGutenberg,
  });
}

@embedded
class BookDownloadUrl {
  String? label;
  String? uri;
  String? type;

  BookDownloadUrl({
    this.label,
    this.uri,
    this.type,
  });
}

class DBBooks extends ChangeNotifier {
  Isar? _database;
  Future<List<Book>> get booksFuture =>
      bkDatabase.then((db) => db.books.where().findAll());
  bool get isLoaded => _database != null;

  List<VoidCallback> onDispose = [];

  DBBooks() {
    booksFuture.then((endpoints) {
      notifyListeners();
    });

    bkDatabase.then((db) {
      _database = db;
      final listener =
          db.books.watchLazy().listen((event) => notifyListeners());
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

  Future upsert(Book book) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.books
          .where()
          .originalIdSourceIdEqualTo(book.originalId, book.sourceId)
          .deleteAll();
      await db.books.put(book);
    });

    notifyListeners();
  }

  Future remove(Book book) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.books.delete(book.id);
    });

    notifyListeners();
  }
}
