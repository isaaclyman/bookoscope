import 'package:bookoscope/db/bookmark.db.dart';
import 'package:bookoscope/events/event_handler.dart';
import 'package:bookoscope/json_data/json_types.dart';
import 'package:bookoscope/navigation/nav_manager.dart';
import 'package:bookoscope/pages/page_about.dart';
import 'package:bookoscope/pages/page_bookmarks.dart';
import 'package:bookoscope/pages/page_browse.dart';
import 'package:bookoscope/pages/page_search.dart';
import 'package:bookoscope/search/full_entry.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CRouterConfig {
  final GoRouter config;
  final CJsonRoot dataRoot;

  CRouterConfig({required this.dataRoot})
      : config = GoRouter(
          routes: [
            ShellRoute(
              builder: (context, state, child) => CAppShell(
                dataRoot: dataRoot,
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
                  name: CPageSearch.name,
                  builder: (context, state) => CPageShell(
                    routerState: state,
                    child: const CPageSearch(),
                  ),
                ),
                GoRoute(
                  path: '/bookmarks',
                  name: CPageBookmarks.name,
                  builder: (context, state) => CPageShell(
                    routerState: state,
                    child: const CPageBookmarks(),
                  ),
                ),
                GoRoute(
                  path: '/browse',
                  name: CPageBrowse.name,
                  builder: (context, state) => CPageShell(
                    routerState: state,
                    child: const CPageBrowse(),
                  ),
                ),
                GoRoute(
                  path: '/about',
                  name: CPageAbout.name,
                  builder: (context, state) => CPageShell(
                    routerState: state,
                    child: const CPageAbout(),
                  ),
                )
              ],
            )
          ],
        );
}

class CAppShell extends StatelessWidget {
  final Widget child;
  final CJsonRoot dataRoot;
  final CSearchManager searchManager;
  final GoRouterState routerState;
  late final CEventHandler eventHandler;

  CAppShell({
    super.key,
    required this.dataRoot,
    required this.routerState,
    required this.child,
  }) : searchManager = CSearchManager(dataRoot) {
    eventHandler = CEventHandler(searchManager: searchManager);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CEventHandler>(
          create: (_) => eventHandler,
        ),
        ChangeNotifierProvider<CSearchManager>(
          create: (_) => searchManager,
        ),
        ChangeNotifierProvider<CBookmarkManager>(
          create: (_) => CBookmarkManager(),
        ),
        ChangeNotifierProvider<CNavManager>(
          create: (_) => CNavManager(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: _Navbar(currentRouteName: routerState.name),
        endDrawer: Consumer<CSearchManager>(
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
      const NavigationDestination(icon: Icon(Icons.search), label: "Search"),
      CPageSearch.name
    ),
    (
      const NavigationDestination(
          icon: Icon(Icons.bookmark), label: "Bookmarks"),
      CPageBookmarks.name
    ),
    (
      const NavigationDestination(icon: Icon(Icons.view_list), label: "Browse"),
      CPageBrowse.name
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

class CPageShell extends StatelessWidget {
  final Widget child;
  final GoRouterState routerState;

  const CPageShell({
    super.key,
    required this.child,
    required this.routerState,
  });

  @override
  Widget build(BuildContext context) {
    final navManager = Provider.of<CNavManager>(context, listen: false);
    Future.microtask(() => navManager.notifyRoute(routerState.name));

    final handler = Provider.of<CEventHandler>(context, listen: false);
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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SizedBox.expand(
        child: SafeArea(child: child),
      ),
    );
  }
}
