import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'ui/theme/app_theme.dart';
import 'screens/catalog_screen.dart';

import 'features/catalog/data/catalog_bridge_datasource.dart';
import 'features/catalog/logic/catalog_cubit.dart';

import 'features/print/data/print_bridge_datasource.dart';
import 'features/print/logic/print_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await AppConfig.load();

  runApp(EtiquetasBodegaApp(config: config));
}

class EtiquetasBodegaApp extends StatelessWidget {
  final AppConfig config;

  const EtiquetasBodegaApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CatalogCubit(CatalogBridgeDatasource(config)),
        ),
        BlocProvider(
          create: (_) => PrintCubit(PrintBridgeDatasource()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const CatalogScreen(),
      ),
    );
  }
}