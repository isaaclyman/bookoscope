import 'package:bookoscope/format/opds/opds_crawler.dart';
import 'package:bookoscope/format/opds/opds_extractor.dart';
import 'package:bookoscope/format/opds/opds_resource.dart';

Future<List<OPDSCrawlResourceUrl>> getGutenbergResourceUris(
  String originalId,
) async {
  final extractor = OPDSExtractor();
  final bookUrl = _getOpdsUrl(originalId);
  final feed = await extractor.getFeed(Uri.parse(bookUrl));
  final entries = feed.entries;
  if (entries == null || entries.isEmpty) {
    return [];
  }

  final acquisitionUris = <OPDSCrawlResourceUrl>[];
  for (final entry in entries) {
    final links = entry.links;
    if (links == null || links.isEmpty) {
      continue;
    }

    for (final link in links.where(
      (link) => OPDSLinkClassifier.isAcquisition(link.rel),
    )) {
      acquisitionUris.add(OPDSCrawlResourceUrl(
        label: link.title ?? 'Download',
        uri: link.href,
        rel: link.rel,
        type: link.type,
      ));
    }
  }

  return acquisitionUris;
}

String _getOpdsUrl(String textId) {
  return 'https://www.gutenberg.org/ebooks/$textId.opds';
}
