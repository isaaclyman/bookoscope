import 'dart:convert';

import 'package:bookoscope/db/db.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'source.db.g.dart';

@collection
class Source {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
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

  String? getBasicAuthHeader() {
    if ((username?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false)) {
      return "Basic ${base64.encode(utf8.encode('$username:$password'))}";
    }

    return null;
  }
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

  Future<void> upsert(Source source) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.sources.putByUrl(source);
    });
  }

  Future<void> delete(Source source) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.sources.delete(source.id);
    });
  }
}
