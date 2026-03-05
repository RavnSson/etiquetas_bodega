import 'package:etiquetas_bodega/core/bridges/bridge_paths.dart';
import 'package:etiquetas_bodega/core/bridges/bridge_runner.dart';
import 'package:etiquetas_bodega/core/config/app_config.dart';

class PrintBridgeDatasource {
  final AppConfig config;

  PrintBridgeDatasource(this.config);

  Future<void> printLabel({
    required String requestId,
    required String code,
    required String name,
    int copies = 1,
  }) async {
    final args = <String>[
      'print',
      '--code',
      code,
      '--name',
      name,
      '--copies',
      copies.toString(),
      '--request-id',
      requestId,
    ];

    final printer = config.printerName?.trim();
    if (printer != null && printer.isNotEmpty) {
      args.addAll(['--printer', printer]);
    }

    await BridgeRunner.runJson(
      exePath: config.printBridgePath ?? BridgePaths.printBridgeExe(),
      args: args,
    );
  }
}
