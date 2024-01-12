import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/search/browse_all.dart';
import 'package:bookoscope/search/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BKPageBrowse extends StatefulWidget {
  static const name = 'Search';

  const BKPageBrowse({super.key});

  @override
  State<BKPageBrowse> createState() => _BKPageBrowseState();
}

class _BKPageBrowseState extends State<BKPageBrowse> {
  bool isSearchBarFocused = false;

  @override
  Widget build(BuildContext context) {
    final sources = context.watch<DBSources>();

    if (sources.sources.where((source) => source.isEnabled).isEmpty) {
      return const Center(
        child: Text('No sources found. Add one to begin.'),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
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
          const Expanded(child: BKBrowseAll()),
        ],
      ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const CSearchFilters(),
      ],
    );
  }
}
