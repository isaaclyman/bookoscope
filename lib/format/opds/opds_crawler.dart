import 'dart:io';

import 'package:bookoscope/format/opds/opds_events.dart';
import 'package:bookoscope/format/opds/opds_extractor.dart';
import 'package:bookoscope/format/opds/opds_resource.dart';
import 'package:bookoscope/format/opds/opds_xml.dart';
import 'package:bookoscope/util/uri.dart';
import 'package:collection/collection.dart';

/// Class for crawling an OPDS catalog starting from [opdsRootUri].
class OPDSCrawler {
  final String opdsRootUri;
  final Set<String> visitedEndpoints = {};
  final Set<String> foundResourceIds = {};
  final extractor = OPDSExtractor();

  OPDSCrawler({
    required this.opdsRootUri,
  });

  /// Recursively crawls the XML response from [opdsRootUri], then
  /// any endpoints indicated by a <link> element, then <link> elements
  /// inside of any <entry> elements that are determined not to be
  /// acquirable resources (leaf nodes / downloadable ebooks).
  ///
  /// The returned [Stream] (of type [OPDSCrawlEvent]) will emit when a URI
  /// is about to be crawled, when a resource (e.g. an ebook) is found, when
  /// an exception occurs (e.g. the URI is accessible or the response can't
  /// be parsed as XML), and when a document has been successfully parsed.
  Stream<OPDSCrawlEvent> crawlFromRoot() {
    return _extractRecursive(opdsRootUri);
  }

  Stream<OPDSCrawlEvent> _extractRecursive(String uriString) async* {
    final uri =
        uriString.startsWith('http://') || uriString.startsWith('https://')
            ? Uri.parse(uriString)
            : joinUri(opdsRootUri, uriString);

    if (visitedEndpoints.contains(uri.toString())) {
      return;
    }

    visitedEndpoints.add(uri.toString());
    yield OPDSCrawlBegin(uri: uri.toString());

    final OPDSFeed feed;
    try {
      feed = await extractor.getFeed(uri);
      yield OPDSCrawlSuccess(uri: uri.toString());
    } on Exception catch (e) {
      yield OPDSCrawlException(
        exception: e,
        uri: uri.toString(),
      );
      return;
    }

    final links = feed.links ?? [];
    for (final link in links.where(OPDSLinkClassifier.isCrawlable)) {
      await for (final event in _extractRecursive(link.href)) {
        yield event;
      }
    }

    final entries = feed.entries ?? [];
    for (final entry in entries.whereNot(OPDSEntryClassifier.isLeafResource)) {
      final entryLinks = entry.links ?? [];
      for (final link in entryLinks.where(OPDSLinkClassifier.isCrawlable)) {
        await for (final event in _extractRecursive(link.href)) {
          yield event;
        }
      }
    }

    for (final entry in entries.where(OPDSEntryClassifier.isLeafResource)) {
      if (foundResourceIds.contains(entry.id)) {
        continue;
      }

      foundResourceIds.add(entry.id);

      final links = entry.links ?? [];
      yield OPDSCrawlResourceFound(
        resource: OPDSCrawlResource(
          title: entry.title ?? 'Title Not Found',
          author: entry.author ?? '',
          tags: [
            if (entry.format != null) entry.format!,
            if (entry.categories != null) ...entry.categories!,
          ],
          downloadUrls: links
              .map(
                (link) => OPDSCrawlResourceUrl(
                  label: link.title ?? 'Download',
                  uri: link.href,
                  type: link.type,
                ),
              )
              .toList(),
          imageUrl: OPDSLinkClassifier.getPreferredImageUrl(links),
          htmlDescription: entry.htmlContent,
          textDescription: entry.textContent,
        ),
        uri: uri.toString(),
      );
    }
  }
}

//
// CLASSIFIERS
//

class OPDSLinkClassifier {
  static const String _relSelf = 'self';
  static const String _relImage = 'http://opds-spec.org/image';
  static const String _relThumbnail = 'http://opds-spec.org/image/thumbnail';
  static const String _relAcquisitionRoot = '//opds-spec.org/acquisition';

  static bool isSelf(OPDSLink link) {
    return link.rel == _relSelf;
  }

  static bool isImage(OPDSLink link) {
    final type = link.type;
    return [_relImage, _relThumbnail].contains(link.rel) ||
        (type != null && type.startsWith('image/'));
  }

  static bool isAcquisition(OPDSLink link) {
    return link.rel.contains(_relAcquisitionRoot);
  }

  static bool isCrawlable(OPDSLink link) {
    return !isSelf(link) && !isImage(link) && !isAcquisition(link);
  }

  static String? getPreferredImageUrl(List<OPDSLink> links) {
    final image = links.firstWhereOrNull((link) => link.rel == _relImage);
    if (image != null) {
      return image.href;
    }

    final thumbnail =
        links.firstWhereOrNull((link) => link.rel == _relThumbnail);
    if (thumbnail != null) {
      return thumbnail.href;
    }

    final otherImage = links
        .firstWhereOrNull((link) => link.type?.startsWith('image/') ?? false);
    return otherImage?.href;
  }
}

class OPDSEntryClassifier {
  static bool isLeafResource(OPDSEntry entry) {
    if (entry.extent != null || entry.format != null) {
      return true;
    }

    final links = entry.links;
    if (links != null && links.any(OPDSLinkClassifier.isAcquisition)) {
      return true;
    }

    return false;
  }
}
