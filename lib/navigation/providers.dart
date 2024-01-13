import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/endpoint.db.dart';
import 'package:bookoscope/db/initialize.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/events/event_handler.dart';
import 'package:bookoscope/format/crawl_manager.dart';
import 'package:bookoscope/navigation/nav_manager.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BKProviders extends StatelessWidget {
  final Widget child;

  const BKProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DBSources>(create: (_) => DBSources()),
        ChangeNotifierProvider<DBEndpoints>(create: (_) => DBEndpoints()),
        ChangeNotifierProvider<DBBooks>(create: (_) => DBBooks()),
        ChangeNotifierProxyProvider2<DBSources, DBBooks, BKSearchManager?>(
          create: (_) => BKSearchManager(),
          update: (_, dbSources, dbBooks, searchManager) {
            searchManager?.refreshSources(dbSources, dbBooks);
            return searchManager;
          },
        ),
        ProxyProvider<BKSearchManager, BKEventHandler>(
          update: (_, searchManager, __) => BKEventHandler(
            searchManager: searchManager,
          ),
        ),
        ChangeNotifierProvider<CNavManager>(
          create: (_) => CNavManager(),
        ),
        ProxyProvider3<DBSources, DBEndpoints, DBBooks, BKCrawlManager>(
          update: (_, dbSources, dbEndpoints, dbBooks, __) => BKCrawlManager(
            dbSources: dbSources,
            dbEndpoints: dbEndpoints,
            dbBooks: dbBooks,
          ),
        ),
        ProxyProvider2<DBSources, BKCrawlManager, DBInitialize>(
          create: (_) => DBInitialize(),
          update: (_, dbSources, crawlManager, dbInit) {
            dbInit ??= DBInitialize();
            dbInit.initializeGutenberg(dbSources, crawlManager);
            return dbInit;
          },
          lazy: false,
        )
      ],
      child: child,
    );
  }
}
