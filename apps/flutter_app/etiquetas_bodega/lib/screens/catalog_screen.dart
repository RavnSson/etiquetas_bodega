import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/catalog/logic/catalog_cubit.dart';
import '../features/catalog/logic/catalog_state.dart';
import '../features/print/logic/print_cubit.dart';
import '../features/print/logic/print_state.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CatalogCubit>().load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etiquetas Bodega'),
        actions: [
          IconButton(
            onPressed: () => context.read<CatalogCubit>().load(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar catálogo',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged: (v) => context.read<CatalogCubit>().setQuery(v),
              decoration: const InputDecoration(
                labelText: 'Buscar (código o nombre)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          BlocBuilder<PrintCubit, PrintState>(
            builder: (context, ps) {
              final msg = ps.error ?? ps.lastOk;
              if (msg == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(msg, maxLines: 2, overflow: TextOverflow.ellipsis),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<CatalogCubit, CatalogState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(
                    child: Text(state.error!, textAlign: TextAlign.center),
                  );
                }

                final items = state.filtered;
                if (items.isEmpty) {
                  return const Center(child: Text('Sin resultados.'));
                }

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final it = items[i];
                    return ListTile(
                      title: Text(
                        it.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${it.code} • ${it.source}'),
                      trailing: BlocBuilder<PrintCubit, PrintState>(
                        builder: (context, ps) {
                          final busy = ps.isPrinting;
                          return IconButton(
                            onPressed: busy
                                ? null
                                : () => context.read<PrintCubit>().printNow(
                                    code: it.code,
                                    name: it.name,
                                    copies: 1,
                                  ),
                            icon: busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.print),
                            tooltip: 'Imprimir',
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
