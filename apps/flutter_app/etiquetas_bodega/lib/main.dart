import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ui/theme/app_theme.dart';
import 'screens/catalog_screen.dart';

import 'features/catalog/data/catalog_bridge_datasource.dart';
import 'features/catalog/logic/catalog_cubit.dart';

import 'features/print/data/print_bridge_datasource.dart';
import 'features/print/logic/print_cubit.dart';

void main() {
  runApp(const EtiquetasBodegaApp());
}

class EtiquetasBodegaApp extends StatelessWidget {
  const EtiquetasBodegaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CatalogCubit(CatalogBridgeDatasource())),
        BlocProvider(create: (_) => PrintCubit(PrintBridgeDatasource())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const CatalogScreen(),
      ),
    );
  }
}