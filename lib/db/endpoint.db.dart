import 'package:bookoscope/db/db.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'endpoint.db.g.dart';

@collection
class Endpoint {
  Id id = Isar.autoIncrement;

  String url;
  bool isCrawled;
  int sourceId;

  Endpoint({
    required this.url,
    required this.isCrawled,
    required this.sourceId,
  });
}

class BKEndpointManager extends ChangeNotifier {
  Isar? _database;
  Future<List<Endpoint>> get endpointsFuture =>
      bkDatabase.then((db) => db.endpoints.where().findAll());
  bool get isLoaded => _database != null;

  List<VoidCallback> onDispose = [];

  BKEndpointManager() {
    endpointsFuture.then((sources) {
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

  Future upsertEndpoint(Endpoint endpoint) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.endpoints.put(endpoint);
    });

    notifyListeners();
  }

  Future removeSource(Endpoint endpoint) async {
    final db = _database;
    if (db == null) {
      return;
    }

    await db.writeTxn(() async {
      await db.endpoints.delete(endpoint.id);
    });

    notifyListeners();
  }
}
