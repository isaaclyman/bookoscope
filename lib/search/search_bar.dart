import 'package:bookoscope/components/fade_horizontal_scroll.dart';
import 'package:bookoscope/events/event_handler.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:bookoscope/util/intersperse.dart';
import 'package:flutter/material.dart';

import 'package:bookoscope/theme/colors.dart';
import 'package:provider/provider.dart';

class CSearchBar extends StatefulWidget {
  final void Function(bool) onFocusChange;

  const CSearchBar({
    super.key,
    required this.onFocusChange,
  });

  @override
  State<CSearchBar> createState() => _CSearchBarState();
}

class _CSearchBarState extends State<CSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final List<VoidCallback> onDispose = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    onDispose.add(() => _focusNode.removeListener(_onFocusChange));

    final searchManager = context.read<BKSearchManager>();
    searchManager.addListener(_onSearchChange);
    _onSearchChange();
    onDispose.add(() => searchManager.removeListener(_onSearchChange));
  }

  @override
  void dispose() {
    for (var callback in onDispose) {
      callback();
    }

    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChange() {
    if (context.mounted) {
      _controller.text = context.read<BKSearchManager>().searchText;
    }
  }

  void _onFocusChange() {
    widget.onFocusChange.call(_focusNode.hasFocus);
  }

  OutlineInputBorder _inputBorder(double width) => OutlineInputBorder(
        borderSide: BorderSide(
          color: context.colors.primary,
          width: width,
        ),
        borderRadius: BorderRadius.circular(50),
      );

  @override
  Widget build(BuildContext context) {
    final handler = context.watch<BKEventHandler>();

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        border: _inputBorder(1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 6,
        ),
        enabledBorder: _inputBorder(1),
        focusedBorder: _inputBorder(2),
        labelText: "Search books",
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() {
                  _controller.clear();
                  handler.setSearchQuery(context, "");
                }),
                tooltip: "Clear search",
              ),
      ),
      focusNode: _focusNode,
      onChanged: (value) => handler.setSearchQuery(context, value),
    );
  }
}

class CSearchFilters extends StatefulWidget {
  const CSearchFilters({super.key});

  @override
  State<CSearchFilters> createState() => _CSearchFiltersState();
}

class _CSearchFiltersState extends State<CSearchFilters> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final handler = context.watch<BKEventHandler>();
    final searchManager = context.watch<BKSearchManager>();
    final areAllFiltersToggledOn =
        searchManager.filterState.entries.every((kvp) => kvp.value);

    return CFadeHorizontalScroll(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton(
              onPressed: () {
                final newFilters = {
                  for (var key in searchManager.filterState.keys)
                    key: !areAllFiltersToggledOn
                };
                handler.setSearchFilters(newFilters);
              },
              icon: Icon(
                areAllFiltersToggledOn
                    ? Icons.filter_list
                    : Icons.filter_list_off,
                size: 20,
              ),
              tooltip: areAllFiltersToggledOn ? 'Deselect all' : 'Select all',
            ),
          ),
          ...searchManager.filterState.entries
              .map<Widget>(
                (kvp) => FilterChip(
                  label: Text(kvp.key),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  labelStyle: context.text.filterChip,
                  selected: kvp.value,
                  onSelected: (value) {
                    final newFilters =
                        Map<String, bool>.from(searchManager.filterState);
                    newFilters[kvp.key] = value;
                    handler.setSearchFilters(newFilters);
                  },
                ),
              )
              .intersperse(
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
