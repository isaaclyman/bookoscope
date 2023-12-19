import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BKSearchManager extends ChangeNotifier {
  final BKHasSearchables _root;
  List<BKSearchable> allSearchables;
  BKSearchableSource? get browsingSource => selectedBrowseFilter == null
      ? null
      : _root.searchableSources
          .firstWhereOrNull((cat) => cat.sourceName == selectedBrowseFilter);

  String searchText = "";
  Map<String, bool> filterState;
  String? selectedBrowseFilter;

  Iterable<BKSearchResultSource> results = [];
  bool get hasResults => results.isNotEmpty;

  BKSearchResult? selectedResult;
  List<BKSearchResult> pastResults = [];
  BKSearchResult? get lastResult => pastResults.last;
  bool get canGoBack => pastResults.isNotEmpty;

  BKSearchManager(this._root)
      : filterState = {
          for (var s in _root.searchableSources) s.sourceName: true
        },
        allSearchables = _root.searchableSources
            .expand((source) => source.searchables)
            .sortedBy((item) => item.header.replaceAll(RegExp("[\"']"), ''))
            .toList();

  void search() {
    results = _getResults();
    notifyListeners();
  }

  BKSearchResult? getResult(String? sourceName, String id) {
    var searchableSource = sourceName != null
        ? _root.searchableSources
            .firstWhereOrNull((cat) => cat.sourceName == sourceName)
        : null;

    if (searchableSource == null) {
      for (var source in _root.searchableSources) {
        var searchable =
            source.searchables.firstWhereOrNull((it) => it.originalId == id);
        if (searchable == null) {
          continue;
        }

        return BKSearchResult(
          sourceName: source.sourceName,
          header: searchable.header,
          summary: id,
          getRenderables: searchable.getRenderables,
          priority: 0,
        );
      }

      return null;
    }

    var searchable =
        searchableSource.searchables.firstWhereOrNull((it) => it.header == id);
    if (searchable == null) {
      return null;
    }

    return BKSearchResult(
      sourceName: searchableSource.sourceName,
      header: searchable.header,
      summary: id,
      getRenderables: searchable.getRenderables,
      priority: 0,
    );
  }

  void selectBrowseFilter(String? filter) {
    selectedBrowseFilter = filter;
    notifyListeners();
  }

  void selectResult(BuildContext context, BKSearchResult? result) {
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

  Iterable<BKSearchResultSource> _getResults() {
    if (searchText.trim().isEmpty) {
      return [];
    }

    final results = <String, BKSearchResultSource>{};

    for (var source in _root.searchableSources) {
      final sourceName = source.sourceName;

      if (filterState[sourceName] == false) {
        continue;
      }

      for (var searchable in source.searchables) {
        final match = searchable.searchTextList.indexed.firstWhereOrNull(
            (it) => it.$2.toLowerCase().contains(searchText.toLowerCase()));
        if (match == null) {
          continue;
        }

        final (priority, matchingText) = match;
        final resultSource = results.putIfAbsent(
          sourceName,
          () => BKSearchResultSource(
            sourceName: sourceName,
            results: [],
          ),
        );
        resultSource.addResult(
          BKSearchResult(
            sourceName: sourceName,
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
            ? v1.sourceName.compareTo(v2.sourceName)
            : v1.minPriority.compareTo(v2.minPriority))
        .toList();
  }
}

class BKSearchResultSource {
  final String sourceName;
  final List<BKSearchResult> results;
  int minPriority = 100;

  BKSearchResultSource({
    required this.sourceName,
    required this.results,
  });

  void addResult(BKSearchResult result) {
    minPriority = min(minPriority, result.priority);
    results.add(result);
  }
}

class BKSearchResult {
  final String sourceName;
  final String header;
  final String summary;
  final Iterable<Widget> Function() getRenderables;
  final int priority;

  BKSearchResult({
    required this.sourceName,
    required this.header,
    required this.summary,
    required this.getRenderables,
    required this.priority,
  });
}

//
// FOR DATA CLASSES
//

class BKSearchableSource {
  String sourceName;
  List<BKSearchable> searchables;

  BKSearchableSource({
    required this.sourceName,
    required this.searchables,
  });
}

//
// INTERFACES
//

abstract class BKHasSearchables {
  List<BKSearchableSource> get searchableSources;
}

abstract class BKSearchable {
  String get originalId;
  String get header;
  String get defaultDescription;
  Iterable<String> get searchTextList;
  Iterable<Widget> getRenderables();
}

abstract class BKSearchableItem {
  String get searchText;
}

abstract class BKSearchableComplexItem {
  Iterable<String> get searchTextList;
  Iterable<Widget> getRenderables();
}
