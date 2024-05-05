import 'dart:convert';
import 'dart:io';

import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/opds/opds_xml.dart';
import 'package:bookoscope/util/authenticate.dart';
import 'package:collection/collection.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

/// Uses [client] to extract [OPDSFeed]s from [Uri]s.
class OPDSExtractor {
  HttpClient client = HttpClient();
  Source? source;
  String? authHeader;

  void useAuth(Source source) {
    this.source = source;
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

  Future<Stream<List<XmlEvent>>> _fetchXmlEvents(Uri uri,
      {int retries = 0}) async {
    final request = await client.getUrl(uri);
    if (authHeader?.isNotEmpty ?? false) {
      request.headers.set('authorization', authHeader ?? "");
    }

    final response = await request.close();
    if (response.statusCode == HttpStatus.unauthorized && retries < 3) {
      final authenticateHeader = response.headers['www-authenticate'];
      if (authenticateHeader != null && authenticateHeader.isNotEmpty) {
        await attemptAuthentication(uri, authenticateHeader);
        return _fetchXmlEvents(uri, retries: retries + 1);
      }
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw Exception('Request to [$uri] returned [${response.statusCode}]. '
          'Please check your credentials.');
    }

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Request to [$uri] returned [${response.statusCode}].');
    }

    return response
        .transform(utf8.decoder)
        .toXmlEvents()
        .normalizeEvents()
        .withParentEvents();
  }

  Future<void> attemptAuthentication(
    Uri uri,
    List<String> authenticateHeaders,
  ) async {
    final options =
        authenticateHeaders.map((header) => parseAuthenticateHeader(header));

    if (options.any((option) => option.scheme == 'basic')) {
      authHeader = source?.getBasicAuthHeader();
      return;
    }

    final digestOption =
        options.firstWhereOrNull((option) => option.scheme == 'digest');
    if (digestOption != null) {
      client.addCredentials(
        uri,
        digestOption.realm ?? "",
        HttpClientDigestCredentials(
          source?.username ?? "",
          source?.password ?? "",
        ),
      );
      return;
    }

    throw Exception(
      "None of these authorization schemes are supported: [${options.map((option) => option.scheme).join(', ')}].",
    );
  }
}
