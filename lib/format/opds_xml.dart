import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bookoscope/util/xml.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

class OPDSFeed {
  final String id;
  final String url;
  final String updated;
  final String? title;
  final List<OPDSLink>? links;
  final List<OPDSEntry>? entries;

  const OPDSFeed({
    required this.id,
    required this.url,
    required this.updated,
    required this.title,
    required this.links,
    required this.entries,
  });

  @override
  String toString() {
    return <String, String>{
      '\$type': 'OPDSFeed',
      'id': id,
      'updated': updated,
      'title': title ?? 'NULL',
      'links': links?.map((l) => l.toString()).join('\n') ?? 'NULL',
      'entries': entries?.map((e) => e.toString()).join('\n') ?? 'NULL',
    }.toString();
  }
}

class OPDSEntry {
  final String id;
  final String updated;
  final String? title;
  final String? author;
  final String? summary;
  final String? extent;
  final String? format;
  final List<String>? categories;
  final List<OPDSLink>? links;

  final String? htmlContent;
  final String? textContent;

  const OPDSEntry({
    required this.updated,
    required this.id,
    required this.title,
    required this.author,
    required this.summary,
    required this.extent,
    required this.format,
    required this.categories,
    required this.links,
    required this.htmlContent,
    required this.textContent,
  });

  @override
  String toString() {
    return <String, String>{
      '\$type': 'OPDSEntry',
      'id': id,
      'updated': updated,
      'title': title ?? 'NULL',
      'summary': summary ?? 'NULL',
      'extent': extent ?? 'NULL',
      'format': format ?? 'NULL',
      'links': links?.map((l) => l.toString()).join('\n') ?? 'NULL',
    }.toString();
  }
}

class OPDSLink {
  final String rel;
  final String href;
  final String? type;
  final String? title;

  OPDSLink({
    required String rel,
    required this.href,
    required this.type,
    required this.title,
  }) : rel = rel.toLowerCase();

  @override
  String toString() {
    return <String, String>{
      '\$type': 'OPDSLink',
      'rel': rel,
      'href': href,
      'type': type ?? 'NULL',
      'title': title ?? 'NULL',
    }.toString();
  }
}

class OPDSExtractor {
  final String rootUri;
  HttpClient client;

  OPDSExtractor({
    required this.rootUri,
  }) : client = HttpClient();

  Future<OPDSFeed> getFeed(Uri uri) async {
    final xmlStream = await _fetchXmlEvents(uri);

    String id = '';
    final id$ = xmlStream.listenForNode(
      'feed',
      'id',
      (node) => id = node.innerText,
    );

    String updated = '';
    final updated$ = xmlStream.listenForNode(
      'feed',
      'updated',
      (node) => updated = node.innerText,
    );

    String? title;
    final title$ = xmlStream.listenForNode(
      'feed',
      'title',
      (node) => title = node.innerText,
    );

    final links = <OPDSLink>[];
    final links$ = xmlStream.listenForNode(
      'feed',
      'link',
      (node) {
        final link = OPDSLink(
          rel: node.getAttribute('rel') ?? '',
          href: node.getAttribute('href') ?? '',
          type: node.getAttribute('type'),
          title: node.getAttribute('title'),
        );
        links.add(link);
      },
    );

    final entries = <OPDSEntry>[];
    final entries$ = xmlStream.listenForNode(
      'feed',
      'entry',
      (node) {
        final links = node.childElements
            .where(
              (node) => node.localName == 'link',
            )
            .map(
              (node) => OPDSLink(
                rel: node.getAttribute('rel') ?? '',
                href: node.getAttribute('href') ?? '',
                type: node.getAttribute('type'),
                title: node.getAttribute('title'),
              ),
            );

        final entry = OPDSEntry(
          id: node.getChildNodeText('id') ?? '',
          updated: node.getChildNodeText('updated') ?? '',
          title: node.getChildNodeText('title'),
          author: node.getPossiblyNestedChildNodeText('author', 'name'),
          summary: node.getChildNodeText('summary'),
          extent: node.getChildNodeText('extent'),
          format: node.getChildNodeText('format'),
          categories: node.getChildrenNodesText('category'),
          htmlContent: node.getMatchingChildNodeText(
            'content',
            (element) =>
                element.getAttribute('type')?.toLowerCase().contains('html') ??
                false,
          ),
          textContent: node.getMatchingChildNodeText(
            'content',
            (element) =>
                element.getAttribute('type')?.toLowerCase().contains('text') ??
                true,
          ),
          links: links.toList(),
        );

        entries.add(entry);
      },
    );

    await Future.wait([id$, updated$, title$, links$, entries$]);
    return OPDSFeed(
      id: id,
      url: uri.toString(),
      updated: updated,
      title: title,
      links: links,
      entries: entries,
    );
  }

  Future<Stream<List<XmlEvent>>> _fetchXmlEvents(Uri uri) async {
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Request to [$uri] returned [${response.statusCode}].');
    }

    return response
        .transform(utf8.decoder)
        .toXmlEvents()
        .normalizeEvents()
        .withParentEvents();
  }
}
