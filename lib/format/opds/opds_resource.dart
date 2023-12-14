/// A resource (e.g. an individual ebook).
class OPDSCrawlResource {
  final String title;
  final String author;
  final List<String> tags;
  final List<OPDSCrawlResourceUrl> downloadUrls;
  final String? imageUrl;
  final String? htmlDescription;
  final String? textDescription;

  const OPDSCrawlResource({
    required this.title,
    required this.author,
    required this.tags,
    required this.downloadUrls,
    required this.imageUrl,
    required this.htmlDescription,
    required this.textDescription,
  });
}

/// A link that can be used to download some version of an [OPDSCrawlResource].
class OPDSCrawlResourceUrl {
  /// The original title of the link, if available. Otherwise, defaults to
  /// "Download".
  final String label;
  final String uri;

  /// The MIME type of the download, if known.
  final String? type;

  const OPDSCrawlResourceUrl({
    required this.label,
    required this.uri,
    required this.type,
  });
}
