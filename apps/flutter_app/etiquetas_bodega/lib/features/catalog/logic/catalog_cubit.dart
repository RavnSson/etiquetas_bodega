import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'catalog_state.dart';
import '../data/catalog_bridge_datasource.dart';
import '../models/catalog_item.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final CatalogBridgeDatasource _ds;

  CatalogCubit(this._ds) : super(CatalogState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));

    final requestId = _reqId('cat');

    try {
      final List<CatalogItem> items = await _ds.loadCatalog(
        requestId: requestId,
      );

      // Mantener selección si aún existe
      CatalogItem? keepSelected = state.selected;
      if (keepSelected != null) {
        final match = items.where((x) => x.code == keepSelected!.code);
        keepSelected = match.isEmpty ? null : match.first;
      }

      emit(
        state.copyWith(
          isLoading: false,
          all: items,
          selected: keepSelected,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void setQuery(String q) {
    emit(state.copyWith(query: q, error: null));
  }

  void selectItem(CatalogItem item) {
    emit(state.copyWith(selected: item));
  }

  void clearSelection() {
    emit(state.copyWith(selected: null));
  }

  String _reqId(String prefix) {
    final r = Random().nextInt(999999).toString().padLeft(6, '0');
    return '$prefix-$r';
  }
}
