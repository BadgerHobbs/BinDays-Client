import 'dart:convert';
import 'dart:typed_data';

import 'package:bindays_client/transport.dart';
import 'package:bindays_client/src/transport/ffi/curl_perform.dart';
import 'package:test/test.dart';

void main() {
  group('ImpersonateTarget', () {
    test('chrome131 has the expected name', () {
      expect(ImpersonateTarget.chrome131.name, 'chrome131');
    });

    test('fromName round-trips and compares by value', () {
      expect(ImpersonateTarget.fromName('chrome131'),
          equals(ImpersonateTarget.chrome131));
      expect(ImpersonateTarget.fromName('ff117'),
          isNot(equals(ImpersonateTarget.chrome131)));
    });
  });

  group('fingerprintHeaders', () {
    test('covers the browser-supplied headers', () {
      expect(fingerprintHeaders, contains('user-agent'));
      expect(fingerprintHeaders, contains('accept'));
      expect(fingerprintHeaders, contains('sec-ch-ua'));
      expect(fingerprintHeaders, contains('accept-encoding'));
    });

    test('does not claim collector-specific headers', () {
      expect(fingerprintHeaders, isNot(contains('content-type')));
      expect(fingerprintHeaders, isNot(contains('cookie')));
      expect(fingerprintHeaders, isNot(contains('referer')));
    });
  });

  group('parseResponseHeaders', () {
    Uint8List bytes(String s) => Uint8List.fromList(latin1.encode(s));

    test('parses status, reason phrase and headers', () {
      final result = parseResponseHeaders(bytes(
        'HTTP/1.1 200 OK\r\n'
        'Content-Type: text/html\r\n'
        'Set-Cookie: a=1\r\n'
        '\r\n',
      ));

      expect(result.statusCode, 200);
      expect(result.reasonPhrase, 'OK');
      expect(result.headers['content-type'], ['text/html']);
      expect(result.headers['set-cookie'], ['a=1']);
    });

    test('keeps only the final block after redirects', () {
      final result = parseResponseHeaders(bytes(
        'HTTP/1.1 302 Found\r\n'
        'Location: /next\r\n'
        '\r\n'
        'HTTP/1.1 200 OK\r\n'
        'Content-Type: application/json\r\n'
        '\r\n',
      ));

      expect(result.statusCode, 200);
      expect(result.headers.containsKey('location'), isFalse);
      expect(result.headers['content-type'], ['application/json']);
    });

    test('preserves repeated headers as a list', () {
      final result = parseResponseHeaders(bytes(
        'HTTP/1.1 200 OK\r\n'
        'Set-Cookie: a=1\r\n'
        'Set-Cookie: b=2\r\n'
        '\r\n',
      ));

      expect(result.headers['set-cookie'], ['a=1', 'b=2']);
    });

    test('handles HTTP/2 status lines with no reason phrase', () {
      final result = parseResponseHeaders(bytes(
        'HTTP/2 204\r\n'
        '\r\n',
      ));

      expect(result.statusCode, 204);
      expect(result.reasonPhrase, '');
    });
  });
}
