import 'dart:io';

import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/opds/opds_crawler.dart';
import 'package:bookoscope/format/opds/opds_events.dart';
import 'package:bookoscope/util/list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xml/xml.dart';

import '../../helpers.dart';
import 'opds_crawler_test.mocks.dart';

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
const page1pathXml = '''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2005/Atom">
  <updated>2023-12-12T22:58:37</updated>
  <id>page1xml</id>
  <link rel="search" type="application/opensearchdescription+xml" href="/opds/page2xml" />
  <entry>
    <updated>2023-12-12T22:58:37</updated>
    <id>page3xml</id>
    <link rel="subsection" type="application/atom+xml;profile=opds-catalog;kind=navigation"
      href="/opds/page3xml" />
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
const page2pathXml = '''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2005/Atom">
  <updated>2023-12-12T23:11:39</updated>
  <id>page2xml</id>
  <link rel="start" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/opds/page1xml" />
  <entry>
    <updated>2023-12-12T23:11:39</updated>
    <id>1</id>
    <link rel="subsection" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/opds/page3xml" />
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
const page3pathXml = '''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2005/Atom">
  <updated>2023-12-12T23:11:39</updated>
  <id>page3xml</id>
  <link rel="start" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/opds/page1xml" />
  <entry>
    <updated>2023-12-12T23:11:39</updated>
    <id>1</id>
    <link rel="subsection" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/opds/page2xml" />
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

@GenerateMocks([HttpClient, HttpClientRequest, HttpClientResponse, HttpHeaders])
void main() {
  final client = MockHttpClient();
  const username = "USER";
  const password = "PASS";

  final testSource = Source(
    label: 'Test',
    description: 'Test Description',
    url: 'https://example.com',
    username: null,
    password: null,
    isEditable: true,
    isEnabled: true,
  );

  Future<void> mockFileResponse(
    String uri,
    String response, {
    bool exact = false,
  }) async {
    final mockRequest = MockHttpClientRequest();
    final mockResponse = MockHttpClientResponse();
    final mockHeaders = MockHttpHeaders();

    when(mockRequest.headers).thenReturn(mockHeaders);
    when(mockHeaders.set(any, any)).thenReturn(null);
    when(client.getUrl(
      argThat(predicate<Uri>((uriArg) =>
          exact ? uriArg.toString() == uri : uriArg.toString().endsWith(uri))),
    )).thenAnswer((_) => Future.value(mockRequest));
    when(mockRequest.close()).thenAnswer((_) => Future.value(mockResponse));
    when(mockResponse.statusCode).thenReturn(200);
    when(mockResponse.transform(any))
        .thenAnswer((_) => Stream<String>.fromIterable(response.split('\n')));
  }

  Future<void> mockAuthorizedFileResponse(
    String uri,
    String response, {
    bool shouldAuthenticate = false,
  }) async {
    final mockRequest = MockHttpClientRequest();
    final mockResponse = MockHttpClientResponse();
    final mockRequestHeaders = MockHttpHeaders();
    final mockResponseHeaders = MockHttpHeaders();

    when(client.getUrl(
      argThat(predicate<Uri>((uriArg) => uriArg.toString().endsWith(uri))),
    )).thenAnswer((_) => Future.value(mockRequest));

    var authorizationSet = false;

    when(mockRequest.headers).thenReturn(mockRequestHeaders);
    when(mockRequestHeaders.set("authorization", any)).thenAnswer((_) {
      authorizationSet = true;
    });
    when(mockRequestHeaders.value("authorization"))
        .thenAnswer((_) => authorizationSet ? "AUTH" : null);
    when(mockRequest.close()).thenAnswer((_) => Future.value(mockResponse));

    when(mockResponse.headers).thenReturn(mockResponseHeaders);
    when(mockResponseHeaders['www-authenticate'])
        .thenAnswer((_) => shouldAuthenticate ? ['Basic'] : null);
    when(mockResponse.statusCode).thenAnswer(
        (_) => mockRequest.headers.value('authorization') != null ? 200 : 401);
    when(mockResponse.transform(any))
        .thenAnswer((_) => Stream<String>.fromIterable(response.split('\n')));
  }

  group('OPDSCrawler - valid endpoints', () {
    OPDSCrawler crawler = OPDSCrawler(
        opdsRootUri: 'https://example.com/page1xml', source: testSource)
      ..extractor.client = client;

    setUp(() {
      crawler = OPDSCrawler(
        opdsRootUri: 'https://example.com/page1xml',
        source: testSource,
      )..extractor.client = client;
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

      final resourceEvents = events
          .whereType<OPDSCrawlResourceFound>()
          .distinctBy((event) => event.resource.originalId);

      expect(resourceEvents.length, 2);

      expectContains(resourceEvents,
          matcher: (event) => event.resource.title == 'Test Book #1');
      expectContains(resourceEvents,
          matcher: (event) => event.resource.title == 'Test Book #2');
    });
  });

  group('OPDSCrawler - valid endpoints with path', () {
    OPDSCrawler crawler = OPDSCrawler(
      opdsRootUri: 'https://example.com/opds',
      source: testSource,
    )..extractor.client = client;

    setUp(() {
      crawler = OPDSCrawler(
        opdsRootUri: 'https://example.com/opds',
        source: testSource,
      )..extractor.client = client;

      mockFileResponse('https://example.com/opds/opds', invalidXml,
          exact: true);
      mockFileResponse('https://example.com/opds/opds/page1xml', invalidXml,
          exact: true);
      mockFileResponse('https://example.com/opds/opds/page2xml', invalidXml,
          exact: true);
      mockFileResponse('https://example.com/opds/opds/page3xml', invalidXml,
          exact: true);

      mockFileResponse('https://example.com/opds', page1pathXml, exact: true);
      mockFileResponse('https://example.com/opds/page1xml', page1pathXml,
          exact: true);
      mockFileResponse('https://example.com/opds/page2xml', page2pathXml,
          exact: true);
      mockFileResponse('https://example.com/opds/page3xml', page3pathXml,
          exact: true);
    });

    tearDown(() => reset(client));

    test('finds exactly two resources', () async {
      final events = <OPDSCrawlEvent>[];

      await for (final event in crawler.crawlFromRoot()) {
        events.add(event);
      }

      final resourceEvents = events
          .whereType<OPDSCrawlResourceFound>()
          .distinctBy((event) => event.resource.originalId);

      expect(resourceEvents.length, 2);

      expectContains(resourceEvents,
          matcher: (event) => event.resource.title == 'Test Book #1');
      expectContains(resourceEvents,
          matcher: (event) => event.resource.title == 'Test Book #2');
    });
  });

  group('OPDSCrawler - invalid endpoint', () {
    OPDSCrawler crawler = OPDSCrawler(
      opdsRootUri: 'https://example.com/page1xml',
      source: testSource,
    )..extractor.client = client;

    setUp(() {
      crawler = OPDSCrawler(
        opdsRootUri: 'https://example.com/page1xml',
        source: testSource,
      )..extractor.client = client;
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

  group('OPDSCrawler - authorized endpoint but no auth provided', () {
    OPDSCrawler crawler = OPDSCrawler(
      opdsRootUri: 'https://example.com/page1xml',
      source: testSource,
    )..extractor.client = client;

    setUp(() {
      crawler = OPDSCrawler(
        opdsRootUri: 'https://example.com/page1xml',
        source: testSource,
      )..extractor.client = client;
      mockAuthorizedFileResponse('/page1xml', page1xml);
      mockAuthorizedFileResponse('/page2xml', page2xml);
      mockAuthorizedFileResponse('/page3xml', invalidXml);
    });

    tearDown(() => reset(client));

    test('gets a 401 Unauthorized error', () async {
      final events = <OPDSCrawlEvent>[];

      await for (final event in crawler.crawlFromRoot()) {
        events.add(event);
      }

      final errorEvents = events.whereType<OPDSCrawlException>();

      expect(errorEvents.length, 1);
      expectContains(
        errorEvents,
        matcher: (event) => event.exception.toString().contains("401"),
      );
    });
  });

  group('OPDSCrawler - authorized endpoint with basic auth', () {
    final testSourceWithCredentials = Source(
      label: 'Test Credentials',
      description: 'Description',
      url: 'http://example.com',
      username: username,
      password: password,
      isEditable: true,
      isEnabled: true,
    );

    OPDSCrawler crawler = OPDSCrawler(
      opdsRootUri: 'https://example.com/page1xml',
      source: testSourceWithCredentials,
    )..extractor.client = client;

    setUp(() {
      crawler = OPDSCrawler(
        opdsRootUri: 'https://example.com/page1xml',
        source: testSourceWithCredentials,
      )..extractor.client = client;
      mockAuthorizedFileResponse('/page1xml', page1xml,
          shouldAuthenticate: true);
      mockAuthorizedFileResponse('/page2xml', page2xml,
          shouldAuthenticate: true);
      mockAuthorizedFileResponse('/page3xml', invalidXml,
          shouldAuthenticate: true);
    });

    tearDown(() => reset(client));

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
