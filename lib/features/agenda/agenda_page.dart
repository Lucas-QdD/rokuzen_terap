import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/relogio.dart';
import '../../core/utils/datas.dart';
import '../../data/models/atendimento_detalhado.dart';
import '../auth/auth_controller.dart';
import 'agenda_providers.dart';
import 'agenda_semanal.dart';
import 'status_atendimento_chip.dart';

/// Agenda do terapeuta, na visão diária (RKZ-03) ou semanal (RKZ-04).
class AgendaPage extends ConsumerWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dia = ref.watch(diaSelecionadoProvider);
    final hoje = somenteData(ref.watch(agoraProvider)());
    final visao = ref.watch(visaoAgendaProvider);
    final foraDeHoje = visao == VisaoAgenda.dia
        ? dia != hoje
        : inicioDaSemana(dia) != inicioDaSemana(hoje);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          if (foraDeHoje)
            IconButton(
              tooltip: 'Ir para hoje',
              icon: const Icon(Icons.today),
              onPressed: () => ref.read(diaSelecionadoProvider.notifier).hoje(),
            ),
          TextButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).sair(),
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SegmentedButton<VisaoAgenda>(
              segments: const [
                ButtonSegment(
                  value: VisaoAgenda.dia,
                  label: Text('Dia'),
                  icon: Icon(Icons.view_day_outlined),
                ),
                ButtonSegment(
                  value: VisaoAgenda.semana,
                  label: Text('Semana'),
                  icon: Icon(Icons.view_week_outlined),
                ),
              ],
              selected: {visao},
              showSelectedIcon: false,
              onSelectionChanged: (selecao) => ref
                  .read(visaoAgendaProvider.notifier)
                  .mostrar(selecao.single),
            ),
          ),
          Expanded(
            child: switch (visao) {
              VisaoAgenda.dia => _VisaoDiaria(dia: dia, hoje: hoje),
              VisaoAgenda.semana => VisaoSemanal(dia: dia, hoje: hoje),
            },
          ),
        ],
      ),
    );
  }
}

class _VisaoDiaria extends ConsumerWidget {
  const _VisaoDiaria({required this.dia, required this.hoje});

  final DateTime dia;
  final DateTime hoje;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atendimentos = ref.watch(atendimentosDoDiaProvider(dia));

    return Column(
      children: [
        _SeletorDeDia(dia: dia, hoje: hoje),
        const Divider(height: 1),
        Expanded(
          child: switch (atendimentos) {
            AsyncData(:final value) when value.isEmpty => const _DiaVazio(),
            AsyncData(:final value) => _ListaDoDia(atendimentos: value),
            AsyncError() => const _Aviso(
              icone: Icons.error_outline,
              texto: 'Não foi possível carregar a agenda.',
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}

class _SeletorDeDia extends ConsumerWidget {
  const _SeletorDeDia({required this.dia, required this.hoje});

  final DateTime dia;
  final DateTime hoje;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final relativo = diaRelativo(dia, hoje);
    final notifier = ref.read(diaSelecionadoProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Dia anterior',
            icon: const Icon(Icons.chevron_left),
            onPressed: notifier.anterior,
          ),
          Expanded(
            child: Column(
              children: [
                if (relativo != null)
                  Text(
                    relativo,
                    style: tema.textTheme.labelLarge?.copyWith(
                      color: tema.colorScheme.primary,
                    ),
                  ),
                Text(
                  formatarDiaLongo(dia),
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Próximo dia',
            icon: const Icon(Icons.chevron_right),
            onPressed: notifier.proximo,
          ),
        ],
      ),
    );
  }
}

class _ListaDoDia extends StatelessWidget {
  const _ListaDoDia({required this.atendimentos});

  final List<AtendimentoDetalhado> atendimentos;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: atendimentos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _CartaoAtendimento(item: atendimentos[i]),
    );
  }
}

class _CartaoAtendimento extends StatelessWidget {
  const _CartaoAtendimento({required this.item});

  final AtendimentoDetalhado item;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final atendimento = item.atendimento;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Rotas.atendimento(atendimento.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    formatarHora(atendimento.inicio),
                    style: tema.textTheme.titleMedium,
                  ),
                  Text(
                    formatarHora(atendimento.fim),
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.pacienteNome, style: tema.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(item.unidadeNome, style: tema.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    StatusAtendimentoChip(status: atendimento.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiaVazio extends StatelessWidget {
  const _DiaVazio();

  @override
  Widget build(BuildContext context) => const _Aviso(
    icone: Icons.event_available,
    texto: 'Nenhum atendimento neste dia.',
  );
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: tema.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
