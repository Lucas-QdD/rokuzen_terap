import 'package:flutter/material.dart';

import '../../data/models/atendimento.dart';

/// Etiqueta colorida com a situação do atendimento.
class StatusAtendimentoChip extends StatelessWidget {
  const StatusAtendimentoChip({super.key, required this.status});

  final StatusAtendimento status;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final (fundo, texto) = switch (status) {
      StatusAtendimento.agendado => (
        cores.primaryContainer,
        cores.onPrimaryContainer,
      ),
      StatusAtendimento.realizado => (
        cores.secondaryContainer,
        cores.onSecondaryContainer,
      ),
      StatusAtendimento.cancelado => (
        cores.surfaceContainerHighest,
        cores.onSurfaceVariant,
      ),
      StatusAtendimento.falta => (cores.errorContainer, cores.onErrorContainer),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          status.rotulo,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: texto),
        ),
      ),
    );
  }
}
