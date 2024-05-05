class WWWAuthenticateOption {
  final String scheme;
  final String? realm;
  final String? nonce;
  final String? algorithm;

  WWWAuthenticateOption({
    required this.scheme,
    this.realm,
    this.nonce,
    this.algorithm,
  });
}

WWWAuthenticateOption parseAuthenticateHeader(String headerValue) {
  headerValue = headerValue.trim();
  final whitespaceRx = RegExp(r"\s");
  final scheme = headerValue
      .substring(
          0,
          headerValue.contains(whitespaceRx)
              ? headerValue.indexOf(whitespaceRx)
              : null)
      .toLowerCase();
  final keyValueRx = RegExp('([a-zA-Z0-9]+)="?([^,"]+)"?');
  final matches = keyValueRx.allMatches(headerValue);
  final valueMap = {for (var match in matches) match.group(1): match.group(2)};
  return WWWAuthenticateOption(
    scheme: scheme,
    realm: valueMap['realm'],
    nonce: valueMap['nonce'],
    algorithm: valueMap['algorithm'],
  );
}
