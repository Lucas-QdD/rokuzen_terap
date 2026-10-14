import 'dart:collection';

import '../../core/utils/datas.dart';
import '../../data/models/atendimento_detalhado.dart';

/// Agrupa os atendimentos pelo dia em que começam (RKZ-03, RKZ-04).
///
/// Os dias ficam em ordem cronológica e, em cada dia, os atendimentos em
/// ordem de início (empate: o que termina antes; depois, o menor id).
/// A chave é a data sem horário. Função pura: não altera [atendimentos].
Map<DateTime, List<AtendimentoDetalhado>> agruparPorDia(
  Iterable<AtendimentoDetalhado> atendimentos,
) {
  final agenda = SplayTreeMap<DateTime, List<AtendimentoDetalhado>>();
  for (final item in atendimentos) {
    agenda
        .putIfAbsent(somenteData(item.atendimento.inicio), () => [])
        .add(item);
  }
  for (final dia in agenda.values) {
    dia.sort(_porHorario);
  }
  return agenda;
}

int _porHorario(AtendimentoDetalhado a, AtendimentoDetalhado b) {
  final x = a.atendimento;
  final y = b.atendimento;
  final porInicio = x.inicio.compareTo(y.inicio);
  if (porInicio != 0) return porInicio;
  final porFim = x.fim.compareTo(y.fim);
  if (porFim != 0) return porFim;
  return x.id.compareTo(y.id);
}
