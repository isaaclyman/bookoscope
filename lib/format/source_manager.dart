import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/endpoint.db.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/opds/opds_crawler.dart';
import 'package:bookoscope/format/opds/opds_events.dart';
import 'package:flutter/foundation.dart';

class BKCrawlManager extends ChangeNotifier {
  final DBSources dbSources;
  final DBEndpoints dbEndpoints;
  final DBBooks dbBooks;

  BKCrawlManager({
    required this.dbSources,
    required this.dbEndpoints,
    required this.dbBooks,
  });

  Stream<OPDSCrawlEvent> crawlOpdsUri(Source source) async* {
    final crawler = OPDSCrawler(opdsRootUri: source.url);
    dbSources.upsert(source);

    await for (final event in crawler.crawlFromRoot()) {
      if (event is OPDSCrawlBegin) {
        dbEndpoints.upsert(Endpoint(
          url: event.uri,
          isCrawled: false,
          sourceId: source.id,
        ));
      }

      if (event is OPDSCrawlSuccess) {
        dbEndpoints.upsert(Endpoint(
          url: event.uri,
          isCrawled: true,
          sourceId: source.id,
        ));
      }

      if (event is OPDSCrawlException) {
        dbEndpoints.upsert(Endpoint(
          url: event.uri,
          isCrawled: true,
          sourceId: source.id,
          exceptionMessage: event.exception.toString(),
        ));
      }

      if (event is OPDSCrawlResourceFound) {
        dbBooks.upsert(Book(
          originalId: event.resource.originalId,
          sourceId: source.id,
          title: event.resource.title,
          author: event.resource.author,
          tags: event.resource.tags,
          downloadUrls: event.resource.downloadUrls
              .map((resourceUri) => BookDownloadUrl(
                    label: resourceUri.label,
                    type: resourceUri.type,
                    uri: resourceUri.uri,
                  ))
              .toList(),
          imageUrl: event.resource.imageUrl,
        ));
      }

      yield event;
    }

    source.isCompletelyCrawled = true;
    dbSources.upsert(source);
  }
}
