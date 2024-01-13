/// A resource (e.g. an individual ebook).
class OPDSCrawlResource {
  final String originalId;
  final String title;
  final List<String> authors;
  final String? format;
  final List<String>? categories;
  final Map<String, String> metadata;
  final List<OPDSCrawlResourceUrl> downloadUrls;
  final String? imageUrl;
  final String? htmlDescription;
  final String? textDescription;

  const OPDSCrawlResource({
    required this.originalId,
    required this.title,
    required this.authors,
    required this.format,
    required this.categories,
    required this.metadata,
    required this.downloadUrls,
    required this.imageUrl,
    required this.htmlDescription,
    required this.textDescription,
  });
}

/// A link that can be used to download some version of an [OPDSCrawlResource].
class OPDSCrawlResourceUrl {
  /// The original title of the link, if available.
  final String? label;

  /// The URI of the link.
  final String uri;

  /// The relationship of the linked resource to this entry.
  final String rel;

  /// The MIME type of the download, if known.
  final String? type;

  const OPDSCrawlResourceUrl({
    required this.label,
    required this.uri,
    required this.rel,
    required this.type,
  });
}
