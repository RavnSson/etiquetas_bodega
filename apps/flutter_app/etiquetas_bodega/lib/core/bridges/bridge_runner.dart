import 'dart:convert';
import 'dart:io';

class BridgeRunner {
  static Future<Map<String, dynamic>> runJson({
    required String exePath,
    required List<String> args,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final result = await Process.run(exePath, args, runInShell: false)
        .timeout(timeout);

    final stdoutStr = (result.stdout ?? '').toString().trim();
    final stderrStr = (result.stderr ?? '').toString().trim();

    if (stdoutStr.isEmpty) {
      throw BridgeContractException(
        code: 'EMPTY_STDOUT',
        message: 'El bridge no devolvió JSON por STDOUT.',
        details: stderrStr.isEmpty ? null : stderrStr,
        exitCode: result.exitCode,
      );
    }

    Map<String, dynamic> jsonMap;
    try {
      final decoded = json.decode(stdoutStr);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('STDOUT JSON no es un objeto');
      }
      jsonMap = decoded;
    } catch (e) {
      throw BridgeContractException(
        code: 'INVALID_JSON',
        message: 'El bridge devolvió JSON inválido.',
        details: 'stdout=$stdoutStr | stderr=$stderrStr | err=$e',
        exitCode: result.exitCode,
      );
    }

    final ok = jsonMap['ok'] == true;

    // Contrato inconsistente: exitCode!=0 pero ok=true
    if (result.exitCode != 0 && ok) {
      throw BridgeContractException(
        code: 'EXITCODE_MISMATCH',
        message: 'exitCode != 0 pero ok=true (contrato roto).',
        details:
            'exitCode=${result.exitCode} stdout=$stdoutStr stderr=$stderrStr',
        exitCode: result.exitCode,
      );
    }

    if (!ok) {
      final err = jsonMap['error'] is Map<String, dynamic>
          ? (jsonMap['error'] as Map<String, dynamic>)
          : <String, dynamic>{};

      throw BridgeBridgeException(
        code: (err['code'] ?? 'BRIDGE_ERROR').toString(),
        message: (err['message'] ?? 'Error del bridge').toString(),
        details: err['details']?.toString(),
        exitCode: result.exitCode,
        payload: jsonMap,
      );
    }

    return jsonMap;
  }
}

class BridgeContractException implements Exception {
  final String code;
  final String message;
  final String? details;
  final int exitCode;

  BridgeContractException({
    required this.code,
    required this.message,
    this.details,
    required this.exitCode,
  });

  @override
  String toString() => 'BridgeContractException($code): $message';
}

class BridgeBridgeException implements Exception {
  final String code;
  final String message;
  final String? details;
  final int exitCode;
  final Map<String, dynamic> payload;

  BridgeBridgeException({
    required this.code,
    required this.message,
    this.details,
    required this.exitCode,
    required this.payload,
  });

  @override
  String toString() => 'BridgeBridgeException($code): $message';
}