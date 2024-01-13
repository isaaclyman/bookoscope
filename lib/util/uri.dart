Uri joinUri(String baseUri, String relativeUri) {
  return Uri.parse(joinUriString(baseUri, relativeUri));
}

String joinUriString(String baseUri, String relativeUri) {
  if (relativeUri.startsWith('/')) {
    return joinUriString(baseUri, relativeUri.substring(1));
  }

  if (baseUri.endsWith('/')) {
    return joinUriString(baseUri.substring(0, baseUri.length - 1), relativeUri);
  }

  return '$baseUri/$relativeUri';
}
