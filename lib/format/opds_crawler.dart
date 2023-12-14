import 'package:bookoscope/format/opds_xml.dart';
import 'package:collection/collection.dart';

class OPDSCrawler {
  final String opdsRoot;
  final Set<String> visitedEndpoints = {};
  final Set<String> foundResourceIds = {};
  OPDSExtractor extractor;

  OPDSCrawler({
    required this.opdsRoot,
  }) : extractor = OPDSExtractor(rootUri: opdsRoot);

  Stream<OPDSCrawlEvent> crawlFromRoot() {
    return _extractRecursive(opdsRoot);
  }

  Stream<OPDSCrawlEvent> _extractRecursive(String uriString) async* {
    if (visitedEndpoints.contains(uriString)) {
      return;
    }

    final uri = Uri.parse(uriString);
    visitedEndpoints.add(uri.toString());
    yield OPDSCrawlBegin(uri: uri.toString());

    final OPDSFeed feed;
    try {
      feed = await extractor.getFeed(uri);
      yield OPDSCrawlSuccess(crawledUri: uri.toString());
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

class OPDSCrawlResource {
  final String title;
  final String author;
  final List<String> tags;
  final List<OPDSCrawlResourceUrl> downloadUrls;
  final String? imageUrl;
  final String? htmlDescription;
  final String? textDescription;

  const OPDSCrawlResource({
    required this.title,
    required this.author,
    required this.tags,
    required this.downloadUrls,
    required this.imageUrl,
    required this.htmlDescription,
    required this.textDescription,
  });
}

class OPDSCrawlResourceUrl {
  final String label;
  final String uri;
  final String? type;

  const OPDSCrawlResourceUrl({
    required this.label,
    required this.uri,
    required this.type,
  });
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
    return [_relImage, _relThumbnail].contains(link.rel);
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
    return thumbnail?.href;
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

//
// EVENTS
//

abstract class OPDSCrawlEvent {
  const OPDSCrawlEvent();
}

class OPDSCrawlBegin extends OPDSCrawlEvent {
  final String uri;

  const OPDSCrawlBegin({
    required this.uri,
  });
}

class OPDSCrawlSuccess extends OPDSCrawlEvent {
  final String crawledUri;

  const OPDSCrawlSuccess({
    required this.crawledUri,
  });
}

class OPDSCrawlException extends OPDSCrawlEvent {
  final Exception exception;
  final String uri;

  const OPDSCrawlException({
    required this.exception,
    required this.uri,
  });
}

class OPDSCrawlResourceFound extends OPDSCrawlEvent {
  final OPDSCrawlResource resource;
  final String uri;

  const OPDSCrawlResourceFound({
    required this.resource,
    required this.uri,
  });
}
