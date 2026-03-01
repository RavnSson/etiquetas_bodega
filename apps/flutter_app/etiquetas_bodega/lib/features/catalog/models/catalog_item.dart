class CatalogItem {
  final String code;
  final String name;
  final String source;

  const CatalogItem({
    required this.code,
    required this.name,
    required this.source,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
    );
  }
}