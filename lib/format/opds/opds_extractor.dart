import 'dart:convert';
import 'dart:io';

import 'package:bookoscope/format/opds/opds_xml.dart';
import 'package:bookoscope/util/xml.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

/// Uses [client] to extract [OPDSFeed]s from [Uri]s.
class OPDSExtractor {
  final HttpClient client;

  const OPDSExtractor({
    required this.client,
  });

  /// Extracts an [OPDSFeed] from a [Uri]. Uses a [Stream] internally
  /// to conserve memory.
  /// The returned [OPDSFeed] represents the entire known hierarchy
  /// of the feed, including any [OPDSLink]s, [OPDSEntry]s, and
  /// [OPDSLink]s within [OPDSEntry]s.
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
      (node) => links.add(OPDSLink.fromXML(node)),
    );

    final entries = <OPDSEntry>[];
    final entries$ = xmlStream.listenForNode(
      'feed',
      'entry',
      (node) => entries.add(OPDSEntry.fromXML(node)),
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
