import 'dart:convert';
import 'dart:io';

class AppConfig {
  final bool offline;

  const AppConfig({required this.offline});

  factory AppConfig.defaults() => const AppConfig(offline: true);

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      offline: json['offline'] == true,
    );
  }

  /// Carga app_config.json buscando en ubicaciones típicas:
  /// 1) junto al ejecutable (Release)
  /// 2) Directory.current (Debug/CLI)
  /// 3) raíz del proyecto Flutter (si current cambió)
  static Future<AppConfig> load() async {
    final paths = _candidatePaths();

    for (final p in paths) {
      final f = File(p);
      if (!await f.exists()) continue;

      try {
        final raw = await f.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return AppConfig.fromJson(decoded);
        }
      } catch (_) {
        // Si está corrupto, sigue buscando otro. Si ninguno sirve, defaults.
      }
    }

    return AppConfig.defaults();
  }

  static List<String> _candidatePaths() {
    final out = <String>{};

    // 1) Junto al ejecutable (Release)
    try {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      out.add('$exeDir${Platform.pathSeparator}app_config.json');
    } catch (_) {}

    // 2) Current working directory (Debug típico)
    final cwd = Directory.current.path;
    out.add('$cwd${Platform.pathSeparator}app_config.json');

    // 3) Si estás ejecutando desde /build/windows/... en debug raro, intenta subir
    // (Flutter project root suele ser donde está pubspec.yaml)
    out.add(Directory.current.uri.resolve('../app_config.json').toFilePath());
    out.add(Directory.current.uri.resolve('../../app_config.json').toFilePath());

    return out.toList();
  }
}