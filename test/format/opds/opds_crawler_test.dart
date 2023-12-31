import 'dart:io';

import 'package:bookoscope/format/opds/opds_crawler.dart';
import 'package:bookoscope/format/opds/opds_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xml/xml.dart';

import '../../helpers.dart';
import 'opds_extractor_test.mocks.dart';

const page1xml = '''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2005/Atom">
  <updated>2023-12-12T22:58:37</updated>
  <id>page1xml</id>
  <link rel="self" type="application/atom+xml;profile=opds-catalog;kind=navigation"
    href="/page1xml" />
  <link rel="search" type="application/opensearchdescription+xml" href="/page2xml" />
  <entry>
    <updated>2023-12-12T22:58:37</updated>
    <id>page3xml</id>
    <link rel="subsection" type="application/atom+xml;profile=opds-catalog;kind=navigation"
      href="/page3xml" />
  </entry>
</feed>
''';

const page2xml = '''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2005/Atom">
  <updated>2023-12-12T23:11:39</updated>
  <id>page2xml</id>
  <link rel="self" type="application/atom+xml;profile=opds-catalog;kind=acquisition" href="/page2xml" />
  <link rel="start" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/page1xml" />
  <entry>
    <updated>2023-12-12T23:11:39</updated>
    <id>1</id>
    <link rel="subsection" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/page3xml" />
  </entry>
  <entry>
    <updated>2023-12-12T23:16:03</updated>
    <id>52</id>
    <title>Test Book #1</title>
    <content type="text">application/epub+zip</content>
    <link rel="http://opds-spec.org/image" type="image/jpeg"
      href="/api/image/chapter-cover?chapterId=52&amp;apiKey=my-api-key" />
    <link rel="http://opds-spec.org/acquisition/open-access" type="application/epub+zip"
      href="/api/opds/my-api-key/series/52/volume/52/chapter/52/download/TEST_EPUB.epub"
      title="TEST_EPUB.epub" p5:count="48" xmlns:p5="http://vaemendis.net/opds-pse/ns" />
  </entry>
</feed>
''';

const page3xml = '''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2005/Atom">
  <updated>2023-12-12T23:11:39</updated>
  <id>page3xml</id>
  <link rel="self" type="application/atom+xml;profile=opds-catalog;kind=acquisition" href="/page3xml" />
  <link rel="start" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/page1xml" />
  <entry>
    <updated>2023-12-12T23:11:39</updated>
    <id>1</id>
    <link rel="subsection" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/page2xml" />
  </entry>
  <entry>
    <updated>2023-12-12T23:16:03</updated>
    <id>52</id>
    <title>Test Book #1</title>
    <content type="text">application/epub+zip</content>
    <link rel="http://opds-spec.org/image" type="image/jpeg"
      href="/api/image/chapter-cover?chapterId=52&amp;apiKey=my-api-key" />
    <link rel="http://opds-spec.org/acquisition/open-access" type="application/epub+zip"
      href="/api/opds/my-api-key/series/52/volume/52/chapter/52/download/TEST_EPUB.epub"
      title="TEST_EPUB.epub" />
  </entry>
  <entry>
    <updated>2023-12-12T23:16:03</updated>
    <id>04</id>
    <title>Test Book #2</title>
    <content type="text">application/epub+zip</content>
    <link rel="http://opds-spec.org/image" type="image/jpeg"
      href="/api/image/chapter-cover?chapterId=04&amp;apiKey=my-api-key" />
    <link rel="http://opds-spec.org/acquisition/open-access" type="application/epub+zip"
      href="/api/opds/my-api-key/series/04/volume/04/chapter/04/download/TEST_EPUB.epub"
      title="TEST_EPUB_2.epub" />
  </entry>
</feed>
''';

const invalidXml = '''
<blah blah
:::doesn't work
<
''';

@GenerateMocks([HttpClient, HttpClientRequest, HttpClientResponse])
void main() {
  final client = MockHttpClient();

  Future<void> mockFileResponse(String uri, String response) async {
    final mockRequest = MockHttpClientRequest();
    final mockResponse = MockHttpClientResponse();

    when(client.getUrl(
      argThat(predicate<Uri>((uriArg) => uriArg.toString().endsWith(uri))),
    )).thenAnswer((_) => Future.value(mockRequest));
    when(mockRequest.close()).thenAnswer((_) => Future.value(mockResponse));
    when(mockResponse.statusCode).thenReturn(200);
    when(mockResponse.transform(any))
        .thenAnswer((_) => Stream<String>.fromIterable(response.split('\n')));
  }

  group('OPDSCrawler - valid endpoints', () {
    OPDSCrawler crawler =
        OPDSCrawler(opdsRootUri: 'https://example.com/page1xml')
          ..extractor.client = client;

    setUp(() {
      crawler = OPDSCrawler(opdsRootUri: 'https://example.com/page1xml')
        ..extractor.client = client;
      mockFileResponse('/page1xml', page1xml);
      mockFileResponse('/page2xml', page2xml);
      mockFileResponse('/page3xml', page3xml);
    });

    tearDown(() => reset(client));

    test('crawls exactly three distinct pages without duplication', () async {
      await crawler.crawlFromRoot().drain();

      verify(client.getUrl(
        argThat(predicate<Uri>((uri) => uri.toString().endsWith('page1xml'))),
      )).called(1);
      verify(client.getUrl(
        argThat(predicate<Uri>((uri) => uri.toString().endsWith('page2xml'))),
      )).called(1);
      verify(client.getUrl(
        argThat(predicate<Uri>((uri) => uri.toString().endsWith('page3xml'))),
      )).called(1);

      verifyNoMoreInteractions(client);
    });

    test('emits exactly three OPDSCrawlBegin events', () async {
      final events = <OPDSCrawlEvent>[];

      await for (final event in crawler.crawlFromRoot()) {
        events.add(event);
      }

      final beginEvents = events.whereType<OPDSCrawlBegin>();

      expect(beginEvents.length, 3);

      expectContains(beginEvents,
          matcher: (event) => event.uri.endsWith('page1xml'));
      expectContains(beginEvents,
          matcher: (event) => event.uri.endsWith('page2xml'));
      expectContains(beginEvents,
          matcher: (event) => event.uri.endsWith('page3xml'));
    });

    test('emits exactly three OPDSCrawlSuccess events', () async {
      final events = <OPDSCrawlEvent>[];

      await for (final event in crawler.crawlFromRoot()) {
        events.add(event);
      }

      final successEvents = events.whereType<OPDSCrawlSuccess>();

      expect(successEvents.length, 3);

      expectContains(successEvents,
          matcher: (event) => event.uri.endsWith('page1xml'));
      expectContains(successEvents,
          matcher: (event) => event.uri.endsWith('page2xml'));
      expectContains(successEvents,
          matcher: (event) => event.uri.endsWith('page3xml'));
    });

    test('finds exactly two resources', () async {
      final events = <OPDSCrawlEvent>[];

      await for (final event in crawler.crawlFromRoot()) {
        events.add(event);
      }

      final resourceEvents = events.whereType<OPDSCrawlResourceFound>();

      expect(resourceEvents.length, 2);

      expectContains(resourceEvents,
          matcher: (event) => event.resource.title == 'Test Book #1');
      expectContains(resourceEvents,
          matcher: (event) => event.resource.title == 'Test Book #2');
    });
  });

  group('OPDSCrawler - invalid endpoint', () {
    OPDSCrawler crawler =
        OPDSCrawler(opdsRootUri: 'https://example.com/page1xml')
          ..extractor.client = client;

    setUp(() {
      crawler = OPDSCrawler(opdsRootUri: 'https://example.com/page1xml')
        ..extractor.client = client;
      mockFileResponse('/page1xml', page1xml);
      mockFileResponse('/page2xml', page2xml);
      mockFileResponse('/page3xml', invalidXml);
    });

    tearDown(() => reset(client));

    test('crawls all three pages', () async {
      await crawler.crawlFromRoot().drain();

      verify(client.getUrl(
        argThat(predicate<Uri>((uri) => uri.toString().endsWith('page1xml'))),
      )).called(1);
      verify(client.getUrl(
        argThat(predicate<Uri>((uri) => uri.toString().endsWith('page2xml'))),
      )).called(1);
      verify(client.getUrl(
        argThat(predicate<Uri>((uri) => uri.toString().endsWith('page3xml'))),
      )).called(1);

      verifyNoMoreInteractions(client);
    });

    test('emits three begin events', () async {
      final events = <OPDSCrawlEvent>[];

      await for (final event in crawler.crawlFromRoot()) {
        events.add(event);
      }

      final beginEvents = events.whereType<OPDSCrawlBegin>();

      expect(beginEvents.length, 3);

      expectContains(beginEvents,
          matcher: (event) => event.uri.endsWith('page1xml'));
      expectContains(beginEvents,
          matcher: (event) => event.uri.endsWith('page2xml'));
      expectContains(beginEvents,
          matcher: (event) => event.uri.endsWith('page3xml'));
    });

    test('emits one error', () async {
      final events = <OPDSCrawlEvent>[];

      await for (final event in crawler.crawlFromRoot()) {
        events.add(event);
      }

      final exceptionEvents = events.whereType<OPDSCrawlException>();

      expect(exceptionEvents.length, 1);

      expectContains(exceptionEvents,
          matcher: (event) =>
              event.uri.endsWith('page3xml') &&
              event.exception is XmlParserException);
    });

    test('finds one resource', () async {
      final events = <OPDSCrawlEvent>[];

      await for (final event in crawler.crawlFromRoot()) {
        events.add(event);
      }

      final resourceEvents = events.whereType<OPDSCrawlResourceFound>();

      expect(resourceEvents.length, 1);

      expectContains(resourceEvents,
          matcher: (event) => event.resource.title == 'Test Book #1');
    });
  });
}
