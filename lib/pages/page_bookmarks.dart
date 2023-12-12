import 'package:collection/collection.dart';
import 'package:bookoscope/components/future_handler.dart';
import 'package:bookoscope/db/bookmark.db.dart';
import 'package:bookoscope/events/error_toast.dart';
import 'package:bookoscope/search/results.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CPageBookmarks extends StatelessWidget {
  static const name = 'Bookmarks';

  const CPageBookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return CFutureHandler(
        future: context.watch<CBookmarkManager>().bookmarksFuture,
        errorMessage: "Error getting bookmarks.",
        nullDataMessage: "Bookmark table is null.",
        builder: (context, bookmarks) {
          final categoriesByName = <String, CSearchResultCategory>{};
          final searchManager =
              Provider.of<CSearchManager>(context, listen: false);

          for (var bookmark in bookmarks) {
            final resultCategory = categoriesByName.putIfAbsent(
              bookmark.categoryName,
              () => CSearchResultCategory(
                category: bookmark.categoryName,
                results: [],
              ),
            );

            resultCategory.addResult(CSearchResult(
              category: bookmark.categoryName,
              header: bookmark.itemName,
              summary: bookmark.itemDescription,
              getRenderables: () {
                final result = searchManager.getResult(
                    bookmark.categoryName, bookmark.itemName);
                if (result == null) {
                  ScaffoldMessenger.of(context).showSnackBar(cErrorToast(
                      "Couldn't find this entry in the data file."));
                  throw Error();
                }

                return result.getRenderables();
              },
              priority: 0,
            ));
          }

          return CResultsBlock(
            categoriesByName.values
                .sorted((a, b) => a.category.compareTo(b.category)),
            searchText: null,
            noResultsMessage: "No bookmarks yet.",
          );
        });
  }
}
