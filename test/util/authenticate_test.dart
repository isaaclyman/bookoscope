import 'package:bookoscope/util/authenticate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("parseAuthenticateHeader", () {
    test('Understands a Basic scheme with no params', () {
      final result = parseAuthenticateHeader('Basic');
      expect(result.scheme, "basic");
    });

    test('Understands a Basic scheme with one param', () {
      final result = parseAuthenticateHeader('Basic realm="Access site"');
      expect(result.scheme, "basic");
      expect(result.realm, "Access site");
    });

    test('Understands a Basic scheme with multiple params', () {
      final result = parseAuthenticateHeader(
        'Basic realm="Access site", charset="UTF-8", foo=bar',
      );
      expect(result.scheme, "basic");
      expect(result.realm, "Access site");
    });

    test('Understands a Digest scheme with params', () {
      final result = parseAuthenticateHeader('''
Digest
    realm="my site",
    qop="auth, auth-int",
    algorithm=MD5,
    nonce="7ypf/xlj9XXwfDPEoM4URrv/xwf94BcCAzFZH4GiTo0v",
    opaque="FQhe/qaU925kfnzjCev0ciny7QMkPqMAFRtzCUYo5tdS"
''');
      expect(result.scheme, "digest");
      expect(result.realm, "my site");
      expect(result.algorithm, "MD5");
      expect(result.nonce, "7ypf/xlj9XXwfDPEoM4URrv/xwf94BcCAzFZH4GiTo0v");
    });
  });
}
