import 'dart:async';

import 'package:collection/collection.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

extension BKXmlStream on Stream<List<XmlEvent>> {
  StreamSubscription listenForNode(
    String parentName,
    String nodeName,
    void Function(XmlNode element) processFn,
  ) {
    return selectSubtreeEvents((event) =>
            event.parent?.name == parentName && event.name == nodeName)
        .toXmlNodes()
        .expand((element) => element)
        .listen(processFn);
  }
}

extension BKXmlNode on XmlNode {
  String? getChildNodeText(String nodeName) {
    return getElement(nodeName)?.innerText;
  }

  String? getMatchingChildNodeText(
    String nodeName,
    bool Function(XmlElement element) matcher,
  ) {
    return childElements
        .firstWhereOrNull(
          (element) => element.localName == nodeName && matcher(element),
        )
        ?.innerText;
  }

  String? getMatchingChildNodeXml(
    String nodeName,
    bool Function(XmlElement) matcher,
  ) {
    return childElements
        .firstWhereOrNull(
          (element) => element.localName == nodeName && matcher(element),
        )
        ?.innerXml;
  }

  String? getPossiblyNestedChildNodeText(String nodeName, String innerNode) {
    final element = getElement(nodeName);
    if (element == null) {
      return null;
    }

    if (element.childElements.isEmpty) {
      return element.innerText;
    }

    if (element.childElements.length == 1) {
      return element.firstElementChild?.innerText;
    }

    final inner = element.getElement(innerNode);
    return inner?.innerText;
  }

  List<String>? getPossiblyNestedChildNodeTexts(
    String nodeName,
    String innerNode,
  ) {
    final childTexts = childElements
        .where((element) => element.localName == nodeName)
        .map((element) {
          if (element.childElements.isEmpty) {
            return element.innerText;
          }

          if (element.childElements.length == 1) {
            return element.firstElementChild?.innerText;
          }

          final inner = element.getElement(innerNode);
          return inner?.innerText;
        })
        .whereNotNull()
        .where((text) => text.trim().isNotEmpty)
        .toList();
    if (childTexts.isEmpty) {
      return null;
    }

    return childTexts;
  }

  List<String>? getChildrenNodesText(String nodeName) {
    final childTexts = childElements
        .where((element) => element.localName == nodeName)
        .map((element) => element.innerText)
        .where((text) => text.trim().isNotEmpty)
        .toList();
    if (childTexts.isEmpty) {
      return null;
    }

    return childTexts;
  }

  List<String>? getChildrenNodesFirstMatchingAttribute(
    String nodeName,
    List<String> attributeNames,
  ) {
    final childAttributeValues = childElements
        .where((element) => element.localName == nodeName)
        .map((element) {
          for (final attr in attributeNames) {
            final value = element.getAttribute(attr);
            if (value != null) {
              return value;
            }
          }

          return null;
        })
        .whereNotNull()
        .toList();

    if (childAttributeValues.isEmpty) {
      return null;
    }

    return childAttributeValues;
  }
}
