import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/endpoint.db.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/guten/guten_extractor.dart';
import 'package:bookoscope/format/opds/opds_crawler.dart';
import 'package:bookoscope/format/opds/opds_events.dart';

const String bkFakeGutenbergUrl = 'file:pg_catalog.csv';

class BKCrawlManager {
  DBSources dbSources;
  DBEndpoints dbEndpoints;
  DBBooks dbBooks;

  BKCrawlManager({
    required this.dbSources,
    required this.dbEndpoints,
    required this.dbBooks,
  });

  Future<void> forceCleanSource(Source source) async {
    await dbEndpoints.deleteAllBySourceId(source.id);
    await dbBooks.deleteAllBySourceId(source.id);
  }

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
          format: event.resource.format,
          categories: event.resource.categories ?? [],
          metadata: event.resource.metadata.entries
              .map((kvp) => BookMetadata(
                    type: kvp.key,
                    content: kvp.value,
                  ))
              .toList(),
          downloadUrls: event.resource.downloadUrls
              .map((resourceUri) => BookDownloadUrl(
                    label: resourceUri.label,
                    type: resourceUri.type,
                    rel: resourceUri.rel,
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
      url: bkFakeGutenbergUrl,
      description: "70,000+ free and public domain ebooks",
      username: null,
      password: null,
      isEditable: false,
      isEnabled: true,
    );
    await dbSources.upsert(source);

    final rows = await extractor.getRows();
    final books =
        rows.where((row) => row.title != "No title").map((row) => Book(
              originalId: row.id.toString(),
              sourceId: source.id,
              title: row.title,
              authors: row.authors ?? [],
              format: null,
              categories: (row.subjects ?? [])
                  .followedBy(row.bookshelves ?? [])
                  .toList(),
              metadata: [
                BookMetadata(
                  type: "Date",
                  content: row.issued,
                ),
              ],
              downloadUrls: null,
              imageUrl: null,
              isGutenberg: true,
            ));
    await dbBooks.overwriteEntireSource(source.id, books.toList());

    source.isCompletelyCrawled = true;
    await dbSources.upsert(source);
  }
}
