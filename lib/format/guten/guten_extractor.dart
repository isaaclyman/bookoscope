import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:bookoscope/format/guten/guten_csv.dart';

class GCSVExtractor {
  Future<Iterable<GCSVRow>> getRows() async {
    final fileString = await rootBundle.loadString('assets/pg_catalog.csv');
    final rows = const CsvToListConverter(convertEmptyTo: EmptyValue.NULL)
        .convert(fileString);
    final headersByIndex = rows.removeAt(0).asMap();
    return rows.map((row) {
      final rowMap = row.asMap().map<String, dynamic>(
            (ix, value) => MapEntry(headersByIndex[ix], value),
          );
      return GCSVRow.fromMap(rowMap);
    });
  }
}
