import 'package:bookoscope/util/xml.dart';
import 'package:xml/xml.dart';

/// In-memory representation of an XML <feed> document received from an
/// OPDS endpoint.
class OPDSFeed {
  final String id;
  final String url;
  final String updated;
  final String? title;
  final List<OPDSLink>? links;
  final List<OPDSEntry>? entries;

  const OPDSFeed({
    required this.id,
    required this.url,
    required this.updated,
    required this.title,
    required this.links,
    required this.entries,
  });

  @override
  String toString() {
    return <String, String>{
      '\$type': 'OPDSFeed',
      'id': id,
      'updated': updated,
      'title': title ?? 'NULL',
      'links': links?.map((l) => l.toString()).join('\n') ?? 'NULL',
      'entries': entries?.map((e) => e.toString()).join('\n') ?? 'NULL',
    }.toString();
  }
}

/// In-memory representation of an XML <entry> element found in an OPDS
/// document.
class OPDSEntry {
  final String id;
  final String updated;
  final String? title;
  final String? author;
  final String? summary;
  final String? extent;
  final String? format;
  final List<String>? categories;
  final List<OPDSLink>? links;

  final String? htmlContent;
  final String? textContent;

  OPDSEntry.fromXML(XmlNode node)
      : id = node.getChildNodeText('id') ?? '',
        updated = node.getChildNodeText('updated') ?? '',
        title = node.getChildNodeText('title'),
        author = node.getPossiblyNestedChildNodeText('author', 'name'),
        summary = node.getChildNodeText('summary'),
        extent = node.getChildNodeText('extent'),
        format = node.getChildNodeText('format'),
        categories = node.getChildrenNodesText('category') ??
            node.getChildrenNodesFirstMatchingAttribute(
                'category', ['label', 'term']),
        htmlContent = node.getMatchingChildNodeXml(
          'content',
          (element) =>
              element.getAttribute('type')?.toLowerCase().contains('html') ??
              false,
        ),
        textContent = node.getMatchingChildNodeText(
          'content',
          (element) =>
              element.getAttribute('type')?.toLowerCase().contains('text') ??
              true,
        ),
        links = node.childElements
            .where((node) => node.localName == 'link')
            .map((node) => OPDSLink.fromXML(node))
            .toList();

  @override
  String toString() {
    return <String, String>{
      '\$type': 'OPDSEntry',
      'id': id,
      'updated': updated,
      'title': title ?? 'NULL',
      'summary': summary ?? 'NULL',
      'extent': extent ?? 'NULL',
      'format': format ?? 'NULL',
      'links': links?.map((l) => l.toString()).join('\n') ?? 'NULL',
    }.toString();
  }
}

/// In-memory representation of an XML <link> element found in an OPDS
/// document, as a child of either the root <feed> element or an
/// <entry> element.
class OPDSLink {
  final String rel;
  final String href;
  final String? type;
  final String? title;

  OPDSLink.fromXML(XmlNode node)
      : rel = node.getAttribute('rel') ?? '',
        href = node.getAttribute('href') ?? '',
        type = node.getAttribute('type'),
        title = node.getAttribute('title');

  @override
  String toString() {
    return <String, String>{
      '\$type': 'OPDSLink',
      'rel': rel,
      'href': href,
      'type': type ?? 'NULL',
      'title': title ?? 'NULL',
    }.toString();
  }
}
