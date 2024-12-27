import 'dart:collection';

import 'package:bookoscope/db/db.dart';
import 'package:bookoscope/util/debounce.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'dated_title.db.g.dart';

@collection
class DatedTitle {
  Id id = Isar.autoIncrement;

  @Index()
  String title;

  DateTime firstSeenDate;

  DatedTitle({
    required this.title,
    required this.firstSeenDate,
  });
}

class DBDatedTitles extends ChangeNotifier {
  Isar? _database;

  DateTime get twoWeeksAgo =>
      DateTime.now().toUtc().add(const Duration(days: -14));
  Future<List<DatedTitle>> get newTitlesFuture => bkDatabase.then((db) =>
      db.datedTitles.filter().firstSeenDateGreaterThan(twoWeeksAgo).findAll());
  HashSet<String> newTitles = HashSet();
  bool get isLoaded => _database != null;

  List<VoidCallback> onDispose = [];

  DBDatedTitles() {
    bkDatabase.then((db) {
      _database = db;
      final debouncedUpdate = bkDebounce(
        const Duration(milliseconds: 300),
        () => _updateData(),
        maxDuration: const Duration(milliseconds: 1000),
      );
      final listener =
          db.datedTitles.watchLazy().listen((event) => debouncedUpdate());
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
    newTitlesFuture.then((nt) {
      newTitles = HashSet.from(nt.map((dt) => dt.title));
      notifyListeners();
    });
  }

  Future<void> upsert(String title) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      final existing =
          await db.datedTitles.where().titleEqualTo(title).findFirst();

      if (existing != null) {
        return;
      }

      await db.datedTitles.put(DatedTitle(
        title: title,
        firstSeenDate: DateTime.now().toUtc(),
      ));
    });
  }
}
