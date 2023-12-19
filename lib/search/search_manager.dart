import 'dart:math';

import 'package:azlistview/azlistview.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BKSearchManager extends ChangeNotifier {
  final CHasSearchables _root;
  CSearchableCategory? get browsingCategory => selectedBrowseFilter == null
      ? null
      : _root.searchables
          .firstWhereOrNull((cat) => cat.category == selectedBrowseFilter);

  String searchText = "";
  Map<String, bool> filterState;
  String? selectedBrowseFilter;

  Iterable<CSearchResultCategory> results = [];
  bool get hasResults => results.isNotEmpty;

  CSearchResult? selectedResult;
  List<CSearchResult> pastResults = [];
  CSearchResult? get lastResult => pastResults.last;
  bool get canGoBack => pastResults.isNotEmpty;

  BKSearchManager(this._root)
      : filterState = {for (var s in _root.searchables) s.category: true},
        selectedBrowseFilter = _root.searchables.first.category;

  void search() {
    results = _getResults();
    notifyListeners();
  }

  CSearchResult? getResult(String? searchableCategoryName, String itemName) {
    var searchableCategory = searchableCategoryName != null
        ? _root.searchables
            .firstWhereOrNull((cat) => cat.category == searchableCategoryName)
        : null;

    if (searchableCategory == null) {
      for (var category in _root.searchables) {
        var searchable = category.searchables
            .firstWhereOrNull((it) => it.header == itemName);
        if (searchable == null) {
          continue;
        }

        return CSearchResult(
          category: category.category,
          header: searchable.header,
          summary: itemName,
          getRenderables: searchable.getRenderables,
          priority: 0,
        );
      }

      return null;
    }

    var searchable = searchableCategory.searchables
        .firstWhereOrNull((it) => it.header == itemName);
    if (searchable == null) {
      return null;
    }

    return CSearchResult(
      category: searchableCategory.category,
      header: searchable.header,
      summary: itemName,
      getRenderables: searchable.getRenderables,
      priority: 0,
    );
  }

  void selectBrowseFilter(String? filter) {
    selectedBrowseFilter = filter;
    notifyListeners();
  }

  void selectResult(BuildContext context, CSearchResult? result) {
    if (selectedResult != null && selectedResult != result) {
      pastResults.add(selectedResult!);
    }

    selectedResult = result;
    Future.microtask(() => Scaffold.of(context).openEndDrawer());
    notifyListeners();
  }

  void selectPreviousResult() {
    if (pastResults.isEmpty) {
      return;
    }

    selectedResult = pastResults.removeLast();
    notifyListeners();
  }

  Iterable<CSearchResultCategory> _getResults() {
    if (searchText.trim().isEmpty) {
      return [];
    }

    final results = <String, CSearchResultCategory>{};

    for (var searchableCategory in _root.searchables) {
      final category = searchableCategory.category;

      if (filterState[category] == false) {
        continue;
      }

      for (var searchable in searchableCategory.searchables) {
        final match = searchable.searchTextList.indexed.firstWhereOrNull(
            (it) => it.$2.toLowerCase().contains(searchText.toLowerCase()));
        if (match == null) {
          continue;
        }

        final (priority, matchingText) = match;
        final resultCategory = results.putIfAbsent(
          category,
          () => CSearchResultCategory(
            category: category,
            results: [],
          ),
        );
        resultCategory.addResult(
          CSearchResult(
            category: category,
            header: searchable.header,
            summary: matchingText,
            getRenderables: searchable.getRenderables,
            priority:
                searchText.toLowerCase() == searchable.header.toLowerCase()
                    ? -1
                    : priority,
          ),
        );
      }
    }

    for (var category in results.values) {
      category.results.sort((v1, v2) => v1.priority == v2.priority
          ? v1.header.compareTo(v2.header)
          : v1.priority.compareTo(v2.priority));
    }

    return results.values
        .sorted((v1, v2) => v1.minPriority == v2.minPriority
            ? v1.category.compareTo(v2.category)
            : v1.minPriority.compareTo(v2.minPriority))
        .toList();
  }
}

class CSearchResultCategory {
  final String category;
  final List<CSearchResult> results;
  int minPriority = 100;

  CSearchResultCategory({
    required this.category,
    required this.results,
  });

  void addResult(CSearchResult result) {
    minPriority = min(minPriority, result.priority);
    results.add(result);
  }
}

class CSearchResult {
  final String category;
  final String header;
  final String summary;
  final Iterable<Widget> Function() getRenderables;
  final int priority;

  CSearchResult({
    required this.category,
    required this.header,
    required this.summary,
    required this.getRenderables,
    required this.priority,
  });
}

class CSearchableBean implements ISuspensionBean {
  CSearchable searchable;

  CSearchableBean.fromCSearchable(this.searchable);

  @override
  bool isShowSuspension = true;

  @override
  String getSuspensionTag() => searchable.header[0];
}

//
// FOR DATA CLASSES
//

class CSearchableCategory {
  String category;
  List<CSearchable> searchables;

  CSearchableCategory({
    required this.category,
    required this.searchables,
  });
}

//
// INTERFACES
//

abstract class CHasSearchables {
  List<CSearchableCategory> get searchables;
}

abstract class CSearchable {
  String get header;
  String get defaultDescription;
  Iterable<String> get searchTextList;
  Iterable<Widget> getRenderables();
}

abstract class CSearchableItem {
  String get searchText;
}

abstract class CSearchableComplexItem {
  Iterable<String> get searchTextList;
  Iterable<Widget> getRenderables();
}
