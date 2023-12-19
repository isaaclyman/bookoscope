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
    final searchables = searchManager.allSearchables;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _BookGrid(
              searchables: searchables,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookGrid extends StatelessWidget {
  final List<BKSearchable> searchables;

  const _BookGrid({
    required this.searchables,
  });

  @override
  Widget build(BuildContext context) {
    if (searchables.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        childAspectRatio: 1 / 1.6,
      ),
      itemCount: searchables.length,
      itemBuilder: (_, ix) {
        final result = searchables.elementAt(ix);
        return BKBookTile(
            bookmarkOnLeft: true,
            result: BKSearchResult(
              sourceName: "",
              header: result.header,
              summary: result.defaultDescription,
              getRenderables: result.getRenderables,
              priority: 0,
            ),
            searchText: null);
      },
    );
  }
}
