import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:flutter/material.dart';

class BKSearchableBook extends BKSearchable {
  final Book book;
  final Source source;

  BKSearchableBook({
    required this.book,
    required this.source,
  });

  @override
  String get defaultDescription => book.authors.join("; ");

  @override
  Iterable<Widget> getRenderables() {
    // TODO: implement getRenderables
    throw UnimplementedError();
  }

  @override
  String get header => book.title;

  @override
  String get originalId => book.originalId;

  @override
  Iterable<String> get searchTextList => [
        source.label,
        book.title,
        ...book.authors,
        ...book.tags,
      ];
}

class BKHasSearchableSources extends BKHasSearchables {
  final List<Book> books;
  final List<Source> sources;

  @override
  late final List<BKSearchableSource> searchableSources;

  BKHasSearchableSources({
    required this.books,
    required this.sources,
  }) {
    searchableSources = _getSearchableSources(sources, books);
  }

  List<BKSearchableSource> _getSearchableSources(
    List<Source> sources,
    List<Book> books,
  ) {
    final booksBySourceId = <int, List<Book>>{};
    for (final book in books) {
      booksBySourceId.putIfAbsent(book.sourceId, () => []);
      booksBySourceId[book.sourceId]?.add(book);
    }

    return sources
        .map((source) => BKSearchableSource(
              sourceName: source.label,
              searchables: booksBySourceId[source.id]
                      ?.map((book) => BKSearchableBook(
                            book: book,
                            source: source,
                          ))
                      .toList() ??
                  [],
            ))
        .toList();
  }
}
