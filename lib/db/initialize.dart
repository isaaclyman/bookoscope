import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/crawl_manager.dart';
import 'package:collection/collection.dart';

class DBInitialize {
  bool isInitializing = false;

  void initializeGutenberg(
    DBSources dbSources,
    BKCrawlManager crawlManager,
  ) async {
    if (isInitializing) {
      return;
    }

    isInitializing = true;
    await dbSources.sourcesFuture.then((sources) async {
      final gutenbergSource = sources.firstWhereOrNull(
          (s) => s.url == bkFakeGutenbergUrl && s.isCompletelyCrawled);
      if (gutenbergSource == null) {
        await crawlManager.parseGutenbergCatalog();
      }
      isInitializing = false;
    });
  }
}
