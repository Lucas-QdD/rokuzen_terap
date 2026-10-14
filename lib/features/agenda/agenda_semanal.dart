import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/utils/datas.dart';
import 'agenda_por_dia.dart';
import 'agenda_providers.dart';

/// Agenda semanal (RKZ-04): quantidade de atendimentos em cada dia da semana.
/// Tocar num dia abre a agenda diária daquele dia.
class VisaoSemanal extends ConsumerWidget {
  const VisaoSemanal({super.key, required this.dia, required this.hoje});

  /// Dia selecionado; a semana exibida é a que o contém.
  final DateTime dia;
  final DateTime hoje;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domingo = inicioDaSemana(dia);
    final quantidades = ref.watch(quantidadesDaSemanaProvider(domingo));
    final contagem = quantidades.value ?? const <DateTime, int>{};
    final diaNotifier = ref.read(diaSelecionadoProvider.notifier);

    void abrirDia(DateTime selecionado) {
      diaNotifier.ir(selecionado);
      ref.read(visaoAgendaProvider.notifier).mostrar(VisaoAgenda.dia);
    }

    return Column(
      children: [
        _CabecalhoSemana(
          dia: dia,
          estaSemana: domingo == inicioDaSemana(hoje),
          onAnterior: diaNotifier.semanaAnterior,
          onProxima: diaNotifier.proximaSemana,
        ),
        TableCalendar<void>(
          locale: 'pt_BR',
          // O table_calendar trabalha com datas em UTC; os callbacks
          // passam por somenteData antes de chegar à agenda.
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2035, 12, 31),
          focusedDay: DateTime.utc(dia.year, dia.month, dia.day),
          currentDay: DateTime.utc(hoje.year, hoje.month, hoje.day),
          calendarFormat: CalendarFormat.week,
          availableCalendarFormats: const {CalendarFormat.week: 'Semana'},
          startingDayOfWeek: StartingDayOfWeek.sunday,
          headerVisible: false,
          rowHeight: 56,
          selectedDayPredicate: (d) => isSameDay(d, dia),
          onDaySelected: (selecionado, _) => abrirDia(selecionado),
          onPageChanged: diaNotifier.ir,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, d, _) {
              final quantidade = contagem[somenteData(d)] ?? 0;
              return quantidade == 0 ? null : _Marcador(quantidade);
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: quantidades.hasError
              ? const Center(child: Text('Não foi possível carregar a semana.'))
              // Sempre 7 itens: Column monta todos de uma vez.
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final d in diasDaSemana(dia))
                        ListTile(
                          selected: d == hoje,
                          title: Text(formatarDiaLongo(d)),
                          subtitle: Text(
                            contagem.containsKey(d)
                                ? descreverQuantidade(contagem[d]!)
                                : '…',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => abrirDia(d),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _CabecalhoSemana extends StatelessWidget {
  const _CabecalhoSemana({
    required this.dia,
    required this.estaSemana,
    required this.onAnterior,
    required this.onProxima,
  });

  final DateTime dia;
  final bool estaSemana;
  final VoidCallback onAnterior;
  final VoidCallback onProxima;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Semana anterior',
            icon: const Icon(Icons.chevron_left),
            onPressed: onAnterior,
          ),
          Expanded(
            child: Column(
              children: [
                if (estaSemana)
                  Text(
                    'Esta semana',
                    style: tema.textTheme.labelLarge?.copyWith(
                      color: tema.colorScheme.primary,
                    ),
                  ),
                Text(
                  formatarSemana(dia),
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Próxima semana',
            icon: const Icon(Icons.chevron_right),
            onPressed: onProxima,
          ),
        ],
      ),
    );
  }
}

/// Número de atendimentos sobre o dia no calendário.
class _Marcador extends StatelessWidget {
  const _Marcador(this.quantidade);

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: cores.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$quantidade',
          style: TextStyle(color: cores.onPrimary, fontSize: 11),
        ),
      ),
    );
  }
}
