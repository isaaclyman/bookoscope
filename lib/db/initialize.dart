import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/crawl_manager.dart';

class DBInitialize {
  final DBSources dbSources;
  final BKCrawlManager crawlManager;

  DBInitialize({
    required this.dbSources,
    required this.crawlManager,
  }) {
    _initializeGutenberg();
  }

  void _initializeGutenberg() async {
    await dbSources.sourcesFuture.then((sources) async {
      if (sources.isEmpty || !sources.any((s) => s.url == bkFakeGutenbergUrl)) {
        await crawlManager.parseGutenbergCatalog();
      }
    });
  }
}
