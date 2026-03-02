import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/catalog/logic/catalog_cubit.dart';
import '../features/catalog/logic/catalog_state.dart';

import '../ui/widgets/redsalud_app_bar.dart';
import '../ui/widgets/catalog_search_field.dart';
import '../ui/widgets/print_message_banner.dart';
import '../ui/widgets/catalog_list.dart';

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
    //context.read<CatalogCubit>().load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: RedSaludAppBar(
        title: 'Etiquetas Bodega',
        onRefresh: () => context.read<CatalogCubit>().load(),
      ),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          // Anchos razonables para desktop
          const rightPanelWidth = 460.0;

          return Row(
            children: [
              // Panel izquierdo (búsqueda + mensajes + lista)
              Expanded(
                child: Column(
                  children: [
                    CatalogSearchField(
                      controller: _search,
                      onChanged: (v) =>
                          context.read<CatalogCubit>().setQuery(v),
                    ),
                    const PrintMessageBanner(),
                    const SizedBox(height: 8),
                    Expanded(child: _buildLeftContent(state)),
                  ],
                ),
              ),

              // Separador vertical
              Container(width: 1, color: theme.dividerColor),

              // Panel derecho (preview / acciones)
              SizedBox(
                width: rightPanelWidth,
                child: _PreviewPanelPlaceholder(
                  selectedName: state.selected?.name,
                  selectedCode: state.selected?.code,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftContent(CatalogState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text(state.error!, textAlign: TextAlign.center));
    }

    final items = state.filtered;
    if (items.isEmpty) {
      return const Center(child: Text('Sin resultados.'));
    }

    return CatalogList(items: items, selected: state.selected);
  }
}

class _PreviewPanelPlaceholder extends StatelessWidget {
  final String? selectedName;
  final String? selectedCode;

  const _PreviewPanelPlaceholder({
    required this.selectedName,
    required this.selectedCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Vista previa',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: (selectedCode == null)
                  ? Center(
                      child: Text(
                        'Selecciona un ítem para ver la etiqueta.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          selectedName ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Código: $selectedCode',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        Text(
                          'Preview barcode (siguiente paso)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Acciones futuras (por ahora placeholder)
          ElevatedButton.icon(
            onPressed: selectedCode == null ? null : () {},
            icon: const Icon(Icons.print),
            label: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }
}
