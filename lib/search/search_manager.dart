import 'dart:collection';
import 'dart:math';

import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/dated_title.db.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/render/link.dart';
import 'package:bookoscope/search/searchable_books.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BKSearchManager extends ChangeNotifier {
  BKHasSearchableSources _root = BKHasSearchableSources(
    books: [],
    sources: [],
    newTitles: HashSet(),
  );
  Map<String, bool> filterState = {};

  BKSearchableSource? get browsingSource => selectedBrowseFilter == null
      ? null
      : _root.searchableSources
          .firstWhereOrNull((cat) => cat.sourceName == selectedBrowseFilter);

  bool get isSearching => searchText.trim().isNotEmpty;
  String searchText = "";
  String? selectedBrowseFilter;

  Iterable<BKSearchResultSource> results = [];
  bool get hasResults => results.isNotEmpty;

  BKSearchResult? selectedResult;
  List<BKSearchResult> pastResults = [];
  BKSearchResult? get lastResult => pastResults.last;
  bool get canGoBack => pastResults.isNotEmpty;

  BKSearchManager();

  void search() {
    results = _getResults();
    notifyListeners();
  }

  void shuffle() {
    final shuffled = results.toList()..shuffle();

    for (var source in shuffled) {
      source.results.shuffle();
    }

    results = shuffled;
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
          originalId: searchable.originalId,
          sourceName: source.sourceName,
          title: searchable.title,
          author: id,
          imageUrl: searchable.imageUrl,
          downloadUrls: searchable.downloadUrls,
          isGutenberg: searchable.isGutenberg,
          isNewTitle: _root.newTitles.contains(searchable.title),
          getRenderables: searchable.getRenderables,
          priority: 0,
        );
      }

      return null;
    }

    var searchable =
        searchableSource.searchables.firstWhereOrNull((it) => it.title == id);
    if (searchable == null) {
      return null;
    }

    return BKSearchResult(
      originalId: searchable.originalId,
      sourceName: searchableSource.sourceName,
      title: searchable.title,
      author: id,
      imageUrl: searchable.imageUrl,
      downloadUrls: searchable.downloadUrls,
      isGutenberg: searchable.isGutenberg,
      isNewTitle: _root.newTitles.contains(searchable.title),
      getRenderables: searchable.getRenderables,
      priority: 0,
    );
  }

  void refreshSources(
      DBSources dbSources, DBBooks dbBooks, DBDatedTitles dbDatedTitles) {
    _root = BKHasSearchableSources(
        sources: dbSources.sources,
        books: dbBooks.books,
        newTitles: dbDatedTitles.newTitles);
    filterState = {for (var s in _root.searchableSources) s.sourceName: true};
    search();
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

    Future.microtask(() {
      if (context.mounted) {
        Scaffold.of(context).openEndDrawer();
      }
    });

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
    final showEverything = !isSearching;
    final results = <String, BKSearchResultSource>{};

    const newTitleSourceName = "✨ New Titles";
    final newTitleSource = _root.newTitles.isEmpty
        ? BKSearchResultSource(
            sourceName: newTitleSourceName,
            isBuiltInSource: false,
            isNewTitles: true,
            results: [],
          )
        : results.putIfAbsent(
            newTitleSourceName,
            () => BKSearchResultSource(
              sourceName: newTitleSourceName,
              isBuiltInSource: false,
              isNewTitles: true,
              results: [],
            ),
          );

    for (var source in _root.searchableSources) {
      final sourceName = source.sourceName;

      if (filterState[sourceName] == false) {
        continue;
      }

      for (var searchable in source.searchables) {
        int priority = 0;
        String? matchingText;

        if (!showEverything) {
          final match = searchable.searchTextList.indexed.firstWhereOrNull(
              (it) => it.$2.toLowerCase().contains(searchText.toLowerCase()));

          if (match == null) {
            continue;
          }

          (priority, matchingText) = match;
        }

        final resultSource = results.putIfAbsent(
          sourceName,
          () => BKSearchResultSource(
            sourceName: sourceName,
            isBuiltInSource: source.isBuiltInSource,
            isNewTitles: false,
            results: [],
          ),
        );

        final isNewTitle = _root.newTitles.contains(searchable.title);
        final searchResult = BKSearchResult(
          originalId: searchable.originalId,
          sourceName: sourceName,
          title: searchable.title,
          author: matchingText ?? searchable.author,
          imageUrl: searchable.imageUrl,
          downloadUrls: searchable.downloadUrls,
          isGutenberg: searchable.isGutenberg,
          isNewTitle: isNewTitle,
          getRenderables: searchable.getRenderables,
          priority: searchText.toLowerCase() == searchable.title.toLowerCase()
              ? -1
              : priority,
        );

        if (isNewTitle) {
          newTitleSource.addResult(searchResult);
        } else {
          resultSource.addResult(searchResult);
        }
      }
    }

    for (var category in results.values) {
      category.results.sort((v1, v2) => v1.priority == v2.priority
          ? v1.title.compareTo(v2.title)
          : v1.priority.compareTo(v2.priority));
    }

    return results.values.sorted((v1, v2) {
      if (v1.isBuiltInSource != v2.isBuiltInSource) {
        return v1.isBuiltInSource ? -1 : 1;
      }

      return v1.minPriority == v2.minPriority
          ? v1.sourceName.compareTo(v2.sourceName)
          : v1.minPriority.compareTo(v2.minPriority);
    }).toList();
  }
}

class BKSearchResultSource {
  final String sourceName;
  final bool isBuiltInSource;
  final bool isNewTitles;
  final List<BKSearchResult> results;
  int minPriority = 100;

  BKSearchResultSource({
    required this.sourceName,
    required this.isBuiltInSource,
    required this.isNewTitles,
    required this.results,
  });

  void addResult(BKSearchResult result) {
    minPriority = min(minPriority, result.priority);
    results.add(result);
  }
}

class BKSearchResult {
  final String originalId;
  final String sourceName;
  final String title;
  final String author;
  final String? imageUrl;
  final List<CExternalLink> downloadUrls;
  final bool isGutenberg;
  final bool isNewTitle;
  final Iterable<Widget> Function() getRenderables;
  final int priority;

  BKSearchResult({
    required this.originalId,
    required this.sourceName,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.downloadUrls,
    required this.isGutenberg,
    required this.isNewTitle,
    required this.getRenderables,
    required this.priority,
  });
}

//
// FOR DATA CLASSES
//

class BKSearchableSource {
  String sourceName;
  bool isBuiltInSource;
  List<BKSearchable> searchables;

  BKSearchableSource({
    required this.sourceName,
    required this.isBuiltInSource,
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
  String get title;
  String get author;
  String? get imageUrl;
  List<CExternalLink> get downloadUrls;
  bool get isGutenberg;
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
