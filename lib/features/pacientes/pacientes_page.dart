import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../data/models/paciente.dart';
import 'pacientes_providers.dart';

/// Lista dos pacientes do terapeuta, com acesso ao cadastro (RKZ-06).
class PacientesPage extends ConsumerWidget {
  const PacientesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pacientes = ref.watch(pacientesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Rotas.novoPaciente),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Cadastrar paciente'),
      ),
      body: switch (pacientes) {
        AsyncData(:final value) when value.isEmpty => const Center(
          child: Text('Nenhum paciente cadastrado.'),
        ),
        AsyncData(:final value) => _Lista(pacientes: value),
        AsyncError() => const Center(
          child: Text('Não foi possível carregar os pacientes.'),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.pacientes});

  final List<Paciente> pacientes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // Espaço no fim para o botão flutuante não cobrir o último paciente.
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: pacientes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final paciente = pacientes[i];
        return ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(paciente.nome),
          subtitle: Text(paciente.telefone),
        );
      },
    );
  }
}
