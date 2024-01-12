import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/crawl_manager.dart';

class DBInitialize {
  bool isInitialized = false;

  void initializeGutenberg(
    DBSources dbSources,
    BKCrawlManager crawlManager,
  ) async {
    await dbSources.sourcesFuture.then((sources) async {
      if (sources.isEmpty || !sources.any((s) => s.url == bkFakeGutenbergUrl)) {
        await crawlManager.parseGutenbergCatalog();
      }
    });
    isInitialized = true;
  }
}
