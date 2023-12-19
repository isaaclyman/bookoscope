import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/endpoint.db.dart';
import 'package:bookoscope/db/initialize.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/events/event_handler.dart';
import 'package:bookoscope/format/crawl_manager.dart';
import 'package:bookoscope/navigation/nav_manager.dart';
import 'package:bookoscope/pages/page_search.dart';
import 'package:bookoscope/pages/page_sources.dart';
import 'package:bookoscope/search/full_entry.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/search/searchable_books.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BKRouterConfig {
  final GoRouter config;

  BKRouterConfig()
      : config = GoRouter(
          routes: [
            ShellRoute(
              builder: (context, state, child) => BKAppShell(
                routerState: state,
                child: child,
              ),
              routes: [
                GoRoute(
                  path: '/',
                  redirect: (context, state) => '/search',
                ),
                GoRoute(
                  path: '/search',
                  name: BKPageBrowse.name,
                  builder: (context, state) => BKPageShell(
                    routerState: state,
                    child: const BKPageBrowse(),
                  ),
                ),
                GoRoute(
                  path: '/sources',
                  name: BKPageSources.name,
                  builder: (context, state) => BKPageShell(
                    routerState: state,
                    child: const BKPageSources(),
                  ),
                ),
              ],
            )
          ],
        );
}

class BKAppShell extends StatelessWidget {
  final Widget child;
  final GoRouterState routerState;

  const BKAppShell({
    super.key,
    required this.routerState,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DBSources>(create: (_) => DBSources()),
        ChangeNotifierProvider<DBEndpoints>(create: (_) => DBEndpoints()),
        ChangeNotifierProvider<DBBooks>(create: (_) => DBBooks()),
        ChangeNotifierProxyProvider2<DBSources, DBBooks, BKSearchManager?>(
          create: (_) => null,
          update: (_, dbSources, dbBooks, __) => BKSearchManager(
            BKHasSearchableSources(
              sources: dbSources.sources,
              books: dbBooks.books,
            ),
          ),
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
          update: (_, dbSources, crawlManager, __) => DBInitialize(
            dbSources: dbSources,
            crawlManager: crawlManager,
          ),
          lazy: false,
        )
      ],
      child: Scaffold(
        bottomNavigationBar: _Navbar(currentRouteName: routerState.name),
        endDrawer: Consumer<BKSearchManager>(
          builder: (_, searchManager, __) => Drawer(
            child: searchManager.selectedResult != null
                ? SafeArea(
                    child: CFullEntry(
                      result: searchManager.selectedResult!,
                    ),
                  )
                : null,
          ),
        ),
        body: child,
      ),
    );
  }
}

class _Navbar extends StatefulWidget {
  final String? currentRouteName;

  const _Navbar({required this.currentRouteName});

  @override
  State<_Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<_Navbar> {
  final List<VoidCallback> onDispose = [];

  final List<(NavigationDestination, String)> _navItemRoutes = [
    (
      const NavigationDestination(
        icon: Icon(Icons.shelves),
        label: "Browse",
      ),
      BKPageBrowse.name
    ),
    (
      const NavigationDestination(
        icon: Icon(Icons.device_hub),
        label: "Sources",
      ),
      BKPageSources.name
    ),
  ];

  @override
  void initState() {
    super.initState();
    final navManager = context.read<CNavManager>();
    navManager.addListener(_onRouteChange);
    onDispose.add(() {
      navManager.removeListener(_onRouteChange);
    });
  }

  @override
  void dispose() {
    for (var callback in onDispose) {
      callback();
    }

    super.dispose();
  }

  _onRouteChange() {
    if (mounted) {
      final routeName = context.read<CNavManager>().selectedRoute;
      final nextIx =
          _navItemRoutes.indexWhere((route) => route.$2 == routeName);
      setState(() {
        selectedIndex = nextIx > -1 ? nextIx : 0;
      });
    }
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (ix) => setState(() {
        selectedIndex = ix;
        context.goNamed(_navItemRoutes[ix].$2);
      }),
      destinations: _navItemRoutes.map((r) => r.$1).toList(),
    );
  }
}

class BKPageShell extends StatelessWidget {
  final Widget child;
  final GoRouterState routerState;

  const BKPageShell({
    super.key,
    required this.child,
    required this.routerState,
  });

  @override
  Widget build(BuildContext context) {
    final navManager = Provider.of<CNavManager>(context, listen: false);
    Future.microtask(() => navManager.notifyRoute(routerState.name));

    final handler = Provider.of<BKEventHandler>(context, listen: false);
    final params = routerState.uri.queryParameters;

    final query = params["query"];
    if (query != null) {
      handler.setSearchQuery(context, query);
    }

    final categoryName = params["category"];
    final itemName = params["item"];
    if (itemName != null) {
      Future.microtask(
          () => handler.goToResult(context, categoryName, itemName));
    } else if (context.mounted) {
      Scaffold.of(context).closeEndDrawer();
    }

    return SizedBox.expand(
      child: SafeArea(child: child),
    );
  }
}
