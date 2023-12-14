import 'package:bookoscope/format/opds/opds_resource.dart';
import 'package:bookoscope/format/opds/opds_crawler.dart';

/// Abstract base class for all events emitted by [OPDSCrawler.crawlFromRoot].
abstract class OPDSCrawlEvent {
  const OPDSCrawlEvent();
}

/// Indicates that a crawl of [uri] is about to begin.
class OPDSCrawlBegin extends OPDSCrawlEvent {
  final String uri;

  const OPDSCrawlBegin({
    required this.uri,
  });
}

/// Indicates that [uri] was successfully crawled.
/// Any found resources have been emitted as [OPDSCrawlResourceFound] events.
class OPDSCrawlSuccess extends OPDSCrawlEvent {
  final String uri;

  const OPDSCrawlSuccess({
    required this.uri,
  });
}

/// Indicates that [uri] could not be crawled due to [exception].
class OPDSCrawlException extends OPDSCrawlEvent {
  final Exception exception;
  final String uri;

  const OPDSCrawlException({
    required this.exception,
    required this.uri,
  });
}

/// Indicates that a [resource] (e.g. an ebook) was found somewhere in the
/// XML response from [uri].
class OPDSCrawlResourceFound extends OPDSCrawlEvent {
  final OPDSCrawlResource resource;
  final String uri;

  const OPDSCrawlResourceFound({
    required this.resource,
    required this.uri,
  });
}
