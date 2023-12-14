import 'package:bookoscope/db/db.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'book.db.g.dart';

@collection
class Book {
  Id id = Isar.autoIncrement;

  String title;
  String author;
  List<String> tags;
  List<BookDownloadUrl> downloadUrls;
  int sourceId;

  Book({
    required this.title,
    required this.author,
    required this.tags,
    required this.downloadUrls,
    required this.sourceId,
  });
}

@embedded
class BookDownloadUrl {
  String? label;
  String? url;
}

class BKBookManager extends ChangeNotifier {
  Isar? _database;
  Future<List<Book>> get booksFuture =>
      bkDatabase.then((db) => db.books.where().findAll());
  bool get isLoaded => _database != null;

  List<VoidCallback> onDispose = [];

  BKBookManager() {
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

  Future addBooks(List<Book> books) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.books.putAll(books);
    });

    notifyListeners();
  }

  Future removeBook(Book book) async {
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
