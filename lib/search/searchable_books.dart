import 'package:bookoscope/components/future_handler.dart';
import 'package:bookoscope/db/book.db.dart';
import 'package:bookoscope/db/source.db.dart';
import 'package:bookoscope/format/guten/guten_acquisition.dart';
import 'package:bookoscope/format/opds/opds_crawler.dart';
import 'package:bookoscope/format/opds/opds_resource.dart';
import 'package:bookoscope/render/labeled_link_accordion.dart';
import 'package:bookoscope/render/labeled_list_accordion.dart';
import 'package:bookoscope/render/labeled_search_links.dart';
import 'package:bookoscope/render/link.dart';
import 'package:bookoscope/render/name_description.dart';
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
    return [
      if (book.authors.isNotEmpty)
        CRenderLinksParagraph(
          label: "Author${book.authors.length > 1 ? "s" : ""}",
          textQueries: book.authors
              .map((author) => CSearchQueryLink(author, "Author: $author"))
              .toList(),
        ),
      if (book.format != null)
        CRenderLinksParagraph(label: "Format", textQueries: [
          CSearchQueryLink(book.format.toString(), "Format: ${book.format}"),
        ]),
      if (book.categories.isNotEmpty)
        CRenderLinksParagraph(
          label: "Tags",
          textQueries: book.categories
              .map((cat) => CSearchQueryLink(cat, "Category: $cat"))
              .toList(),
        ),
      if (book.metadata.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CRenderLabeledListAccordion(
            book.metadata.map(
              (metadata) => CNameDescription(
                  metadata.type ?? "Meta", metadata.content ?? "Unknown"),
            ),
            label: "Metadata",
          ),
        ),
      if ((book.downloadUrls?.isEmpty ?? true) && !book.isGutenberg)
        const Text("No download links found.")
      else if (book.isGutenberg)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _GutenbergLinks(textId: book.originalId),
        )
      else
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CRenderLabeledResultLinkAccordion(
              label: "Download",
              links: book.downloadUrls
                      ?.where(
                    (uri) =>
                        uri.rel != null &&
                        OPDSLinkClassifier.isAcquisition(uri.rel ?? ""),
                  )
                      .map((uri) {
                    return CExternalLink(
                      OPDSLinkClassifier.getDisplayLabel(
                        uri.label,
                        uri.rel,
                        uri.type,
                      ),
                      uri: uri.uri ?? "",
                    );
                  }).toList() ??
                  []),
        ),
    ];
  }

  @override
  String get title => book.title;

  @override
  String get originalId => book.originalId;

  @override
  Iterable<String> get searchTextList => [
        source.label,
        book.title,
        ...book.authors.map((author) => "Author: $author"),
        if (book.format != null) "Format: ${book.format}",
        ...book.categories.map((cat) => "Category: $cat"),
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

class _GutenbergLinks extends StatefulWidget {
  final String textId;

  const _GutenbergLinks({required this.textId});

  @override
  State<_GutenbergLinks> createState() => _GutenbergLinksState();
}

class _GutenbergLinksState extends State<_GutenbergLinks> {
  late final Future<List<OPDSCrawlResourceUrl>> linksFuture;

  @override
  void initState() {
    super.initState();
    linksFuture = getGutenbergResourceUris(widget.textId);
  }

  @override
  Widget build(BuildContext context) {
    return BKFutureHandler(
      future: linksFuture,
      errorMessage:
          'Error while getting download links from Gutenberg Project.',
      nullDataMessage: 'No data received.',
      builder: (context, links) => links.isEmpty
          ? const Text("No download links found.")
          : CRenderLabeledResultLinkAccordion(
              label: "Download",
              links: links
                  .map(
                    (link) => CExternalLink(
                      OPDSLinkClassifier.getDisplayLabel(
                        link.label,
                        link.rel,
                        link.type,
                        includeType: false,
                      ),
                      uri: link.uri,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
