import 'dart:math';

import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BKBookTile extends StatelessWidget {
  final String? searchText;
  final BKSearchResult result;
  final bool bookmarkOnLeft;

  const BKBookTile({
    super.key,
    required this.result,
    required this.searchText,
    required this.bookmarkOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    final searchManager = Provider.of<BKSearchManager>(context);

    return Card(
      child: GridTile(
        footer: GridTileBar(
          title: Text(result.header),
          subtitle: _HighlightMatch(
            matchText: searchText,
            fullText: result.summary,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.download_for_offline_rounded),
            onPressed: () {},
          ),
        ),
        child: const Text('Cover Image'),
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
