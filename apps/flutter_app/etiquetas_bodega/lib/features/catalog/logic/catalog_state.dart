import 'package:etiquetas_bodega/features/catalog/models/catalog_item.dart';

class CatalogState {
  final bool isLoading;
  final String query;
  final List<CatalogItem> all;
  final CatalogItem? selected;
  final String? error;

  const CatalogState({
    required this.isLoading,
    required this.query,
    required this.all,
    required this.selected,
    required this.error,
  });

  factory CatalogState.initial() => const CatalogState(
    isLoading: false,
    query: '',
    all: [],
    selected: null,
    error: null,
  );

  CatalogState copyWith({
    bool? isLoading,
    String? query,
    List<CatalogItem>? all,
    CatalogItem? selected,
    String? error,
  }) {
    return CatalogState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      all: all ?? this.all,
      selected: selected ?? this.selected,
      error: error,
    );
  }

  List<CatalogItem> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;

    return all.where((x) {
      return x.code.toLowerCase().contains(q) ||
          x.name.toLowerCase().contains(q);
    }).toList();
  }
}
