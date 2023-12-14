import 'package:bookoscope/format/opds/opds_xml.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import '../../helpers.dart';

void main() {
  group('OPDSLink constructor', () {
    group('[Gutenberg Project]', () {
      test('understands a search <link>', () {
        const xml = '''
          <link type="application/atom+xml;profile=opds-catalog" rel="subsection"
            href="/ebooks/search.opds/?sort_order=title" />
        ''';
        final element = XmlDocument.parse(xml).rootElement;
        final link = OPDSLink.fromXML(element);

        expect(link.type, 'application/atom+xml;profile=opds-catalog');
        expect(link.rel, 'subsection');
        expect(link.href, '/ebooks/search.opds/?sort_order=title');
        expect(link.title, null);
      });

      test('understands an acquisition <link>', () {
        const xml = '''
          <link type="application/epub+zip" rel="http://opds-spec.org/acquisition"
            title="EPUB (no images, older E-readers)" length="65187"
            href="https://www.gutenberg.org/ebooks/1080.epub.noimages" />
        ''';
        final element = XmlDocument.parse(xml).rootElement;
        final link = OPDSLink.fromXML(element);

        expect(link.type, 'application/epub+zip');
        expect(link.rel, 'http://opds-spec.org/acquisition');
        expect(
            link.href, 'https://www.gutenberg.org/ebooks/1080.epub.noimages');
        expect(link.title, 'EPUB (no images, older E-readers)');
      });
    });

    group('[Kavita]', () {
      test('understands a search <link>', () {
        const xml = '''
          <link rel="search" type="application/opensearchdescription+xml" 
            href="/api/opds/my-api-key/search" />
        ''';
        final element = XmlDocument.parse(xml).rootElement;
        final link = OPDSLink.fromXML(element);

        expect(link.type, 'application/opensearchdescription+xml');
        expect(link.rel, 'search');
        expect(link.href, '/api/opds/my-api-key/search');
        expect(link.title, null);
      });

      test('understands an acquisition <link>', () {
        const xml = '''
          <link rel="http://opds-spec.org/acquisition/open-access" type="application/epub+zip"
            href="/api/opds/my-api-key/series/52/volume/52/chapter/52/download/TEST_EPUB.epub"
            title="TEST_EPUB.epub" p5:count="48" xmlns:p5="http://vaemendis.net/opds-pse/ns" />
        ''';
        final element = XmlDocument.parse(xml).rootElement;
        final link = OPDSLink.fromXML(element);

        expect(link.type, 'application/epub+zip');
        expect(link.rel, 'http://opds-spec.org/acquisition/open-access');
        expect(link.href,
            '/api/opds/my-api-key/series/52/volume/52/chapter/52/download/TEST_EPUB.epub');
        expect(link.title, 'TEST_EPUB.epub');
      });
    });
  });

  group('OPDSEntry constructor', () {
    group('[Gutenberg Project]', () {
      test('understands a directory <entry>', () {
        const xml = '''
          <entry>
            <updated>2023-12-12T22:55:57Z</updated>
            <id>https://www.gutenberg.org/ebooks/search.opds/?sort_order=downloads</id>
            <title>Popular</title>
            <content type="text">Our most popular books.</content>
            <link type="application/atom+xml;profile=opds-catalog" rel="subsection"
              href="/ebooks/search.opds/?sort_order=downloads" />
            <link type="image/png" rel="http://opds-spec.org/image/thumbnail"
              href="https://www.gutenberg.org/gutenberg/bookmark.png" />
          </entry>
        ''';

        final element = XmlDocument.parse(xml).rootElement;
        final entry = OPDSEntry.fromXML(element);

        expect(entry.id,
            'https://www.gutenberg.org/ebooks/search.opds/?sort_order=downloads');
        expect(entry.updated, '2023-12-12T22:55:57Z');
        expect(entry.title, 'Popular');
        expect(entry.textContent, 'Our most popular books.');

        expect(entry.summary, null);
        expect(entry.author, null);
        expect(entry.categories, null);
        expect(entry.extent, null);
        expect(entry.format, null);
        expect(entry.htmlContent, null);

        expect(entry.links?.length, 2);
        expectContains(entry.links,
            matcher: (link) =>
                link.type == 'image/png' &&
                link.href ==
                    'https://www.gutenberg.org/gutenberg/bookmark.png');
      });

      test('understands a resource <entry>', () {
        const xml = '''
          <entry>
            <updated>2023-12-12T22:26:39Z</updated>
            <title>A Modest Proposal</title>
            <content type="xhtml">
              <div xmlns="http://www.w3.org/1999/xhtml">
                <p>This edition had all images removed.</p>
                <p> Title: A Modest Proposal<br />For preventing the children of poor people in Ireland,
                  from being a burden on their parents or country, and for making them beneficial to the
                  publick </p>
                <p>Author: Swift, Jonathan, 1667-1745</p>
                <p>EBook No.: 1080</p>
                <p>Published: Oct 1, 1997</p>
                <p>Downloads: 23937</p>
                <p>Language: English</p>
                <p>Subject: Political satire, English</p>
                <p>Subject: Religious satire, English</p>
                <p>Subject: Ireland -- Politics and government -- 18th century -- Humor</p>
                <p>LoCC: Language and Literatures: English literature</p>
                <p>Category: Text</p>
                <p>Rights: Public domain in the USA.</p>
              </div>
            </content>
            <id>urn:gutenberg:1080:2</id>
            <published>1997-10-01T00:00:00+00:00</published>
            <rights>Public domain in the USA.</rights>
            <author>
              <name>Swift, Jonathan</name>
            </author>
            <category scheme="http://purl.org/dc/terms/LCSH" term="Political satire, English" />
            <category scheme="http://purl.org/dc/terms/LCSH" term="Religious satire, English" />
            <category scheme="http://purl.org/dc/terms/LCSH"
              term="Ireland -- Politics and government -- 18th century -- Humor" />
            <category scheme="http://purl.org/dc/terms/LCC" term="PR"
              label="Language and Literatures: English literature" />
            <category scheme="http://purl.org/dc/terms/DCMIType" term="Text" />
            <dcterms:language>en</dcterms:language>
            <relevance:score>1</relevance:score>
            <link type="application/epub+zip" rel="http://opds-spec.org/acquisition"
              title="EPUB (no images, older E-readers)" length="65187"
              href="https://www.gutenberg.org/ebooks/1080.epub.noimages" />
            <link type="application/x-mobipocket-ebook" rel="http://opds-spec.org/acquisition"
              title="Kindle (no images)" length="185888"
              href="https://www.gutenberg.org/ebooks/1080.kindle.noimages" />
            <link type="image/jpeg" rel="http://opds-spec.org/image"
              href="https://www.gutenberg.org/cache/epub/1080/pg1080.cover.medium.jpg" />
            <link type="image/jpeg" rel="http://opds-spec.org/image/thumbnail"
              href="https://www.gutenberg.org/cache/epub/1080/pg1080.cover.small.jpg" />
            <link type="application/atom+xml;profile=opds-catalog" rel="related"
              href="/ebooks/1080/also/.opds" title="Readers also downloaded…" />
            <link type="application/atom+xml;profile=opds-catalog" rel="related"
              href="/ebooks/author/326.opds" title="By Swift, Jonathan…" />
            <link type="application/atom+xml;profile=opds-catalog" rel="related"
              href="/ebooks/subject/1040.opds" title="On Political satire, English…" />
            <link type="application/atom+xml;profile=opds-catalog" rel="related"
              href="/ebooks/subject/4856.opds" title="On Religious satire, English…" />
            <link type="application/atom+xml;profile=opds-catalog" rel="related"
              href="/ebooks/subject/4857.opds"
              title="On Ireland -- Politics and government -- 18th century -- Humor…" />
          </entry>
        ''';

        final element = XmlDocument.parse(xml).rootElement;
        final entry = OPDSEntry.fromXML(element);

        expect(entry.id, 'urn:gutenberg:1080:2');
        expect(entry.updated, '2023-12-12T22:26:39Z');
        expect(entry.title, 'A Modest Proposal');
        expectNotNull(entry.htmlContent);
        expect(
          entry.htmlContent!
              .contains('<p>Author: Swift, Jonathan, 1667-1745</p>'),
          true,
        );

        expect(entry.summary, null);
        expect(entry.author, 'Swift, Jonathan');
        expectNotNull(entry.categories);
        expect(entry.categories!.length, 5);
        expectContains(entry.categories,
            literal: 'Language and Literatures: English literature');
        expectContains(entry.categories,
            literal:
                'Ireland -- Politics and government -- 18th century -- Humor');

        expect(entry.extent, null);
        expect(entry.format, null);
        expect(entry.textContent, null);

        expect(entry.links?.length, 9);
        expectContains(entry.links,
            matcher: (link) =>
                link.type == 'application/epub+zip' &&
                link.href ==
                    'https://www.gutenberg.org/ebooks/1080.epub.noimages');
      });
    });

    group('[Kavita]', () {
      test('understands a directory <entry>', () {
        const xml = '''
          <entry>
            <updated>2023-12-12T22:58:37</updated>
            <id>onDeck</id>
            <title>On Deck</title>
            <content type="text">Browse On Deck</content>
            <link rel="subsection" type="application/atom+xml;profile=opds-catalog;kind=navigation"
              href="/api/opds/my-api-key/on-deck" />
          </entry>
        ''';

        final element = XmlDocument.parse(xml).rootElement;
        final entry = OPDSEntry.fromXML(element);

        expect(entry.id, 'onDeck');
        expect(entry.updated, '2023-12-12T22:58:37');
        expect(entry.title, 'On Deck');
        expect(entry.textContent, 'Browse On Deck');

        expect(entry.summary, null);
        expect(entry.author, null);
        expect(entry.categories, null);
        expect(entry.extent, null);
        expect(entry.format, null);
        expect(entry.htmlContent, null);

        expect(entry.links?.length, 1);
        expectContains(entry.links,
            matcher: (link) =>
                link.type ==
                    'application/atom+xml;profile=opds-catalog;kind=navigation' &&
                link.href == '/api/opds/my-api-key/on-deck');
      });

      test('Understands a resource <entry>', () {
        const xml = '''
          <entry>
            <updated>2023-12-12T23:16:03</updated>
            <id>52</id>
            <title>Test Book #1</title>
            <summary>epub+zip - 8.08 MB</summary>
            <extent xmlns="http://purl.org/dc/terms/">8.08 MB</extent>
            <format xmlns="http://purl.org/dc/terms/format">Epub</format>
            <content type="text">application/epub+zip</content>
            <link rel="http://opds-spec.org/image" type="image/jpeg"
              href="/api/image/chapter-cover?chapterId=52&amp;apiKey=my-api-key" />
            <link rel="http://opds-spec.org/image/thumbnail" type="image/jpeg"
              href="/api/image/chapter-cover?chapterId=52&amp;apiKey=my-api-key" />
            <link rel="http://opds-spec.org/acquisition/open-access" type="application/epub+zip"
              href="/api/opds/my-api-key/series/52/volume/52/chapter/52/download/TEST_EPUB.epub"
              title="TEST_EPUB.epub" p5:count="48" xmlns:p5="http://vaemendis.net/opds-pse/ns" />
            <link rel="http://vaemendis.net/opds-pse/stream" type="image/jpeg"
              href="/api/opds/my-api-key/image?libraryId=3&amp;seriesId=52&amp;volumeId=52&amp;chapterId=52&amp;pageNumber={pageNumber}"
              p5:count="48" p5:lastReadDate="0001-01-01T00:00:00"
              xmlns:p5="http://vaemendis.net/opds-pse/ns" />
          </entry>
        ''';

        final element = XmlDocument.parse(xml).rootElement;
        final entry = OPDSEntry.fromXML(element);

        expect(entry.id, '52');
        expect(entry.updated, '2023-12-12T23:16:03');
        expect(entry.title, 'Test Book #1');
        expect(entry.textContent, 'application/epub+zip');

        expect(entry.summary, 'epub+zip - 8.08 MB');
        expect(entry.author, null);
        expect(entry.categories, null);

        expect(entry.extent, '8.08 MB');
        expect(entry.format, 'Epub');
        expect(entry.htmlContent, null);

        expect(entry.links?.length, 4);
        expectContains(entry.links,
            matcher: (link) =>
                link.type == 'application/epub+zip' &&
                link.href ==
                    '/api/opds/my-api-key/series/52/volume/52/chapter/52/download/TEST_EPUB.epub');
      });
    });
  });
}
