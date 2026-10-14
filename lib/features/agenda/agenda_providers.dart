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

/// Id do terapeuta logado (`null` sem sessão).
final _terapeutaIdProvider = Provider<int?>(
  (ref) => ref.watch(authControllerProvider.select((a) => a.value?.id)),
);

/// Dia exibido na agenda diária (sem horário). Começa em hoje e volta para
/// hoje quando outro terapeuta faz login.
final diaSelecionadoProvider = NotifierProvider<DiaSelecionado, DateTime>(
  DiaSelecionado.new,
);

class DiaSelecionado extends Notifier<DateTime> {
  @override
  DateTime build() {
    ref.watch(_terapeutaIdProvider);
    return _hoje();
  }

  DateTime _hoje() => somenteData(ref.read(agoraProvider)());

  void anterior() => state = DateTime(state.year, state.month, state.day - 1);

  void proximo() => state = DateTime(state.year, state.month, state.day + 1);

  void hoje() => state = _hoje();
}

/// Atendimentos de [dia] do terapeuta logado, em ordem de horário (RKZ-03).
final atendimentosDoDiaProvider = FutureProvider.autoDispose
    .family<List<AtendimentoDetalhado>, DateTime>((ref, dia) async {
      final terapeutaId = ref.watch(_terapeutaIdProvider);
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
      final terapeutaId = ref.watch(_terapeutaIdProvider);
      if (terapeutaId == null) return null;
      final repository = await ref.watch(atendimentoRepositoryProvider.future);
      return repository.buscarPorId(terapeutaId, id);
    });
