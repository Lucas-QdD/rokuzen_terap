import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import '../../core/relogio.dart';
import '../../core/utils/datas.dart';
import '../../data/models/atendimento_detalhado.dart';
import '../../data/repositories/atendimento_repository.dart';
import '../../data/repositories/sqlite_atendimento_repository.dart';
import '../auth/auth_controller.dart';
import 'agenda_por_dia.dart';

final atendimentoRepositoryProvider = FutureProvider<AtendimentoRepository>(
  (ref) async =>
      SqliteAtendimentoRepository(await ref.watch(databaseProvider.future)),
);

/// Dia exibido na agenda diária (sem horário). Começa em hoje e volta para
/// hoje quando outro terapeuta faz login.
final diaSelecionadoProvider = NotifierProvider<DiaSelecionado, DateTime>(
  DiaSelecionado.new,
);

class DiaSelecionado extends Notifier<DateTime> {
  @override
  DateTime build() {
    ref.watch(terapeutaLogadoIdProvider);
    return _hoje();
  }

  DateTime _hoje() => somenteData(ref.read(agoraProvider)());

  void anterior() => state = DateTime(state.year, state.month, state.day - 1);

  void proximo() => state = DateTime(state.year, state.month, state.day + 1);

  void hoje() => state = _hoje();

  /// Vai para [dia]; aceita os dias em UTC do table_calendar.
  void ir(DateTime dia) => state = somenteData(dia);

  void semanaAnterior() =>
      state = DateTime(state.year, state.month, state.day - 7);

  void proximaSemana() =>
      state = DateTime(state.year, state.month, state.day + 7);
}

enum VisaoAgenda { dia, semana }

/// Visão da agenda (diária ou semanal). Volta para a diária quando outro
/// terapeuta faz login.
final visaoAgendaProvider = NotifierProvider<VisaoAgendaNotifier, VisaoAgenda>(
  VisaoAgendaNotifier.new,
);

class VisaoAgendaNotifier extends Notifier<VisaoAgenda> {
  @override
  VisaoAgenda build() {
    ref.watch(terapeutaLogadoIdProvider);
    return VisaoAgenda.dia;
  }

  void mostrar(VisaoAgenda visao) => state = visao;
}

/// Quantidade de atendimentos por dia da semana de [domingo] (RKZ-04).
final quantidadesDaSemanaProvider = FutureProvider.autoDispose
    .family<Map<DateTime, int>, DateTime>((ref, domingo) async {
      final dias = diasDaSemana(domingo);
      final terapeutaId = ref.watch(terapeutaLogadoIdProvider);
      if (terapeutaId == null) return contarPorDia(const [], dias);
      final repository = await ref.watch(atendimentoRepositoryProvider.future);
      final lista = await repository.listarPorPeriodo(
        terapeutaId,
        dias.first,
        DateTime(dias.last.year, dias.last.month, dias.last.day + 1),
      );
      return contarPorDia(lista, dias);
    });

/// Atendimentos de [dia] do terapeuta logado, em ordem de horário (RKZ-03).
final atendimentosDoDiaProvider = FutureProvider.autoDispose
    .family<List<AtendimentoDetalhado>, DateTime>((ref, dia) async {
      final terapeutaId = ref.watch(terapeutaLogadoIdProvider);
      if (terapeutaId == null) return const [];
      final repository = await ref.watch(atendimentoRepositoryProvider.future);
      final lista = await repository.listarPorPeriodo(
        terapeutaId,
        dia,
        DateTime(dia.year, dia.month, dia.day + 1),
      );
      return agruparPorDia(lista)[dia] ?? const [];
    });

/// Atendimento [id] do terapeuta logado (RKZ-05).
final atendimentoProvider = FutureProvider.autoDispose
    .family<AtendimentoDetalhado?, int>((ref, id) async {
      final terapeutaId = ref.watch(terapeutaLogadoIdProvider);
      if (terapeutaId == null) return null;
      final repository = await ref.watch(atendimentoRepositoryProvider.future);
      return repository.buscarPorId(terapeutaId, id);
    });
