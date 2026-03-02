import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:etiquetas_bodega/features/catalog/logic/catalog_cubit.dart';
import 'package:etiquetas_bodega/features/catalog/models/catalog_item.dart';
import 'package:etiquetas_bodega/features/print/logic/print_cubit.dart';
import 'package:etiquetas_bodega/features/print/logic/print_state.dart';

class CatalogList extends StatelessWidget {
  final List<CatalogItem> items;
  final CatalogItem? selected;

  const CatalogList({super.key, required this.items, required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final it = items[i];
        final isSelected = selected?.code == it.code;

        return Material(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          child: ListTile(
            selected: isSelected,
            selectedTileColor: theme.colorScheme.primary.withValues(
              alpha: 0.08,
            ),
            onTap: () => context.read<CatalogCubit>().selectItem(it),
            title: Text(it.name, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.print),
                  tooltip: 'Imprimir',
                );
              },
            ),
          ),
        );
      },
    );
  }
}
