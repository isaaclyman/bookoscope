import 'package:bookoscope/search/book_tile.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BKBrowseAll extends StatefulWidget {
  const BKBrowseAll({super.key});

  @override
  State<BKBrowseAll> createState() => _BKBrowseAllState();
}

class _BKBrowseAllState extends State<BKBrowseAll> {
  @override
  Widget build(BuildContext context) {
    final searchManager = context.watch<BKSearchManager>();
    final searchables = searchManager.results;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: _BookGrid(
        combineSources: !searchManager.isSearching,
        resultSources: searchables,
      ),
    );
  }
}

class _BookGrid extends StatelessWidget {
  final bool combineSources;
  final Iterable<BKSearchResultSource> resultSources;

  const _BookGrid({
    required this.combineSources,
    required this.resultSources,
  });

  @override
  Widget build(BuildContext context) {
    if (resultSources.isEmpty) {
      return const SizedBox.shrink();
    }

    final results = resultSources
        .sorted((a, b) {
          if (a.minPriority != b.minPriority) {
            return a.minPriority.compareTo(b.minPriority);
          }

          if (a.isBuiltInSource != b.isBuiltInSource) {
            return a.isBuiltInSource ? 1 : -1;
          }

          return a.sourceName.compareTo(b.sourceName);
        })
        .expand((source) => source.results)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 1 / 1.6,
        ),
        itemCount: results.length,
        itemBuilder: (_, ix) {
          final result = results.elementAt(ix);
          return BKBookTile(
            result: BKSearchResult(
              sourceName: result.sourceName,
              title: result.title,
              author: result.author,
              imageUrl: result.imageUrl,
              getRenderables: result.getRenderables,
              priority: 0,
            ),
            searchText: null,
          );
        },
      ),
    );
  }
}
