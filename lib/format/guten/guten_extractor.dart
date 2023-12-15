import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:bookoscope/format/csv/guten_csv.dart';

class GCSVExtractor {
  Stream<GCSVRow> getRows() async* {
    final fileString = await rootBundle.loadString('assets/pg_catalog.csv');
    final rows = const CsvToListConverter(convertEmptyTo: EmptyValue.NULL)
        .convert(fileString);
    final headersByIndex = rows.removeAt(0).asMap();

    for (final row in rows) {
      final rowMap = row.asMap().map<String, dynamic>(
            (ix, value) => MapEntry(headersByIndex[ix], value),
          );
      yield GCSVRow.fromMap(rowMap);
    }
  }
}
