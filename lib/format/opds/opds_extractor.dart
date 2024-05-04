import 'dart:convert';
import 'dart:io';

import 'package:bookoscope/format/opds/opds_xml.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

/// Uses [client] to extract [OPDSFeed]s from [Uri]s.
class OPDSExtractor {
  HttpClient client = HttpClient();
  String? username;
  String? password;

  void useBasicAuth(String? username, String? password) {
    this.username = username;
    this.password = password;
  }

  /// Extracts an [OPDSFeed] from a [Uri]. Uses a [Stream] internally
  /// to conserve memory.
  /// The returned [OPDSFeed] represents the entire known hierarchy
  /// of the feed, including any [OPDSLink]s, [OPDSEntry]s, and
  /// [OPDSLink]s within [OPDSEntry]s.
  Future<OPDSFeed> getFeed(Uri uri) async {
    final xmlStream = await _fetchXmlEvents(uri);
    final feedSubElements = xmlStream
        .selectSubtreeEvents((event) => event.parent?.name == 'feed')
        .toXmlNodes()
        .expand((nodes) => nodes)
        .where((node) => node is XmlElement)
        .map((node) => node as XmlElement);

    String id = '';
    String updated = '';
    String? title;
    final links = <OPDSLink>[];
    final entries = <OPDSEntry>[];

    await for (final node in feedSubElements) {
      switch (node.name.local) {
        case "id":
          id = node.innerText;
          break;
        case "updated":
          updated = node.innerText;
          break;
        case "title":
          title = node.innerText;
          break;
        case "link":
          links.add(OPDSLink.fromXML(node));
          break;
        case "entry":
          entries.add(OPDSEntry.fromXML(node));
          break;
      }
    }

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

    if (username != null && password != null) {
      final basicAuth =
          "Basic ${base64.encode(utf8.encode('$username:$password'))}";
      request.headers.set("authorization", basicAuth);
    }

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
