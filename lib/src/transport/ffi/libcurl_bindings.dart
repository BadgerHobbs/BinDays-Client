import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

/// Minimal `dart:ffi` binding to the handful of `libcurl` / `libcurl-impersonate`
/// symbols this package needs.
///
/// Only the options used by `ImpersonateAdapter` are wired up. `curl_easy_setopt`
/// and `curl_easy_getinfo` are variadic in C; they are bound here through
/// [ffi.VarArgs] typed wrappers (one per argument type) so the calling
/// convention is correct on every platform, rather than relying on the
/// "non-variadic with a fixed extra argument" trick.
// CURLoption type bases (see curl.h). The numeric value of an option is the
// base for its argument type plus the option's ordinal.
const int _curloptLong = 0;
const int _curloptObjectPoint = 10000;
const int _curloptFunctionPoint = 20000;
// STRINGPOINT, SLISTPOINT and CBPOINT all share the OBJECTPOINT base.

/// CURLoption values used by this package.
abstract final class CurlOpt {
  static const int url = _curloptObjectPoint + 2;
  static const int writeFunction = _curloptFunctionPoint + 11;
  static const int writeData = _curloptObjectPoint + 1;
  static const int postFields = _curloptObjectPoint + 15;
  static const int httpHeader = _curloptObjectPoint + 23;
  static const int headerData = _curloptObjectPoint + 29;
  static const int customRequest = _curloptObjectPoint + 36;
  static const int nobody = _curloptLong + 44;
  static const int post = _curloptLong + 47;
  static const int followLocation = _curloptLong + 52;
  static const int postFieldSize = _curloptLong + 60;
  static const int sslVerifyPeer = _curloptLong + 64;
  static const int maxRedirs = _curloptLong + 68;
  static const int headerFunction = _curloptFunctionPoint + 79;
  static const int httpGet = _curloptLong + 80;
  static const int sslVerifyHost = _curloptLong + 81;
  static const int acceptEncoding = _curloptObjectPoint + 102;
  static const int timeoutMs = _curloptLong + 155;
}

/// CURLINFO values used by this package (see curl.h: `CURLINFO_LONG = 0x200000`).
abstract final class CurlInfo {
  static const int responseCode = 0x200000 + 2;
}

/// `CURL_GLOBAL_DEFAULT` (`CURL_GLOBAL_SSL | CURL_GLOBAL_WIN32`).
const int curlGlobalDefault = 3;

// --- Native signatures -------------------------------------------------------

typedef _GlobalInitNative = ffi.Int32 Function(ffi.Long flags);
typedef _GlobalInitDart = int Function(int flags);

typedef _EasyInitNative = ffi.Pointer<ffi.Void> Function();

typedef _EasyCleanupNative = ffi.Void Function(ffi.Pointer<ffi.Void> handle);
typedef _EasyCleanupDart = void Function(ffi.Pointer<ffi.Void> handle);

typedef _EasyPerformNative = ffi.Int32 Function(ffi.Pointer<ffi.Void> handle);
typedef _EasyPerformDart = int Function(ffi.Pointer<ffi.Void> handle);

typedef _EasyImpersonateNative = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> handle,
  ffi.Pointer<ffi.Char> target,
  ffi.Int defaultHeaders,
);
typedef _EasyImpersonateDart = int Function(
  ffi.Pointer<ffi.Void> handle,
  ffi.Pointer<ffi.Char> target,
  int defaultHeaders,
);

typedef _SlistAppendNative = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> list,
  ffi.Pointer<ffi.Char> value,
);
typedef _SlistAppendDart = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> list,
  ffi.Pointer<ffi.Char> value,
);

typedef _SlistFreeAllNative = ffi.Void Function(ffi.Pointer<ffi.Void> list);
typedef _SlistFreeAllDart = void Function(ffi.Pointer<ffi.Void> list);

typedef _SetoptLongNative = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> handle,
  ffi.Int32 option,
  ffi.VarArgs<(ffi.Long,)>,
);
typedef _SetoptLongDart = int Function(
  ffi.Pointer<ffi.Void> handle,
  int option,
  int value,
);

typedef _SetoptPtrNative = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> handle,
  ffi.Int32 option,
  ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>,
);
typedef _SetoptPtrDart = int Function(
  ffi.Pointer<ffi.Void> handle,
  int option,
  ffi.Pointer<ffi.Void> value,
);

typedef _GetinfoLongNative = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> handle,
  ffi.Int32 info,
  ffi.VarArgs<(ffi.Pointer<ffi.Long>,)>,
);
typedef _GetinfoLongDart = int Function(
  ffi.Pointer<ffi.Void> handle,
  int info,
  ffi.Pointer<ffi.Long> value,
);

/// Native signature of a `libcurl` write/header callback:
/// `size_t cb(char* ptr, size_t size, size_t nmemb, void* userdata)`.
typedef CurlIoCallbackNative = ffi.Size Function(
  ffi.Pointer<ffi.Uint8> ptr,
  ffi.Size size,
  ffi.Size nmemb,
  ffi.Pointer<ffi.Void> userdata,
);

/// Loads `libcurl-impersonate` and exposes the symbols this package uses.
class LibCurl {
  LibCurl(String path) : _lib = _load(path) {
    _globalInit = _lib
        .lookupFunction<_GlobalInitNative, _GlobalInitDart>('curl_global_init');
    easyInit = _lib
        .lookupFunction<_EasyInitNative, ffi.Pointer<ffi.Void> Function()>(
            'curl_easy_init');
    easyCleanup = _lib
        .lookupFunction<_EasyCleanupNative, _EasyCleanupDart>(
            'curl_easy_cleanup');
    easyPerform = _lib
        .lookupFunction<_EasyPerformNative, _EasyPerformDart>(
            'curl_easy_perform');
    easyImpersonate =
        _lib.lookupFunction<_EasyImpersonateNative, _EasyImpersonateDart>(
            'curl_easy_impersonate');
    slistAppend = _lib
        .lookupFunction<_SlistAppendNative, _SlistAppendDart>(
            'curl_slist_append');
    slistFreeAll = _lib
        .lookupFunction<_SlistFreeAllNative, _SlistFreeAllDart>(
            'curl_slist_free_all');
    _setoptLong = _lib
        .lookupFunction<_SetoptLongNative, _SetoptLongDart>('curl_easy_setopt');
    _setoptPtr = _lib
        .lookupFunction<_SetoptPtrNative, _SetoptPtrDart>('curl_easy_setopt');
    _getinfoLong = _lib
        .lookupFunction<_GetinfoLongNative, _GetinfoLongDart>(
            'curl_easy_getinfo');

    _globalInit(curlGlobalDefault);
  }

  /// Opens the library for the current platform.
  ///
  /// On iOS the library ships as a dynamic framework embedded in the app
  /// bundle. Because nothing references its symbols at link time (FFI resolves
  /// them at runtime), the linker does not load it at launch, so its symbols
  /// are not in the process's global table — [ffi.DynamicLibrary.process] can't
  /// find them. Open the embedded framework explicitly by its bundle-relative
  /// path instead; dyld resolves it from the app's Frameworks directory.
  /// Everywhere else (desktop, Android) the library is a real shared object
  /// opened by path or soname.
  static ffi.DynamicLibrary _load(String path) {
    if (Platform.isIOS) {
      return ffi.DynamicLibrary.open(
          'libcurl-impersonate.framework/libcurl-impersonate');
    }
    return ffi.DynamicLibrary.open(path);
  }

  final ffi.DynamicLibrary _lib;

  late final int Function(int) _globalInit;
  late final ffi.Pointer<ffi.Void> Function() easyInit;
  late final void Function(ffi.Pointer<ffi.Void>) easyCleanup;
  late final int Function(ffi.Pointer<ffi.Void>) easyPerform;
  late final int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>, int)
      easyImpersonate;
  late final ffi.Pointer<ffi.Void> Function(
      ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>) slistAppend;
  late final void Function(ffi.Pointer<ffi.Void>) slistFreeAll;
  late final _SetoptLongDart _setoptLong;
  late final _SetoptPtrDart _setoptPtr;
  late final _GetinfoLongDart _getinfoLong;

  /// Sets a `long`-typed option, returning the CURLcode.
  int setoptLong(ffi.Pointer<ffi.Void> handle, int option, int value) =>
      _setoptLong(handle, option, value);

  /// Sets a pointer-typed option (string, slist, function or data pointer).
  int setoptPtr(
    ffi.Pointer<ffi.Void> handle,
    int option,
    ffi.Pointer<ffi.Void> value,
  ) =>
      _setoptPtr(handle, option, value);

  /// Sets a string option, copying [value] into a temporary native buffer that
  /// remains alive for the duration of the call (curl copies string options).
  int setoptString(ffi.Pointer<ffi.Void> handle, int option, String value) {
    final native = value.toNativeUtf8();
    try {
      return _setoptPtr(handle, option, native.cast());
    } finally {
      malloc.free(native);
    }
  }

  /// Reads a `long`-typed info value (e.g. the response status code).
  int getinfoLong(ffi.Pointer<ffi.Void> handle, int info) {
    final out = malloc<ffi.Long>();
    try {
      _getinfoLong(handle, info, out);
      return out.value;
    } finally {
      malloc.free(out);
    }
  }
}
