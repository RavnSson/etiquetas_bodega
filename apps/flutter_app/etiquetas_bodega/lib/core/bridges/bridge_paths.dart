import 'dart:io';

class BridgePaths {
  static String mkBridgeExe() => _resolve(
        releaseRelative: r'bridges\mk_bridge.exe',
        devRelativeFromRepo: r'bridges\mk_bridge\dist\mk_bridge.exe',
      );

  static String printBridgeExe() => _resolve(
        releaseRelative: r'bridges\print_bridge.exe',
        devRelativeFromRepo: r'bridges\print_bridge\dist\print_bridge.exe',
      );

  static String _resolve({
    required String releaseRelative,
    required String devRelativeFromRepo,
  }) {
    // 1) Release: relativo al ejecutable actual (o al cwd)
    final release = _cwdResolve(releaseRelative);
    if (File(release).existsSync()) return release;

    // 2) Dev: repoRoot = subir 3 niveles desde ...\apps\flutter_app\etiquetas_bodega
    final cwd = Directory.current.uri;
    final repoRoot = cwd.resolve('../').resolve('../').resolve('../');
    final dev = repoRoot.resolve(devRelativeFromRepo.replaceAll(r'\', '/'))
        .toFilePath(windows: true);

    return dev;
  }

  static String _cwdResolve(String relWindowsPath) {
    final cwd = Directory.current.uri;
    final p = cwd.resolve(relWindowsPath.replaceAll(r'\', '/'));
    return p.toFilePath(windows: true);
  }
}