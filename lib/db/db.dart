import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/dated_title.db.dart';
import 'package:bookoscope/db/endpoint.db.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

final bkDatabase = _getDatabase();

Future<Isar> _getDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [SourceSchema, EndpointSchema, BookSchema, DatedTitleSchema],
    directory: dir.path,
  );
}
