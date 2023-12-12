import 'package:bookoscope/pages/page_about.dart';
import 'package:bookoscope/search/results.dart';
import 'package:bookoscope/search/search_bar.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/theme/colors.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CPageSearch extends StatefulWidget {
  static const name = 'Search';

  const CPageSearch({super.key});

  @override
  State<CPageSearch> createState() => _CPageSearchState();
}

class _CPageSearchState extends State<CPageSearch> {
  bool isSearchBarFocused = false;

  @override
  Widget build(BuildContext context) {
    final searchManager = context.watch<CSearchManager>();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (!isSearchBarFocused && !searchManager.hasResults)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                color: context.colors.accent,
                onPressed: () {
                  context.pushNamed(CPageAbout.name);
                },
                icon: const Icon(Icons.info_outline),
              ),
            ),
          ),
        Expanded(
          child: AnimatedAlign(
            alignment: isSearchBarFocused || searchManager.hasResults
                ? Alignment.topCenter
                : Alignment.center,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SearchBlock(
                  onFocusChange: (isFocused) => setState(() {
                    isSearchBarFocused = isFocused;
                  }),
                ),
                if (searchManager.searchText.isNotEmpty)
                  Expanded(
                    child: Builder(builder: (context) {
                      return CResultsBlock(
                        searchManager.results,
                        searchText: searchManager.searchText,
                        noResultsMessage:
                            "No results found.\nCheck your filters.",
                      );
                    }),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBlock extends StatelessWidget {
  final void Function(bool) onFocusChange;

  const _SearchBlock({
    required this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
            child: CSearchBar(
              onFocusChange: onFocusChange,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              "Compatible with the Cypher System",
              style: context.text.legal,
            ),
          ),
        ),
        const CSearchFilters(),
      ],
    );
  }
}
