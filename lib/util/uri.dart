Uri joinUri(String baseUri, String relativeUri) {
  if (relativeUri.startsWith('/')) {
    return joinUri(baseUri, relativeUri.substring(1));
  }

  final baseSegments = baseUri.split('/');
  baseSegments.removeLast();
  final normalizedBaseUri = baseSegments.join('/');

  return Uri.parse('$normalizedBaseUri/$relativeUri');
}
