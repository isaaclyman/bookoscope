import 'package:bookoscope/db/db.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'source.db.g.dart';

@collection
class Source {
  Id id = Isar.autoIncrement;

  String label;
  String url;
  String username;
  String password;
  bool isCompletelyCrawled = false;

  Source({
    required this.label,
    required this.url,
    required this.username,
    required this.password,
  });
}

class BKSourceManager extends ChangeNotifier {
  Isar? _database;
  Future<List<Source>> get sourcesFuture =>
      bkDatabase.then((db) => db.sources.where().findAll());
  bool get isLoaded => _database != null;

  List<VoidCallback> onDispose = [];

  BKSourceManager() {
    sourcesFuture.then((sources) {
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

  Future upsertSource(Source source) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.sources.put(source);
    });

    notifyListeners();
  }

  Future removeSource(Source source) async {
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
