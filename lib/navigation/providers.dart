import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/dated_title.db.dart';
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
        ChangeNotifierProvider<DBDatedTitles>(create: (_) => DBDatedTitles()),
        ChangeNotifierProxyProvider3<DBSources, DBBooks, DBDatedTitles,
            BKSearchManager?>(
          create: (_) => BKSearchManager(),
          update: (_, dbSources, dbBooks, dbDatedTitles, searchManager) {
            searchManager?.refreshSources(dbSources, dbBooks, dbDatedTitles);
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
        ProxyProvider4<DBSources, DBEndpoints, DBBooks, DBDatedTitles,
            BKCrawlManager>(
          update: (_, dbSources, dbEndpoints, dbBooks, dbDatedTitles, __) =>
              BKCrawlManager(
            dbSources: dbSources,
            dbEndpoints: dbEndpoints,
            dbBooks: dbBooks,
            dbDatedTitles: dbDatedTitles,
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
