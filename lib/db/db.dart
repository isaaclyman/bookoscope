import 'package:bookoscope/db/bookmark.db.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

final cDatabase = _getDatabase();

Future<Isar> _getDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [BookmarkSchema],
    directory: dir.path,
  );
}
