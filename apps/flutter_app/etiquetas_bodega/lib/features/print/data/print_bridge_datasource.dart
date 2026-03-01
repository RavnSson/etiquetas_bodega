import 'package:etiquetas_bodega/core/bridges/bridge_paths.dart';
import 'package:etiquetas_bodega/core/bridges/bridge_runner.dart';

class PrintBridgeDatasource {
  Future<void> printLabel({
    required String requestId,
    required String code,
    required String name,
    int copies = 1,
  }) async {
    await BridgeRunner.runJson(
      exePath: BridgePaths.printBridgeExe(),
      args: [
        'print',
        '--code',
        code,
        '--name',
        name,
        '--copies',
        copies.toString(),
        '--request-id',
        requestId,
      ],
    );
  }
}