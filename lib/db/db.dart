import 'package:bookoscope/db/endpoint.db.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

final bkDatabase = _getDatabase();

Future<Isar> _getDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [EndpointSchema],
    directory: dir.path,
  );
}
