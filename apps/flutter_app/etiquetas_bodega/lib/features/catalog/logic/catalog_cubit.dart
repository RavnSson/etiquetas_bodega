import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'catalog_state.dart';
import '../data/catalog_bridge_datasource.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final CatalogBridgeDatasource _ds;

  CatalogCubit(this._ds) : super(CatalogState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));

    final requestId = _reqId('cat');
    try {
      final items = await _ds.loadCatalog(requestId: requestId);
      emit(state.copyWith(isLoading: false, all: items, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void setQuery(String q) => emit(state.copyWith(query: q, error: null));

  String _reqId(String prefix) {
    final r = Random().nextInt(999999).toString().padLeft(6, '0');
    return '$prefix-$r';
  }
}