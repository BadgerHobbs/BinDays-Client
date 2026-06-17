import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'ffi/curl_perform.dart';
import 'native_library.dart';
import 'profiles.dart';

/// Headers managed by the transport itself, which must not be forwarded to curl
/// as caller headers (curl computes its own).
const Set<String> _transportHeaders = {'content-length'};

/// A Dio [HttpClientAdapter] that executes requests through the
/// `libcurl-impersonate` shared library, reproducing a real browser's TLS
/// ClientHello (JA3/JA4) and HTTP/2 fingerprint.
///
/// Plug it into a [Dio] instance:
/// ```dart
/// final dio = Dio();
/// dio.httpClientAdapter = ImpersonateAdapter(target: ImpersonateTarget.chrome131);
/// ```
///
/// Each request is performed on a short-lived background isolate, since the
/// underlying `curl_easy_perform` call is blocking.
class ImpersonateAdapter implements HttpClientAdapter {
  ImpersonateAdapter({
    required this.target,
    String? libraryPath,
    this.validateCertificates = true,
    this.defaultTimeout = const Duration(seconds: 30),
  }) : _libraryPath = resolveLibraryPath(explicit: libraryPath);

  /// The browser fingerprint to reproduce.
  final ImpersonateTarget target;

  /// Whether the server's TLS certificate is verified. Defaults to `true`; set
  /// to `false` to mirror curl's `--insecure`.
  final bool validateCertificates;

  /// Timeout applied when the [RequestOptions] specify none.
  final Duration defaultTimeout;

  final String _libraryPath;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body =
        requestStream == null ? null : _joinChunks(await requestStream.toList());

    final headers = <String, String>{};
    options.headers.forEach((key, value) {
      if (_transportHeaders.contains(key.toLowerCase())) return;
      headers[key] = value?.toString() ?? '';
    });

    final timeout = options.receiveTimeout?.isNegative == false &&
            options.receiveTimeout != Duration.zero
        ? options.receiveTimeout!
        : defaultTimeout;

    final request = CurlImpersonateRequest(
      libraryPath: _libraryPath,
      target: target.name,
      url: options.uri.toString(),
      method: options.method,
      headers: headers,
      body: body,
      followRedirects: options.followRedirects,
      maxRedirects: options.maxRedirects,
      timeoutMs: timeout.inMilliseconds <= 0
          ? defaultTimeout.inMilliseconds
          : timeout.inMilliseconds,
      verifyTls: validateCertificates,
    );

    final CurlImpersonateResult result;
    try {
      result = await Isolate.run(() => performImpersonatedRequest(request));
    } on CurlException catch (error) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: error.toString(),
        error: error,
      );
    }

    final responseHeaders = <String, List<String>>{};
    result.headers.forEach((key, value) => responseHeaders[key] = [value]);

    return ResponseBody.fromBytes(
      result.body,
      result.statusCode,
      headers: responseHeaders,
      statusMessage: result.reasonPhrase,
    );
  }

  @override
  void close({bool force = false}) {
    // Nothing to release: each request owns its own curl handle on a transient
    // isolate, which is cleaned up when the request completes.
  }

  static Uint8List _joinChunks(List<Uint8List> chunks) {
    if (chunks.isEmpty) return Uint8List(0);
    if (chunks.length == 1) return chunks.first;
    final builder = BytesBuilder(copy: false);
    for (final chunk in chunks) {
      builder.add(chunk);
    }
    return builder.toBytes();
  }
}
