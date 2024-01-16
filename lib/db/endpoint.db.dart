import 'package:bookoscope/db/db.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'endpoint.db.g.dart';

@collection
class Endpoint {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String url;

  bool isCrawled;
  String? exceptionMessage;

  int sourceId;

  Endpoint({
    required this.url,
    required this.isCrawled,
    required this.sourceId,
    this.exceptionMessage,
  });
}

class DBEndpoints extends ChangeNotifier {
  Isar? _database;
  Future<List<Endpoint>> get endpointsFuture =>
      bkDatabase.then((db) => db.endpoints.where().findAll());
  bool get isLoaded => _database != null;

  List<VoidCallback> onDispose = [];

  DBEndpoints() {
    endpointsFuture.then((endpoints) {
      notifyListeners();
    });

    bkDatabase.then((db) {
      _database = db;
      final listener =
          db.endpoints.watchLazy().listen((event) => notifyListeners());
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

  Future<void> deleteAllBySourceId(int sourceId) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.endpoints.filter().sourceIdEqualTo(sourceId).deleteAll();
    });
  }

  Future<void> upsert(Endpoint endpoint) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.endpoints.putByUrl(endpoint);
    });
  }

  Future<void> remove(Endpoint endpoint) async {
    final db = _database;
    assert(db != null);
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.endpoints.delete(endpoint.id);
    });
  }
}
