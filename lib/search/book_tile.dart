import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:bookoscope/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BKBookTile extends StatelessWidget {
  final String? searchText;
  final BKSearchResult result;

  const BKBookTile({
    super.key,
    required this.result,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    final searchManager = context.watch<BKSearchManager>();
    final imageUrl = result.imageUrl;

    return GestureDetector(
      onTap: () {
        searchManager.selectResult(context, result);
      },
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    )
                  : _DefaultBookCover(
                      title: result.title,
                      author: result.author,
                    ),
            ),
            ListTile(
              title: Text(
                result.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: _HighlightMatch(
                matchText: searchText,
                fullText: result.author,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download_for_offline_rounded),
                onPressed: () {},
              ),
            )
          ],
        ),
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

class _DefaultBookCover extends StatelessWidget {
  final String title;
  final String author;

  const _DefaultBookCover({
    required this.title,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey[900]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Center(
                child: AutoSizeText(
                  title,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 26,
                    fontFamily: 'Titillium',
                  ),
                ),
              ),
            ),
            Text(
              author,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(220),
                fontSize: 14,
                fontFamily: 'Titillium',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
