import 'package:bookoscope/db/bookmark.db.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CBookmarkIconButton extends StatelessWidget {
  final CSearchResult result;

  const CBookmarkIconButton({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarkManager = context.watch<CBookmarkManager>();
    final isBookmarked = bookmarkManager.isBookmarked(
      categoryName: result.category,
      itemName: result.header,
    );

    final bookmark = Bookmark(
      categoryName: result.category,
      itemName: result.header,
      itemDescription: result.summary,
    );

    return !bookmarkManager.isLoaded
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: IconButton(
              onPressed: () => !isBookmarked
                  ? bookmarkManager.addBookmark(bookmark)
                  : bookmarkManager.removeBookmark(bookmark),
              icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
              tooltip: !isBookmarked ? 'Add bookmark' : 'Remove bookmark',
              visualDensity: VisualDensity.compact,
            ),
          );
  }
}
