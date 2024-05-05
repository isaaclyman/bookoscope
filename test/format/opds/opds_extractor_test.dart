import 'dart:io';

import 'package:bookoscope/format/opds/opds_extractor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../helpers.dart';
import 'opds_extractor_test.mocks.dart';

@GenerateMocks([HttpClient, HttpClientRequest, HttpClientResponse])
void main() {
  group('extractXml', () {
    final client = MockHttpClient();
    final extractor = OPDSExtractor()..client = client;

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

      final feed = await extractor
          .getFeed(Uri.parse('https://example.com/gutenberg_root'));

      expect(feed.id, 'http://www.gutenberg.org/ebooks/search.opds/');
      expect(feed.title, 'All Books (sorted by popularity)');
      expect(feed.updated, '2023-12-12T18:07:42Z');

      expect(feed.links?.length, 6);
      expectContains(feed.links,
          matcher: (link) =>
              link.rel == 'next' &&
              link.href == '/ebooks/search.opds/?start_index=26');

      expect(feed.entries?.length, 27);
      expectContains(
        feed.entries,
        matcher: (element) =>
            element.title == 'Sort Alphabetically by Title' &&
            element.links!.any((link) =>
                link.rel == 'subsection' &&
                link.href == '/ebooks/search.opds/?sort_order=title'),
      );
      expectContains(
        feed.entries,
        matcher: (element) =>
            element.title == 'Frankenstein; Or, The Modern Prometheus' &&
            element.links!.any((link) =>
                link.rel == 'subsection' && link.href == '/ebooks/84.opds'),
      );
    });

    test('Correctly parses Kavita OPDS root', () async {
      final file = File('examples/kavita_root.xml');
      await mockFileResponse(file);

      final feed =
          await extractor.getFeed(Uri.parse('https://example.com/kavita_root'));

      expect(feed.id, 'root');
      expect(feed.title, 'Kavita');
      expect(feed.updated, '2023-12-12T22:58:37');

      expect(feed.links?.length, 3);
      expectContains(feed.links,
          matcher: (link) =>
              link.rel == 'start' && link.href == '/api/opds/my-api-key');

      expect(feed.entries?.length, 6);
      expectContains(
        feed.entries,
        matcher: (element) =>
            element.title == 'On Deck' &&
            element.links!.any((link) =>
                link.rel == 'subsection' &&
                link.href == '/api/opds/my-api-key/on-deck'),
      );
      expectContains(
        feed.entries,
        matcher: (element) =>
            element.title == 'All Collections' &&
            element.links!.any((link) =>
                link.rel == 'subsection' &&
                link.href == '/api/opds/my-api-key/collections'),
      );
    });

    test('correctly parses calibre root', () async {
      final file = File('examples/calibre_root.xml');
      await mockFileResponse(file);

      final feed = await extractor
          .getFeed(Uri.parse('https://example.com/calibre_root'));

      expect(feed.id, 'urn:calibre:main');
      expect(feed.title, 'calibre Library');
      expect(feed.updated, '2024-05-05T11:41:52+00:00');

      expect(feed.links?.length, 2);
      expectContains(feed.links,
          matcher: (link) =>
              link.rel == 'start' &&
              link.href == '/opds?library_id=Calibre_Library');

      expect(feed.entries?.length, 5);
      expectContains(
        feed.entries,
        matcher: (element) =>
            element.title == 'By Title' &&
            element.links!.any((link) =>
                link.type ==
                    'application/atom+xml;type=feed;profile=opds-catalog' &&
                link.href ==
                    '/opds/navcatalog/4f7469746c65?library_id=Calibre_Library'),
      );
      expectContains(
        feed.entries,
        matcher: (element) =>
            element.title == 'Library: Calibre Library' &&
            element.links!.any((link) =>
                link.type ==
                    'application/atom+xml;type=feed;profile=opds-catalog' &&
                link.href == '/opds?library_id=Calibre_Library'),
      );
    });

    test('correctly parses calibre By Title subpage', () async {
      final file = File('examples/calibre_bytitle.xml');
      await mockFileResponse(file);

      final feed = await extractor
          .getFeed(Uri.parse('https://example.com/calibre_bytitle'));

      expect(feed.id, 'calibre-all:title');
      expect(feed.title, 'calibre Library :: By Title');
      expect(feed.updated, '2024-05-05T11:41:52+00:00');

      expect(feed.links?.length, 5);
      expectContains(feed.links,
          matcher: (link) =>
              link.rel == 'first' &&
              link.href ==
                  '/opds/navcatalog/4f7469746c65?library_id=Calibre_Library');

      expect(feed.entries?.length, 1);
      expectContains(
        feed.entries,
        matcher: (element) =>
            element.title == 'Quick Start Guide' &&
            element.authors!.contains("John Schember") &&
            element.links!.any((link) =>
                link.rel == 'http://opds-spec.org/acquisition' &&
                link.href == '/get/epub/1/Calibre_Library'),
      );
    });
  });
}
