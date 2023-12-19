import 'package:bookoscope/format/guten/guten_csv.dart';
import 'package:bookoscope/format/guten/guten_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gutenberg CSV catalog extractor', () {
    final extractor = GCSVExtractor();
    List<GCSVRow> rows = [];

    setUpAll(() async {
      rows = await extractor.getRows().toList();
    });

    test('extracts the first entry (declaration of independence)', () {
      expectContains(
        rows,
        matcher: (row) =>
            row.title ==
                'The Declaration of Independence of the United States of America' &&
            row.authors!.contains('Jefferson, Thomas, 1743-1826') &&
            row.id == 1,
      );
    });

    test('extracts the final entry (un mousse de surcouf)', () {
      expectContains(
        rows,
        matcher: (row) =>
            row.title == 'Un mousse de Surcouf' &&
            row.authors!.contains('Maël, Pierre') &&
            row.id == 72366,
      );
    });

    test('extracts an entry with multiple authors', () {
      final multiAuthorEntry =
          rows.firstWhere((row) => row.title == 'The Federalist Papers');
      expectContains(multiAuthorEntry.authors,
          literal: 'Hamilton, Alexander, 1757-1804');
      expectContains(multiAuthorEntry.authors, literal: 'Jay, John, 1745-1829');
      expectContains(multiAuthorEntry.authors,
          literal: 'Madison, James, 1751-1836');
    });
  });
}
