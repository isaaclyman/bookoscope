class OPDSFeed {
  String updated;
  String id;
  String? title;
  List<OPDSLink>? links;

  OPDSFeed({
    required this.updated,
    required this.id,
    this.title,
    this.links,
  });
}

class OPDSEntry {
  String updated;
  String id;
  String? title;
  String? summary;
  String? extent;
  String? format;
  List<OPDSLink>? links;

  OPDSEntry({
    required this.updated,
    required this.id,
    this.title,
    this.summary,
    this.extent,
    this.format,
    this.links,
  });
}

class OPDSLink {
  String rel;
  String href;
  String? type;
  String? title;

  OPDSLink({
    required this.rel,
    required this.href,
    this.type,
    this.title,
  });
}
