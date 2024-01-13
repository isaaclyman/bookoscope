import 'package:auto_size_text/auto_size_text.dart';
import 'package:bookoscope/search/search_manager.dart';
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
                      errorBuilder: (_, err, ___) {
                        debugPrint(err.toString());
                        return _DefaultBookCover(
                          title: result.title,
                          author: result.author,
                          sourceName: result.sourceName,
                        );
                      },
                    )
                  : _DefaultBookCover(
                      title: result.title,
                      author: result.author,
                      sourceName: result.sourceName,
                    ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(
                left: 16,
                right: 2,
              ),
              title: Text(
                result.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                result.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

class _DefaultBookCover extends StatelessWidget {
  final String title;
  final String author;
  final String sourceName;

  const _DefaultBookCover({
    required this.title,
    required this.author,
    required this.sourceName,
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
              child: AutoSizeText(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(220),
                  fontSize: 26,
                  fontFamily: 'Titillium',
                ),
              ),
            ),
            Text(
              sourceName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
