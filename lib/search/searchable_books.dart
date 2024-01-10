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
  String get author => book.authors.join("; ");

  @override
  Iterable<Widget> getRenderables() {
    return [Text('Placeholder')];
  }

  @override
  String get title => book.title;

  @override
  String get originalId => book.originalId;

  @override
  Iterable<String> get searchTextList => [
        source.label,
        book.title,
        ...book.authors,
        ...book.tags,
      ];

  @override
  String? get imageUrl => book.imageUrl;
}

class BKHasSearchableSources extends BKHasSearchables {
  final List<Book> books;
  final List<Source> sources;

  @override
  List<BKSearchableSource> get searchableSources =>
      _getSearchableSources(sources, books);

  BKHasSearchableSources({
    required this.books,
    required this.sources,
  });

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
        .where((source) => source.isEnabled)
        .map((source) => BKSearchableSource(
              sourceName: source.label,
              isBuiltInSource: !source.isEditable,
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
