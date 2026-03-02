import 'package:etiquetas_bodega/core/bridges/bridge_paths.dart';
import 'package:etiquetas_bodega/core/bridges/bridge_runner.dart';
import 'package:etiquetas_bodega/core/config/app_config.dart';
import 'package:etiquetas_bodega/features/catalog/models/catalog_item.dart';

class CatalogBridgeDatasource {
  final AppConfig config;

  CatalogBridgeDatasource(this.config);

  Future<List<CatalogItem>> loadCatalog({required String requestId}) async {
    final args = <String>[
      'catalog',
      if (config.offline) '--offline',
      '--request-id',
      requestId,
    ];

    final json = await BridgeRunner.runJson(
      exePath: BridgePaths.mkBridgeExe(),
      args: args,
    );

    final data = json['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((m) => CatalogItem.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }
}