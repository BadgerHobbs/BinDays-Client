// Downloads the libcurl-impersonate shared library for the current desktop
// platform and extracts it under `.native/`, then prints the resolved library
// path. Used to provision the impersonate transport for `dart`/`dart test`
// runs (e.g. the BinDays-API integration tests on Windows/Linux).
//
// The binary is fetched from this repository's own GitHub Release (published by
// the `publish-native-libs` workflow), so consumers never depend on the
// upstream curl-impersonate project at build time. The version is pinned in
// `native_libs.version`; mobile (Android/iOS) binaries are bundled by the app
// build instead and do not use this script.
//
// Usage:
//   dart run bindays_client:install            # pinned version + default dest
//   dart run bindays_client:install <version> <destDir>
//
// Requires network access and the system `tar` (bsdtar ships with Windows 10
// 1803+, Linux and macOS).
import 'dart:ffi' show Abi;
import 'dart:io';

/// Fallback version, used if `native_libs.version` cannot be located next to
/// this script. Keep in sync with `native_libs.version`.
const String _fallbackVersion = '2.0.0a5';
const String _repo = 'BadgerHobbs/BinDays-Client';

/// The `libcurl-impersonate` release asset suffix for each supported desktop
/// ABI. Mobile ABIs are intentionally excluded — they are bundled by the app.
const Map<Abi, String> _assetSuffixByAbi = {
  Abi.windowsX64: 'x86_64-win32',
  Abi.windowsArm64: 'arm64-win32',
  Abi.macosX64: 'x86_64-macos',
  Abi.macosArm64: 'arm64-macos',
  Abi.linuxX64: 'x86_64-linux-gnu',
  Abi.linuxArm64: 'aarch64-linux-gnu',
};

/// Whether [base] is a `libcurl-impersonate` shared-library file name for this
/// platform. Matches versioned variants (the Linux/macOS releases ship the real
/// library as e.g. `libcurl-impersonate.so.4.8.0`, with `.so`/`.so.4` symlinks)
/// while excluding the `.a`/`.la` static-library siblings.
bool _matchesLibrary(String base) {
  if (Platform.isWindows) return base == 'libcurl-impersonate.dll';
  if (Platform.isMacOS) {
    return base.startsWith('libcurl-impersonate') && base.endsWith('.dylib');
  }
  return base.startsWith('libcurl-impersonate.so');
}

Future<void> main(List<String> args) async {
  final version = args.isNotEmpty ? args[0] : _resolveVersion();
  final destDir = Directory(args.length > 1 ? args[1] : '.native');

  final suffix = _assetSuffixByAbi[Abi.current()];
  if (suffix == null) {
    stderr.writeln('Unsupported platform: ${Abi.current()}');
    exitCode = 1;
    return;
  }

  final asset = 'libcurl-impersonate-v$version.$suffix.tar.gz';
  final url = Uri.parse(
      'https://github.com/$_repo/releases/download/native-v$version/$asset');

  destDir.createSync(recursive: true);

  // Reuse an existing extracted copy if present.
  final existing = _findLibrary(destDir);
  if (existing != null) {
    stdout.writeln(existing);
    return;
  }

  stderr.writeln('Downloading $url');
  final archive = File('${destDir.path}${Platform.pathSeparator}$asset');
  await _download(url, archive);

  stderr.writeln('Extracting ${archive.path}');
  // Run from the dest dir with a relative archive name so tar does not read a
  // Windows drive-letter colon as a remote host.
  final ProcessResult result;
  try {
    result = Process.runSync(
      'tar',
      ['-xzf', asset],
      workingDirectory: destDir.path,
    );
  } on ProcessException catch (e) {
    stderr.writeln(
        'Failed to run "tar" (is it installed and on PATH?): ${e.message}');
    exitCode = 1;
    return;
  }
  if (result.exitCode != 0) {
    stderr.writeln('tar failed: ${result.stderr}');
    exitCode = 1;
    return;
  }
  archive.deleteSync();

  final library = _findLibrary(destDir);
  if (library == null) {
    stderr.writeln('Could not find the shared library after extraction.');
    exitCode = 1;
    return;
  }

  stdout.writeln(library);
}

/// Reads the pinned version from `native_libs.version` next to this script,
/// falling back to [_fallbackVersion] if it cannot be located.
String _resolveVersion() {
  try {
    // bin/install.dart -> <package root>/native_libs.version
    final scriptDir = File.fromUri(Platform.script).parent;
    for (final candidate in [
      File('${scriptDir.path}/../native_libs.version'),
      File('${scriptDir.parent.path}/native_libs.version'),
    ]) {
      if (candidate.existsSync()) {
        return candidate.readAsStringSync().trim();
      }
    }
  } catch (_) {
    // Fall through to the constant.
  }
  return _fallbackVersion;
}

String? _findLibrary(Directory root) {
  if (!root.existsSync()) return null;

  final List<FileSystemEntity> entities;
  try {
    entities = root.listSync(recursive: true, followLinks: false);
  } on FileSystemException {
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

  // Prefer the shortest base name — the unversioned `.so`/`.dylib` soname.
  matches.sort((a, b) => _baseName(a).length.compareTo(_baseName(b).length));
  return matches.first;
}

String _baseName(String path) =>
    path.split(Platform.pathSeparator).last.split('/').last;

Future<void> _download(Uri url, File destination) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('GET $url -> ${response.statusCode}');
    }
    await response.pipe(destination.openWrite());
  } finally {
    client.close();
  }
}
