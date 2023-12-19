import 'dart:collection';

import 'package:azlistview/azlistview.dart';
import 'package:bookoscope/components/fade_horizontal_scroll.dart';
import 'package:bookoscope/search/results.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/util/intersperse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CPageBrowse extends StatefulWidget {
  static const name = 'Browse';

  const CPageBrowse({super.key});

  @override
  State<CPageBrowse> createState() => _CPageBrowseState();
}

class _CPageBrowseState extends State<CPageBrowse> {
  @override
  Widget build(BuildContext context) {
    final searchManager = context.watch<BKSearchManager>();
    final selectedFilter = searchManager.selectedBrowseFilter;
    final searchables = searchManager.browsingCategory?.searchables;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: selectedFilter == null || searchables == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _AlphabeticalEntryList(
                    category: selectedFilter,
                    searchables: searchables,
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: CFadeHorizontalScroll(
            child: Row(
              children: searchManager.filterState.keys
                  .map<Widget>(
                    (filterName) => ChoiceChip(
                      label: Text(filterName),
                      onSelected: (checked) {
                        if (!checked) {
                          return;
                        }
                        setState(
                          () => searchManager.selectBrowseFilter(filterName),
                        );
                      },
                      selected: selectedFilter == filterName,
                    ),
                  )
                  .intersperse(const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                  ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AlphabeticalEntryList extends StatelessWidget {
  final List<CSearchable> searchables;
  final String category;

  const _AlphabeticalEntryList({
    required this.category,
    required this.searchables,
  });

  @override
  Widget build(BuildContext context) {
    if (searchables.isEmpty) {
      return const SizedBox.shrink();
    }

    final beans =
        searchables.map((s) => CSearchableBean.fromCSearchable(s)).toList();
    final indexLetters =
        LinkedHashSet<String>.from(beans.map((b) => b.getSuspensionTag()))
            .toList();

    return AzListView(
      data: beans,
      indexBarData: searchables.length < 10 ? [] : indexLetters,
      itemBuilder: (context, index) {
        final result = searchables.elementAt(index);
        return CEntrySummary(
          bookmarkOnLeft: true,
          result: CSearchResult(
            category: category,
            header: result.header,
            summary: result.defaultDescription,
            getRenderables: result.getRenderables,
            priority: 0,
          ),
          searchText: null,
        );
      },
      itemCount: searchables.length,
    );
  }
}
