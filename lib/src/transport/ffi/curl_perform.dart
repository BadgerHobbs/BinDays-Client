import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'libcurl_bindings.dart';

/// Request headers that form part of the browser fingerprint and are therefore
/// supplied by `curl_easy_impersonate` (with `default_headers = 1`) rather than
/// by the caller. Mirrors the set used by the BinDays-API test harness so the
/// impersonated headers are never overridden by collector values.
const Set<String> fingerprintHeaders = {
  'user-agent',
  'accept',
  'accept-encoding',
  'accept-language',
  'upgrade-insecure-requests',
  'priority',
  'connection',
  'host',
  'sec-fetch-dest',
  'sec-fetch-mode',
  'sec-fetch-site',
  'sec-fetch-user',
  'sec-ch-ua',
  'sec-ch-ua-mobile',
  'sec-ch-ua-platform',
};

/// A self-contained, isolate-sendable description of one HTTP request to perform
/// through `libcurl-impersonate`. Contains only plain data so it can cross an
/// [Isolate] boundary.
class CurlImpersonateRequest {
  const CurlImpersonateRequest({
    required this.libraryPath,
    required this.target,
    required this.url,
    required this.method,
    required this.headers,
    required this.followRedirects,
    required this.maxRedirects,
    required this.timeoutMs,
    required this.verifyTls,
    this.body,
  });

  final String libraryPath;
  final String target;
  final String url;
  final String method;
  final Map<String, String> headers;
  final Uint8List? body;
  final bool followRedirects;
  final int maxRedirects;
  final int timeoutMs;
  final bool verifyTls;
}

/// The plain-data result of a performed request, sendable back across an
/// [Isolate] boundary.
class CurlImpersonateResult {
  const CurlImpersonateResult({
    required this.statusCode,
    required this.reasonPhrase,
    required this.headers,
    required this.body,
  });

  final int statusCode;
  final String reasonPhrase;
  final Map<String, String> headers;
  final Uint8List body;
}

/// Thrown when a `libcurl` call returns a non-zero CURLcode.
class CurlException implements Exception {
  CurlException(this.operation, this.code);

  final String operation;
  final int code;

  @override
  String toString() => 'CurlException: $operation failed (CURLcode $code)';
}

/// Builds and performs [request] synchronously via `libcurl-impersonate`.
///
/// This blocks on `curl_easy_perform`, so callers should run it off the main
/// isolate (see `ImpersonateAdapter`, which wraps it in [Isolate.run]). The
/// `libcurl` write/header callbacks are invoked synchronously on this thread
/// during `curl_easy_perform`, which is why [ffi.NativeCallable.isolateLocal] is
/// safe here.
CurlImpersonateResult performImpersonatedRequest(CurlImpersonateRequest request) {
  final curl = LibCurl(request.libraryPath);
  final handle = curl.easyInit();
  if (handle == ffi.nullptr) {
    throw CurlException('curl_easy_init', -1);
  }

  final bodyBytes = BytesBuilder(copy: false);
  final headerBytes = BytesBuilder(copy: false);

  final writeCallback = ffi.NativeCallable<CurlIoCallbackNative>.isolateLocal(
    (ffi.Pointer<ffi.Uint8> ptr, int size, int nmemb, ffi.Pointer<ffi.Void> _) {
      final total = size * nmemb;
      bodyBytes.add(Uint8List.fromList(ptr.asTypedList(total)));
      return total;
    },
    exceptionalReturn: 0,
  );
  final headerCallback = ffi.NativeCallable<CurlIoCallbackNative>.isolateLocal(
    (ffi.Pointer<ffi.Uint8> ptr, int size, int nmemb, ffi.Pointer<ffi.Void> _) {
      final total = size * nmemb;
      headerBytes.add(Uint8List.fromList(ptr.asTypedList(total)));
      return total;
    },
    exceptionalReturn: 0,
  );

  ffi.Pointer<ffi.Void> headerList = ffi.nullptr;
  ffi.Pointer<ffi.Uint8> nativeBody = ffi.nullptr;

  try {
    // Apply the browser profile first; any option set afterwards overrides it.
    final target = request.target.toNativeUtf8();
    try {
      final rc = curl.easyImpersonate(handle, target.cast(), 1);
      if (rc != 0) throw CurlException('curl_easy_impersonate', rc);
    } finally {
      malloc.free(target);
    }

    curl.setoptString(handle, CurlOpt.url, request.url);
    // Advertise + transparently decode all supported encodings (curl's
    // --compressed): the impersonated Accept-Encoding header is sent, and the
    // response body is handed back already decompressed.
    curl.setoptString(handle, CurlOpt.acceptEncoding, '');
    if (!request.verifyTls) {
      curl.setoptLong(handle, CurlOpt.sslVerifyPeer, 0);
      curl.setoptLong(handle, CurlOpt.sslVerifyHost, 0);
    }
    curl.setoptLong(handle, CurlOpt.timeoutMs, request.timeoutMs);
    if (request.followRedirects) {
      curl.setoptLong(handle, CurlOpt.followLocation, 1);
      curl.setoptLong(handle, CurlOpt.maxRedirs, request.maxRedirects);
    }

    final method = request.method.toUpperCase();
    final hasBody = request.body != null && request.body!.isNotEmpty;
    if (hasBody) {
      final body = request.body!;
      nativeBody = malloc<ffi.Uint8>(body.length);
      nativeBody.asTypedList(body.length).setAll(0, body);
      // POSTFIELDS does not copy the buffer; it stays referenced until perform
      // completes, so nativeBody is freed only in the finally below.
      curl.setoptLong(handle, CurlOpt.postFieldSize, body.length);
      curl.setoptPtr(handle, CurlOpt.postFields, nativeBody.cast());
    }

    // Set the method explicitly, except for a POST with a body. There,
    // POSTFIELDS already implies POST, and additionally forcing the method to
    // POST would make curl re-issue the request as POST after a 303 redirect
    // (with no body, yielding 411 Length Required), whereas the correct
    // behaviour — matching browsers and Dio — is to GET the redirect target.
    // Other methods (PUT, PATCH, DELETE) still need CUSTOMREQUEST.
    final isPostWithBody = hasBody && method == 'POST';
    if (!isPostWithBody && method != 'GET') {
      curl.setoptString(handle, CurlOpt.customRequest, method);
    }

    for (final entry in request.headers.entries) {
      if (fingerprintHeaders.contains(entry.key.toLowerCase())) continue;
      final line = '${entry.key}: ${entry.value}'.toNativeUtf8();
      try {
        headerList = curl.slistAppend(headerList, line.cast());
      } finally {
        malloc.free(line);
      }
    }
    if (headerList != ffi.nullptr) {
      curl.setoptPtr(handle, CurlOpt.httpHeader, headerList);
    }

    curl.setoptPtr(
        handle, CurlOpt.writeFunction, writeCallback.nativeFunction.cast());
    curl.setoptPtr(
        handle, CurlOpt.headerFunction, headerCallback.nativeFunction.cast());

    final performRc = curl.easyPerform(handle);
    if (performRc != 0) throw CurlException('curl_easy_perform', performRc);

    final infoStatus = curl.getinfoLong(handle, CurlInfo.responseCode);
    final parsed = parseResponseHeaders(headerBytes.toBytes());

    return CurlImpersonateResult(
      statusCode: parsed.statusCode != 0 ? parsed.statusCode : infoStatus,
      reasonPhrase: parsed.reasonPhrase,
      headers: parsed.headers,
      body: bodyBytes.toBytes(),
    );
  } finally {
    if (headerList != ffi.nullptr) curl.slistFreeAll(headerList);
    if (nativeBody != ffi.nullptr) malloc.free(nativeBody);
    curl.easyCleanup(handle);
    writeCallback.close();
    headerCallback.close();
  }
}

/// Parses curl's dumped response headers into a status code, a case-normalised
/// header map (lower-cased keys, comma-joined repeats) and the reason phrase.
///
/// curl emits one header block per response; following redirects accumulates
/// several. Each status line begins a new block, so resetting there keeps only
/// the final response — matching the BinDays-API curl parser. Exposed for unit
/// testing; not part of the public API.
({int statusCode, String reasonPhrase, Map<String, String> headers})
    parseResponseHeaders(Uint8List bytes) {
  var statusCode = 0;
  var reasonPhrase = '';
  final headers = <String, String>{};

  final text = latin1.decode(bytes, allowInvalid: true);
  for (final rawLine in text.split('\n')) {
    final line =
        rawLine.endsWith('\r') ? rawLine.substring(0, rawLine.length - 1) : rawLine;

    if (line.startsWith('HTTP/')) {
      // e.g. "HTTP/1.1 302 Found" (HTTP/2 has no reason phrase).
      final parts = line.split(' ');
      statusCode = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      reasonPhrase = parts.length > 2 ? parts.sublist(2).join(' ').trim() : '';
      headers.clear();
      continue;
    }

    final separator = line.indexOf(':');
    if (separator <= 0) continue;

    final key = line.substring(0, separator).trim().toLowerCase();
    final value = line.substring(separator + 1).trim();
    headers[key] = headers.containsKey(key) ? '${headers[key]},$value' : value;
  }

  return (statusCode: statusCode, reasonPhrase: reasonPhrase, headers: headers);
}
