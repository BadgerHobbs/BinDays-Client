extension UriExtension on Uri {
  /// Adds a path segment to the end of the URI. Prevents double slashes.
  ///
  /// If the provided [path] is already absolute (starts with '/'), it will replace the existing path.
  /// Otherwise, it will be appended to the existing path.  Double slashes are removed from the
  /// resulting path.
  ///
  /// Example:
  ///
  /// ```dart
  /// final uri = Uri.parse('https://example.com/api');
  /// final newUri = uri.add('users'); // Result: https://example.com/api/users
  ///
  /// final uri2 = Uri.parse('https://example.com/api');
  /// final newUri2 = uri2.add('/users'); // Result: https://example.com/users
  ///
  /// final uri3 = Uri.parse('https://example.com/api/');
  /// final newUri3 = uri3.add('users'); // Result: https://example.com/api/users
  /// ```
  Uri add(String path) {
    // Combine paths with slash
    final newPath = [this.path, path].join('/');

    // Remove multiple slashes
    final cleanedPath = newPath.replaceAll(RegExp(r'//+'), '/');

    return replace(path: cleanedPath);
  }
}
