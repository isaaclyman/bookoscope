import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

extension BKXmlStream on Stream<List<XmlEvent>> {
  Future<void> listenForNode(
    String parentName,
    String nodeName,
    void Function(XmlNode element) processFn,
  ) {
    return selectSubtreeEvents((event) =>
            event.parent?.name == parentName && event.name == nodeName)
        .toXmlNodes()
        .expand((element) => element)
        .listen(processFn)
        .asFuture();
  }
}

extension BKXmlNode on XmlNode {
  String? getChildNodeText(String nodeName) {
    return getElement(nodeName)?.innerText;
  }
}
