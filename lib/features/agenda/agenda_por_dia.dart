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

/// Quantidade de atendimentos em cada um dos [dias] (RKZ-04), na ordem
/// recebida e com zero nos dias vazios. Atendimentos fora de [dias] são
/// ignorados. Conta todas as situações, como a agenda do dia exibe.
Map<DateTime, int> contarPorDia(
  Iterable<AtendimentoDetalhado> atendimentos,
  Iterable<DateTime> dias,
) {
  final agenda = agruparPorDia(atendimentos);
  return {
    for (final dia in dias.map(somenteData)) dia: agenda[dia]?.length ?? 0,
  };
}

/// Texto da quantidade, ex.: `Nenhum atendimento`, `1 atendimento`.
String descreverQuantidade(int quantidade) => switch (quantidade) {
  0 => 'Nenhum atendimento',
  1 => '1 atendimento',
  _ => '$quantidade atendimentos',
};

int _porHorario(AtendimentoDetalhado a, AtendimentoDetalhado b) {
  final x = a.atendimento;
  final y = b.atendimento;
  final porInicio = x.inicio.compareTo(y.inicio);
  if (porInicio != 0) return porInicio;
  final porFim = x.fim.compareTo(y.fim);
  if (porFim != 0) return porFim;
  return x.id.compareTo(y.id);
}
