import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/datas.dart';
import '../../data/models/atendimento_detalhado.dart';
import 'agenda_providers.dart';
import 'status_atendimento_chip.dart';

/// Detalhe do atendimento (RKZ-05).
class AtendimentoPage extends ConsumerWidget {
  const AtendimentoPage({super.key, required this.id});

  /// Id do atendimento; `null` quando a rota tem um id inválido.
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = this.id;
    final atendimento = id == null
        ? const AsyncData<AtendimentoDetalhado?>(null)
        : ref.watch(atendimentoProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Atendimento')),
      body: switch (atendimento) {
        AsyncData(:final value?) => _Detalhe(item: value),
        AsyncData() => const Center(child: Text('Atendimento não encontrado.')),
        AsyncError() => const Center(
          child: Text('Não foi possível carregar o atendimento.'),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Detalhe extends StatelessWidget {
  const _Detalhe({required this.item});

  final AtendimentoDetalhado item;

  @override
  Widget build(BuildContext context) {
    final a = item.atendimento;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _Campo(Icons.person_outline, 'Paciente', Text(item.pacienteNome)),
        _Campo(Icons.event_outlined, 'Data', Text(formatarDiaLongo(a.inicio))),
        _Campo(
          Icons.schedule,
          'Horário',
          Text('${formatarHora(a.inicio)} – ${formatarHora(a.fim)}'),
        ),
        _Campo(Icons.timelapse, 'Duração', Text(formatarDuracao(a.duracao))),
        _Campo(Icons.place_outlined, 'Unidade', Text(item.unidadeNome)),
        _Campo(Icons.spa_outlined, 'Tipo', Text(a.tipo.rotulo)),
        _Campo(
          Icons.flag_outlined,
          'Situação',
          Align(
            alignment: Alignment.centerLeft,
            child: StatusAtendimentoChip(status: a.status),
          ),
        ),
      ],
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo(this.icone, this.rotulo, this.valor);

  final IconData icone;
  final String rotulo;
  final Widget valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListTile(
      leading: Icon(icone),
      title: Text(rotulo, style: tema.textTheme.labelMedium),
      subtitle: DefaultTextStyle.merge(
        style: tema.textTheme.bodyLarge,
        child: valor,
      ),
    );
  }
}
