import 'dart:io';

/// Thrown when the `libcurl-impersonate` shared library cannot be located.
class ImpersonateLibraryNotFoundException implements Exception {
  ImpersonateLibraryNotFoundException(this.searched);

  /// The candidate paths that were tried, in order.
  final List<String> searched;

  @override
  String toString() =>
      'ImpersonateLibraryNotFoundException: could not find the '
      'libcurl-impersonate shared library. Set the BINDAYS_IMPERSONATE_LIB '
      'environment variable to its path, pass `libraryPath:` to '
      'ImpersonateAdapter, or run `dart run bindays_client:install`.\n'
      'Searched:\n  ${searched.join('\n  ')}';
}

/// The canonical (unversioned) shared-library file name for this platform, used
/// for the bare-name OS-loader fallback.
String _canonicalLibraryName() {
  if (Platform.isWindows) return 'libcurl-impersonate.dll';
  if (Platform.isMacOS) return 'libcurl-impersonate.dylib';
  return 'libcurl-impersonate.so';
}

/// Whether [base] is a `libcurl-impersonate` shared-library file name for this
/// platform. Matches versioned variants too (the Linux/macOS releases ship the
/// real library as e.g. `libcurl-impersonate.so.4.8.0`, with `.so` / `.so.4` as
/// symlinks), while excluding the `.a`/`.la` static-library siblings.
bool _matchesLibrary(String base) {
  if (Platform.isWindows) return base == 'libcurl-impersonate.dll';
  if (Platform.isMacOS) {
    return base.startsWith('libcurl-impersonate') && base.endsWith('.dylib');
  }
  return base.startsWith('libcurl-impersonate.so');
}

/// Searches [dir] (optionally [recursive]) for matching library files that
/// resolve to an existing file (following symlinks), preferring the shortest
/// base name — i.e. the unversioned `.so`/`.dylib` soname over a versioned file.
String? _findLibraryIn(Directory dir, {required bool recursive}) {
  if (!dir.existsSync()) return null;

  final List<FileSystemEntity> entities;
  try {
    entities = dir.listSync(recursive: recursive, followLinks: false);
  } on FileSystemException {
    // Some directories (e.g. an app sandbox's root on Android) can't be listed;
    // treat them as having no match rather than crashing the search.
    return null;
  }

  final matches = <String>[];
  for (final entity in entities) {
    final base = _baseName(entity.path);
    // Match by name regardless of entity type so symlinks (Link, not File) are
    // considered; existsSync() follows the link and confirms a real target.
    if (_matchesLibrary(base) && File(entity.path).existsSync()) {
      matches.add(entity.path);
    }
  }
  if (matches.isEmpty) return null;

  matches.sort((a, b) => _baseName(a).length.compareTo(_baseName(b).length));
  return matches.first;
}

/// Base directories searched for a bundled library: the current working
/// directory, the directory containing the running executable, and that
/// directory's parent. The executable-relative entries matter when the host app
/// is a compiled binary launched with an unrelated working directory.
List<String> _baseDirectories() {
  // A Set so an executable launched from the current directory doesn't yield
  // duplicate entries (and duplicate directory scans).
  final dirs = <String>{Directory.current.path};

  try {
    final exeFile = File(Platform.resolvedExecutable);
    final exeDir = exeFile.parent;
    dirs
      ..add(exeDir.path)
      ..add(exeDir.parent.path);
  } catch (_) {
    // resolvedExecutable can be unavailable in some embedded contexts.
  }

  return dirs.toList();
}

String _join(String dir, String name) => '$dir${Platform.pathSeparator}$name';

/// Resolves the path to the `libcurl-impersonate` shared library.
///
/// Resolution order:
/// 1. [explicit], if provided and existing.
/// 2. The `BINDAYS_IMPERSONATE_LIB` environment variable, if set and existing.
/// 3. A bundled copy under the current directory or its `.native/` folder.
///
/// If none match, the bare platform library name is returned so the OS loader
/// can resolve it via `PATH` / `LD_LIBRARY_PATH` / rpath. Throws
/// [ImpersonateLibraryNotFoundException] only when [requireExisting] is true and
/// nothing is found.
String resolveLibraryPath({String? explicit, bool requireExisting = false}) {
  final searched = <String>[];

  if (explicit != null) {
    if (File(explicit).existsSync()) return explicit;
    searched.add(explicit);
  }

  final envPath = Platform.environment['BINDAYS_IMPERSONATE_LIB'];
  if (envPath != null && envPath.isNotEmpty) {
    if (File(envPath).existsSync()) return envPath;
    searched.add(envPath);
  }

  // On Android the library ships inside the APK and is loaded by soname; on iOS
  // it is statically linked into the app executable (resolved via
  // DynamicLibrary.process(), so the path is unused). Either way there is no
  // file to find — skip the filesystem scan and return the bare name.
  if (Platform.isAndroid || Platform.isIOS) {
    return _canonicalLibraryName();
  }

  for (final dir in _baseDirectories()) {
    // Direct hit in the base directory.
    final direct = _findLibraryIn(Directory(dir), recursive: false);
    if (direct != null) return direct;
    searched.add(dir);

    // The install script extracts into `.native/` with a nested layout (e.g.
    // `.native/bin/` on Windows), so search it recursively as a fallback.
    final nativeDir = Directory(_join(dir, '.native'));
    if (nativeDir.existsSync()) {
      searched.add('${nativeDir.path} (recursive)');
      final nested = _findLibraryIn(nativeDir, recursive: true);
      if (nested != null) return nested;
    }
  }

  if (requireExisting) {
    throw ImpersonateLibraryNotFoundException(searched);
  }

  // Fall back to the bare name and let the OS loader find it.
  return _canonicalLibraryName();
}

String _baseName(String path) =>
    path.split(Platform.pathSeparator).last.split('/').last;
