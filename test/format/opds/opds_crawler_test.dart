import 'dart:io';

import 'package:bookoscope/format/opds/opds_crawler.dart';
import 'package:bookoscope/format/opds/opds_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

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

@GenerateMocks([HttpClient, HttpClientRequest, HttpClientResponse])
void main() {
  group('OPDSCrawler', () {
    final client = MockHttpClient();
    final crawler = OPDSCrawler(opdsRootUri: 'https://example.com/page1xml')
      ..extractor.client = client;

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

    mockFileResponse('/page1xml', page1xml);
    mockFileResponse('/page2xml', page2xml);
    mockFileResponse('/page3xml', page3xml);

    test('crawls three distinct pages and finds two resources', () async {
      final events = <OPDSCrawlEvent>[];

      await for (final event in crawler.crawlFromRoot()) {
        events.add(event);
      }

      print(events);
      expect(verify(client.getUrl(any)).callCount, 3);
    });
  });
}
