/// A browser fingerprint that `libcurl-impersonate` knows how to reproduce.
///
/// The [name] is passed verbatim to `curl_easy_impersonate`, so it must match
/// one of the targets supported by the linked `libcurl-impersonate` build (the
/// same identifiers accepted by the `--impersonate` flag of the command line
/// tool, e.g. `chrome131`).
class ImpersonateTarget {
  /// Creates a target for the given `curl-impersonate` identifier.
  const ImpersonateTarget(this.name);

  /// The `curl-impersonate` target identifier (e.g. `chrome131`).
  final String name;

  /// Chrome 131 on desktop. Matches the target used by the BinDays-API tests.
  static const ImpersonateTarget chrome131 = ImpersonateTarget('chrome131');

  /// Resolves a target from its identifier. Any name accepted by the linked
  /// `libcurl-impersonate` build is valid; unknown names fail later, when
  /// `curl_easy_impersonate` rejects them.
  factory ImpersonateTarget.fromName(String name) => ImpersonateTarget(name);

  @override
  String toString() => 'ImpersonateTarget($name)';

  @override
  bool operator ==(Object other) =>
      other is ImpersonateTarget && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
