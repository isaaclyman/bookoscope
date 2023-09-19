import 'package:cypher_system_srd_lookup/search/search_manager.dart';
import 'package:cypher_system_srd_lookup/util/debounce.dart';
import 'package:flutter/material.dart';

class CEventHandler {
  final CSearchManager searchManager;
  late final void Function() debouncedSearch;

  CEventHandler({required this.searchManager}) {
    debouncedSearch = cDebounce(
      const Duration(milliseconds: 150),
      () => searchManager.search(),
    );
  }

  closeDrawer(BuildContext context) {
    Scaffold.of(context).closeEndDrawer();
  }

  setSearchFilters(Map<String, bool> filterState) {
    searchManager.filterState = filterState;
    debouncedSearch();
  }

  setSearchQuery(String query) {
    searchManager.searchText = query;
    debouncedSearch();
  }
}