import 'package:bookoscope/search/book_tile.dart';
import 'package:bookoscope/search/search_manager.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _BookGrid(
              combineSources: !searchManager.isSearching,
              resultSources: searchables,
            ),
          ),
        ),
      ],
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

    final combinedSources = !combineSources
        ? resultSources
        : [
            BKSearchResultSource(
              sourceName: "",
              isBuiltInSource: true,
              results:
                  resultSources.expand((source) => source.results).toList(),
            ),
          ];

    return Column(
      children: combinedSources
          .map(
            (source) => [
              if (source.sourceName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    source.sourceName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 1 / 1.6,
                    ),
                    itemCount: source.results.length,
                    itemBuilder: (_, ix) {
                      final result = source.results.elementAt(ix);
                      return BKBookTile(
                        result: BKSearchResult(
                          sourceName: "",
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
                ),
              ),
            ],
          )
          .expand((pair) => pair)
          .toList(),
    );
  }
}
