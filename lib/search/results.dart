import 'dart:math';

import 'package:bookoscope/search/book_tile.dart';
import 'package:collection/collection.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';

class CResultsBlock extends StatefulWidget {
  final Iterable<BKSearchResultSource> results;
  final String? searchText;
  final String noResultsMessage;

  const CResultsBlock(
    this.results, {
    super.key,
    required this.searchText,
    required this.noResultsMessage,
  });

  @override
  State<CResultsBlock> createState() => _CResultsBlockState();
}

class _CResultsBlockState extends State<CResultsBlock> {
  final Map<String, int> resultsToShow = {};

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 650),
      child: widget.results.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.error),
                  ),
                  Text(
                    widget.noResultsMessage,
                  ),
                ],
              ),
            )
          : ListView(
              children: widget.results
                  .map((cat) => [
                        _CategoryHeader(text: cat.sourceName),
                        ...cat.results
                            .slice(
                              0,
                              min(
                                  resultsToShow.putIfAbsent(
                                      cat.sourceName, () => 10),
                                  cat.results.length),
                            )
                            .map((r) => BKBookTile(
                                  result: r,
                                  searchText: widget.searchText,
                                )),
                        if (cat.results.length >
                            (resultsToShow[cat.sourceName] ?? 10))
                          _LoadMoreResults(
                            categoryName: cat.sourceName,
                            onLoadMore: () {
                              setState(() {
                                resultsToShow[cat.sourceName] = resultsToShow
                                        .putIfAbsent(cat.sourceName, () => 10) +
                                    10;
                              });
                            },
                            resultsShown: resultsToShow[cat.sourceName] ?? 10,
                            totalResults: cat.results.length,
                          ),
                      ])
                  .flattened
                  .toList(),
            ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String text;

  const _CategoryHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 4,
        left: 8,
        right: 8,
        top: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Expanded(
            flex: 1,
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              text,
              style: context.text.resultCategoryHeader,
            ),
          ),
          const Expanded(
            flex: 20,
            child: Divider(
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreResults extends StatelessWidget {
  final String categoryName;
  final void Function() onLoadMore;
  final int resultsShown;
  final int totalResults;

  const _LoadMoreResults({
    required this.categoryName,
    required this.onLoadMore,
    required this.resultsShown,
    required this.totalResults,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$resultsShown of $totalResults $categoryName results.",
            style: context.text.small,
          ),
          TextButton(
            onPressed: onLoadMore,
            child: Text(
              "Load More",
              style: context.text.small,
            ),
          ),
        ],
      ),
    );
  }
}
