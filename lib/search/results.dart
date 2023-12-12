import 'dart:math';

import 'package:collection/collection.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CResultsBlock extends StatefulWidget {
  final Iterable<CSearchResultCategory> results;
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
                        _CategoryHeader(text: cat.category),
                        ...cat.results
                            .slice(
                              0,
                              min(
                                  resultsToShow.putIfAbsent(
                                      cat.category, () => 10),
                                  cat.results.length),
                            )
                            .map((r) => CEntrySummary(
                                  result: r,
                                  searchText: widget.searchText,
                                  bookmarkOnLeft: false,
                                )),
                        if (cat.results.length >
                            (resultsToShow[cat.category] ?? 10))
                          _LoadMoreResults(
                            categoryName: cat.category,
                            onLoadMore: () {
                              setState(() {
                                resultsToShow[cat.category] = resultsToShow
                                        .putIfAbsent(cat.category, () => 10) +
                                    10;
                              });
                            },
                            resultsShown: resultsToShow[cat.category] ?? 10,
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

class CEntrySummary extends StatelessWidget {
  final String? searchText;
  final CSearchResult result;
  final bool bookmarkOnLeft;

  const CEntrySummary({
    super.key,
    required this.result,
    required this.searchText,
    required this.bookmarkOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    final searchManager = Provider.of<CSearchManager>(context);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              searchManager.selectResult(context, result);
            },
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 6,
                left: bookmarkOnLeft ? 0 : 24,
                right: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      result.header,
                      style: context.text.resultEntryHeader,
                    ),
                  ),
                  if (result.summary.isNotEmpty)
                    _HighlightMatch(
                      matchText: searchText,
                      fullText: result.summary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
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

class _HighlightMatch extends StatelessWidget {
  final String? matchText;
  final String fullText;

  const _HighlightMatch({
    required this.matchText,
    required this.fullText,
  });

  @override
  Widget build(BuildContext context) {
    if (matchText == null) {
      return Text.rich(
        TextSpan(text: fullText),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final fullMatchIx =
        fullText.toLowerCase().indexOf(matchText!.toLowerCase());

    final minWindow = max(30, matchText!.length);
    String windowedText;
    if (minWindow >= fullText.length || fullMatchIx <= minWindow) {
      windowedText = fullText;
    } else if (fullMatchIx >= fullText.length - minWindow) {
      windowedText = "...${fullText.substring(fullText.length - minWindow)}";
    } else {
      windowedText = "...${fullText.substring(fullMatchIx - minWindow ~/ 2)}";
    }

    final windowMatchIx =
        windowedText.toLowerCase().indexOf(matchText!.toLowerCase());

    return windowMatchIx == -1
        ? Text.rich(
            TextSpan(text: windowedText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : Text.rich(
            TextSpan(children: [
              TextSpan(
                text: windowedText.substring(0, windowMatchIx),
              ),
              TextSpan(
                text: windowedText.substring(
                    windowMatchIx, windowMatchIx + matchText!.length),
                style: context.text.highlight,
              ),
              TextSpan(
                text: windowedText.substring(windowMatchIx + matchText!.length),
              ),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
  }
}
