import 'package:bookoscope/db/db.dart';
import 'package:bookoscope/util/debounce.dart';
import 'package:bookoscope/util/list.dart';
import 'package:bookoscope/util/string.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'book.db.g.dart';

@collection
class Book {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('sourceId')], unique: true, replace: true)
  String originalId;
  int sourceId;

  String title;

  List<String> authors;

  String? format;

  List<String> categories;

  List<BookMetadata> metadata;

  List<BookDownloadUrl>? downloadUrls;

  String? imageUrl;

  bool isGutenberg;

  Book({
    required this.originalId,
    required this.title,
    required this.authors,
    required this.format,
    required this.categories,
    required this.metadata,
    required this.downloadUrls,
    required this.imageUrl,
    required this.sourceId,
    required this.isGutenberg,
  });

  void merge(Book other) {
    assert(other.sourceId == sourceId && other.originalId == originalId);
    title = other.title.coalesce(title);
    authors = authors.followedBy(other.authors).distinct();
    format = other.format.coalesce(format);
    categories = categories.followedBy(other.categories).distinct();
    metadata = metadata.followedBy(other.metadata).distinctBy((el) => el.type);
    downloadUrls = (downloadUrls ?? [])
        .followedBy(other.downloadUrls ?? [])
        .distinctBy((el) => el.uri);
    imageUrl = other.imageUrl ?? imageUrl;
  }
}

@embedded
class BookMetadata {
  String? type;
  String? content;

  BookMetadata({
    this.type,
    this.content,
  });
}

@embedded
class BookDownloadUrl {
  String? label;
  String? uri;
  String? rel;
  String? type;

  BookDownloadUrl({
    this.label,
    this.uri,
    this.rel,
    this.type,
  });
}

class DBBooks extends ChangeNotifier {
  Isar? _database;
  Future<List<Book>> get booksFuture =>
      bkDatabase.then((db) => db.books.where().findAll());
  List<Book> books = [];
  bool get isLoaded => _database != null;

  List<VoidCallback> onDispose = [];

  DBBooks() {
    bkDatabase.then((db) {
      _database = db;
      final debouncedUpdate = bkDebounce(
        const Duration(milliseconds: 300),
        () => _updateData(),
        maxDuration: const Duration(milliseconds: 1000),
      );
      final listener =
          db.books.watchLazy().listen((event) => debouncedUpdate());
      onDispose.add(() => listener.cancel());
    });
    _updateData();
  }

  @override
  void dispose() {
    for (var callback in onDispose) {
      callback();
    }
    super.dispose();
  }

  void _updateData() {
    booksFuture.then((books) {
      this.books = books;
      notifyListeners();
    });
  }

  Future<void> deleteAllBySourceId(int sourceId) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.books.filter().sourceIdEqualTo(sourceId).deleteAll();
    });
  }

  Future<void> upsert(Book book) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      final existing = await db.books
          .where()
          .originalIdSourceIdEqualTo(book.originalId, book.sourceId)
          .findFirst();

      if (existing != null) {
        book.merge(existing);
      }

      await db.books.putByOriginalIdSourceId(book);
    });
  }

  Future<void> overwriteEntireSource(int sourceId, List<Book> books) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.books.filter().sourceIdEqualTo(sourceId).deleteAll();
      await db.books.putAll(books);
    });
  }

  Future<void> remove(Book book) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.books.delete(book.id);
    });
  }
}
