import 'package:flutter/material.dart';

class RedSaludAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onRefresh;

  const RedSaludAppBar({
    super.key,
    required this.title,
    required this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      // 👇 Franja superior institucional
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 4, // grosor de franja
            color: const Color(0xFF00A3B5),
          ),
          const SizedBox(height: kToolbarHeight - 4),
        ],
      ),

      iconTheme: const IconThemeData(color: Color(0xFF00A3B5)),
      actionsIconTheme: const IconThemeData(color: Color(0xFF00A3B5)),

      title: Row(
        children: [
          Image.asset(
            'assets/images/logo_redsalud.png',
            height: 26,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const Text(
            'Etiquetas Bodega',
            style: TextStyle(
              color: Color(0xFF00A3B5),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          tooltip: 'Recargar catálogo',
        ),
      ],
    );
  }
}
