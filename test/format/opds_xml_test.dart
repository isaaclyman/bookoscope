import 'dart:io';

import 'package:bookoscope/format/opds_xml.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../helpers.dart';
import 'opds_xml_test.mocks.dart';

@GenerateMocks([HttpClient, HttpClientRequest, HttpClientResponse])
void main() {
  group('extractXml', () {
    final client = MockHttpClient();
    final extractor = OPDSExtractor(rootUri: 'https://example.com')
      ..client = client;

    Future<void> mockFileResponse(File file) async {
      final fileString = await file.readAsString();
      final mockRequest = MockHttpClientRequest();
      final mockResponse = MockHttpClientResponse();

      when(client.getUrl(any)).thenAnswer((_) => Future.value(mockRequest));
      when(mockRequest.close()).thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.transform(any)).thenAnswer(
          (_) => Stream<String>.fromIterable(fileString.split('\n')));
    }

    tearDown(() => reset(client));

    test('Correctly parses gutenberg OPDS root', () async {
      final file = File('examples/gutenberg_root.xml');
      await mockFileResponse(file);

      final feed =
          await extractor.getFeed('https://example.com/gutenberg_root');

      expect(feed.id, 'http://www.gutenberg.org/ebooks/search.opds/');
      expect(feed.title, 'All Books (sorted by popularity)');
      expect(feed.updated, '2023-12-12T18:07:42Z');

      expect(feed.links?.length, 6);
      final nextLink = feed.links?['next'];
      expect(nextLink?.href, '/ebooks/search.opds/?start_index=26');

      expect(feed.entries?.length, 27);
      expectContains(
        feed.entries,
        (element) =>
            element.title == 'Sort Alphabetically by Title' &&
            element.links?['subsection']?.href ==
                '/ebooks/search.opds/?sort_order=title',
      );
      expectContains(
        feed.entries,
        (element) =>
            element.title == 'Frankenstein; Or, The Modern Prometheus' &&
            element.links?['subsection']?.href == '/ebooks/84.opds',
      );
    });

    test('Correctly parses Kavita OPDS root', () async {
      final file = File('examples/kavita_root.xml');
      await mockFileResponse(file);

      final feed = await extractor.getFeed('https://example.com/kavita_root');

      expect(feed.id, 'root');
      expect(feed.title, 'Kavita');
      expect(feed.updated, '2023-12-12T22:58:37');

      expect(feed.links?.length, 3);
      final nextLink = feed.links?['start'];
      expect(nextLink?.href, '/api/opds/my-api-key');

      expect(feed.entries?.length, 6);
      expectContains(
        feed.entries,
        (element) =>
            element.title == 'On Deck' &&
            element.links?['subsection']?.href ==
                '/api/opds/my-api-key/on-deck',
      );
      expectContains(
        feed.entries,
        (element) =>
            element.title == 'All Collections' &&
            element.links?['subsection']?.href ==
                '/api/opds/my-api-key/collections',
      );
    });
  });
}
