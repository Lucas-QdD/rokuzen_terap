import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';

/// Tela inicial após o login. A agenda do dia (RKZ-03) entra aqui.
class AgendaPage extends ConsumerWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terapeuta = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).sair(),
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
      body: Center(
        child: Text(
          terapeuta == null ? '' : 'Olá, ${terapeuta.nome}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
