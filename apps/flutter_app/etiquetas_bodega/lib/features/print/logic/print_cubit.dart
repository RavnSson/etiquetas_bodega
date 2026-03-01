import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/print_bridge_datasource.dart';
import 'print_state.dart';

class PrintCubit extends Cubit<PrintState> {
  final PrintBridgeDatasource _ds;

  PrintCubit(this._ds) : super(PrintState.initial());

  Future<void> printNow({
    required String code,
    required String name,
    int copies = 1,
  }) async {
    emit(state.copyWith(isPrinting: true, lastOk: null, error: null));

    final requestId = _reqId('prt');
    try {
      await _ds.printLabel(
        requestId: requestId,
        code: code,
        name: name,
        copies: copies,
      );
      emit(state.copyWith(
        isPrinting: false,
        lastOk: 'Impreso: $code',
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isPrinting: false,
        lastOk: null,
        error: e.toString(),
      ));
    }
  }

  String _reqId(String prefix) {
    final r = Random().nextInt(999999).toString().padLeft(6, '0');
    return '$prefix-$r';
  }
}