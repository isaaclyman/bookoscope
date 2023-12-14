import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bookoscope/util/xml.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

class OPDSFeed {
  String id;
  String updated;
  String? title;
  Map<String, OPDSLink>? links;
  List<OPDSEntry>? entries;

  OPDSFeed({
    required this.id,
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
      'links': links?.values.map((l) => l.toString()).join('\n') ?? 'NULL',
      'entries': entries?.map((e) => e.toString()).join('\n') ?? 'NULL',
    }.toString();
  }
}

class OPDSEntry {
  String id;
  String updated;
  String? title;
  String? summary;
  String? extent;
  String? format;
  Map<String, OPDSLink>? links;

  OPDSEntry({
    required this.updated,
    required this.id,
    required this.title,
    required this.summary,
    required this.extent,
    required this.format,
    required this.links,
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
      'links': links?.values.map((l) => l.toString()).join('\n') ?? 'NULL',
    }.toString();
  }
}

class OPDSLink {
  String rel;
  String href;
  String? type;
  String? title;

  OPDSLink({
    required this.rel,
    required this.href,
    required this.type,
    required this.title,
  });

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

  Future<OPDSFeed> getFeed(String uri) async {
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

    final links = <String, OPDSLink>{};
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
        links[link.rel] = link;
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

        entries.add(
          OPDSEntry(
            id: node.getChildNodeText('id') ?? '',
            updated: node.getChildNodeText('updated') ?? '',
            title: node.getChildNodeText('title'),
            summary: node.getChildNodeText('summary'),
            extent: node.getChildNodeText('extent'),
            format: node.getChildNodeText('format'),
            links: {for (final link in links) link.rel: link},
          ),
        );
      },
    );

    await Future.wait([id$, updated$, title$, links$, entries$]);
    return OPDSFeed(
      id: id,
      updated: updated,
      title: title,
      links: links,
      entries: entries,
    );
  }

  Future<Stream<List<XmlEvent>>> _fetchXmlEvents(String uri) async {
    final request = await client.getUrl(Uri.parse(uri));
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
