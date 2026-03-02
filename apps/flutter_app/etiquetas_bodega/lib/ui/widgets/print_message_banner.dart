import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/print/logic/print_cubit.dart';
import '../../features/print/logic/print_state.dart';

class PrintMessageBanner extends StatelessWidget {
  const PrintMessageBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintCubit, PrintState>(
      builder: (context, ps) {
        final msg = ps.error ?? ps.lastOk;
        if (msg == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(msg, maxLines: 2, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}
