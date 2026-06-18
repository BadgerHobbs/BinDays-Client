/// Browser TLS/JA3 + HTTP/2 impersonation transport for the BinDays client.
///
/// [Client] uses [ImpersonateAdapter] by default, so most callers never need
/// this library directly. It is exported for advanced use — e.g. selecting a
/// different [ImpersonateTarget], or wiring the adapter onto a separately
/// managed [Dio] instance.
///
/// The adapter routes Dio requests through the `libcurl-impersonate` shared
/// library (via `dart:ffi`), reproducing a real browser's TLS ClientHello
/// (cipher/extension order, ALPS, certificate compression, ...) and HTTP/2
/// settings — the transport-layer fingerprint that pure-Dart HTTP clients
/// cannot control, and which some councils' WAFs inspect.
library;

export 'src/transport/impersonate_adapter.dart' show ImpersonateAdapter;
export 'src/transport/native_library.dart'
    show resolveLibraryPath, ImpersonateLibraryNotFoundException;
export 'src/transport/profiles.dart' show ImpersonateTarget;
