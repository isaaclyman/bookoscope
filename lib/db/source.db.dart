import 'package:bookoscope/db/db.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'source.db.g.dart';

@collection
class Source {
  Id id = Isar.autoIncrement;

  @Index()
  String url;

  String label;

  String? username;

  String? password;

  bool isCompletelyCrawled = false;

  Source({
    required this.label,
    required this.url,
    required this.username,
    required this.password,
  });
}

class DBSources extends ChangeNotifier {
  Isar? _database;
  Future<List<Source>> get sourcesFuture =>
      bkDatabase.then((db) => db.sources.where().findAll());
  List<Source> sources = [];
  bool get isLoaded => _database != null;

  List<VoidCallback> onDispose = [];

  DBSources() {
    sourcesFuture.then((sources) {
      this.sources = sources;

      notifyListeners();
    });

    bkDatabase.then((db) {
      _database = db;
      final listener =
          db.sources.watchLazy().listen((event) => notifyListeners());
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

  Future upsert(Source source) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.sources.where().urlEqualTo(source.url).deleteAll();
      await db.sources.put(source);
    });

    notifyListeners();
  }

  Future remove(Source source) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.sources.delete(source.id);
    });

    notifyListeners();
  }
}
