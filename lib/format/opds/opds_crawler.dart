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
    } catch (e) {
      yield OPDSCrawlException(
        exception: e,
        uri: uri.toString(),
      );
      return;
    }

    final links = feed.links ?? [];
    for (final link in links
        .where((link) => OPDSLinkClassifier.isCrawlable(link.rel, link.type))) {
      await for (final event in _extractRecursive(link.href)) {
        yield event;
      }
    }

    final entries = feed.entries ?? [];
    for (final entry in entries.whereNot(OPDSEntryClassifier.isLeafResource)) {
      final entryLinks = entry.links ?? [];
      for (final link in entryLinks.where(
          (link) => OPDSLinkClassifier.isCrawlable(link.rel, link.type))) {
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
          originalId: entry.id,
          title: entry.title ?? 'Title Not Found',
          authors: entry.authors ?? [],
          format: entry.format,
          categories: entry.categories,
          metadata: {
            if (entry.textContent != null) "Text": entry.textContent ?? "",
            if (entry.htmlContent != null) "HTML": entry.htmlContent ?? "",
            if (entry.summary != null) "Summary": entry.summary ?? "",
            if (entry.published != null || entry.updated.isNotEmpty)
              "Date": entry.published ?? entry.updated,
            if (entry.extent != null) "Size": entry.extent ?? "",
          },
          downloadUrls: links
              .map(
                (link) => OPDSCrawlResourceUrl(
                  label: link.title,
                  uri: link.href,
                  rel: link.rel,
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

const _knownMimeTypeLabels = <String, String>{
  "application/epub": "EPUB",
  "application/epub+zip": "EPUB",
  "application/x-mobipocket-ebook": "MOBI",
  "application/pdf": "PDF",
};

class OPDSLinkClassifier {
  static const String _relSelf = 'self';
  static const String _relImageRoot = '//opds-spec.org/image';
  static const String _relThumbnail = '//opds-spec.org/image/thumbnail';
  static const String _relAcquisitionRoot = '//opds-spec.org/acquisition';

  static bool isSelf(String rel) {
    return rel == _relSelf;
  }

  static bool isImage(String rel, String? type) {
    return rel.contains(_relImageRoot) ||
        (type != null && type.startsWith('image/'));
  }

  static bool isAcquisition(String rel) {
    return rel.contains(_relAcquisitionRoot);
  }

  static bool isCrawlable(String rel, String? type) {
    return !isSelf(rel) && !isImage(rel, type) && !isAcquisition(rel);
  }

  static String getDisplayType(String type) {
    if (_knownMimeTypeLabels.containsKey(type)) {
      return _knownMimeTypeLabels[type]!;
    }

    var lastPart = type.split("/").last;
    if (lastPart.startsWith("x-")) {
      lastPart = lastPart.substring(2);
    }

    return lastPart.toUpperCase();
  }

  static String getDisplayLabel(
    String? label,
    String? rel,
    String? type, {
    bool includeType = true,
  }) {
    final displayType =
        type == null ? null : OPDSLinkClassifier.getDisplayType(type);
    if (label != null) {
      return includeType && displayType != null
          ? "$label ($displayType)"
          : label;
    }

    if (rel != null && rel.contains("$_relAcquisitionRoot/")) {
      var acquisitionType = rel.split("$_relAcquisitionRoot/").last;
      acquisitionType = acquisitionType.trim().replaceAll("/", "");

      if (acquisitionType.isNotEmpty && acquisitionType != 'open-access') {
        acquisitionType = acquisitionType.replaceAll("-", " ");
        acquisitionType =
            acquisitionType[0].toUpperCase() + acquisitionType.substring(1);
        return acquisitionType;
      }
    }

    return displayType ?? "Unknown Type";
  }

  static String? getPreferredImageUrl(List<OPDSLink> links) {
    final image =
        links.firstWhereOrNull((link) => link.rel.contains(_relImageRoot));
    if (image != null) {
      return image.href;
    }

    final thumbnail =
        links.firstWhereOrNull((link) => link.rel.contains(_relThumbnail));
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
    if (links != null &&
        links.any((link) => OPDSLinkClassifier.isAcquisition(link.rel))) {
      return true;
    }

    return false;
  }
}
