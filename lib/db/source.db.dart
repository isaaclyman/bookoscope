import 'package:bookoscope/db/db.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'source.db.g.dart';

@collection
class Source {
  Id id = Isar.autoIncrement;

  @Index()
  String url;

  String label;

  String? description;

  String? username;

  String? password;

  bool isCompletelyCrawled = false;

  bool isEditable;

  bool isEnabled;

  Source({
    required this.label,
    required this.description,
    required this.url,
    required this.username,
    required this.password,
    required this.isEditable,
    required this.isEnabled,
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
    bkDatabase.then((db) {
      _database = db;
      final listener = db.sources.watchLazy().listen((event) => _updateData());
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
    sourcesFuture.then((sources) {
      this.sources = sources.sorted((a, b) {
        if (a.isEnabled != b.isEnabled) {
          return a.isEnabled ? -1 : 1;
        }

        return a.label.compareTo(b.label);
      });
      notifyListeners();
    });
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
  }

  Future delete(Source source) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.sources.delete(source.id);
    });
  }
}
