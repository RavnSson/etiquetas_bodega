import 'package:etiquetas_bodega/core/bridges/bridge_paths.dart';
import 'package:etiquetas_bodega/core/bridges/bridge_runner.dart';
import 'package:etiquetas_bodega/features/catalog/models/catalog_item.dart';

class CatalogBridgeDatasource {
  Future<List<CatalogItem>> loadCatalog({required String requestId}) async {
    final json = await BridgeRunner.runJson(
      exePath: BridgePaths.mkBridgeExe(),
      args: ['catalog', '--request-id', requestId],
    );

    final data = json['data'];
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((m) => CatalogItem.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }
}