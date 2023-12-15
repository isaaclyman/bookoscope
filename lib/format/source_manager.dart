import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/endpoint.db.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/guten/guten_extractor.dart';
import 'package:bookoscope/format/opds/opds_crawler.dart';
import 'package:bookoscope/format/opds/opds_events.dart';
import 'package:flutter/material.dart';

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
    await dbSources.upsert(source);

    await for (final event in crawler.crawlFromRoot()) {
      if (event is OPDSCrawlBegin) {
        await dbEndpoints.upsert(Endpoint(
          url: event.uri,
          isCrawled: false,
          sourceId: source.id,
        ));
      }

      if (event is OPDSCrawlSuccess) {
        await dbEndpoints.upsert(Endpoint(
          url: event.uri,
          isCrawled: true,
          sourceId: source.id,
        ));
      }

      if (event is OPDSCrawlException) {
        await dbEndpoints.upsert(Endpoint(
          url: event.uri,
          isCrawled: true,
          sourceId: source.id,
          exceptionMessage: event.exception.toString(),
        ));
      }

      if (event is OPDSCrawlResourceFound) {
        await dbBooks.upsert(Book(
          originalId: event.resource.originalId,
          sourceId: source.id,
          title: event.resource.title,
          authors: event.resource.authors,
          tags: event.resource.tags,
          downloadUrls: event.resource.downloadUrls
              .map((resourceUri) => BookDownloadUrl(
                    label: resourceUri.label,
                    type: resourceUri.type,
                    uri: resourceUri.uri,
                  ))
              .toList(),
          imageUrl: event.resource.imageUrl,
          isGutenberg: false,
        ));
      }

      yield event;
    }

    source.isCompletelyCrawled = true;
    await dbSources.upsert(source);
  }

  Future<void> parseGutenbergCatalog() async {
    final extractor = GCSVExtractor();
    final source = Source(
      label: 'Project Gutenberg',
      url: 'file:pg_catalog.csv',
      username: null,
      password: null,
    );
    await dbSources.upsert(source);

    await for (final row in extractor.getRows()) {
      if (row.title == 'No title') {
        continue;
      }

      await dbBooks.upsert(Book(
        originalId: row.id.toString(),
        sourceId: source.id,
        title: row.title,
        authors: row.authors ?? [],
        tags: (row.subjects ?? []).followedBy(row.bookshelves ?? []).toList(),
        downloadUrls: null,
        imageUrl: null,
        isGutenberg: true,
      ));
    }

    source.isCompletelyCrawled = true;
    await dbSources.upsert(source);
  }
}
