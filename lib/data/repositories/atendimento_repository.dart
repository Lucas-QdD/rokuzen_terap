import '../models/atendimento_detalhado.dart';

/// Consulta dos atendimentos do terapeuta (RKZ-03, RKZ-05).
abstract interface class AtendimentoRepository {
  /// Atendimentos de [terapeutaId] que começam em `[de, ate)`, em ordem de
  /// horário.
  Future<List<AtendimentoDetalhado>> listarPorPeriodo(
    int terapeutaId,
    DateTime de,
    DateTime ate,
  );

  /// Atendimento [id], se pertencer a [terapeutaId]; senão, `null`.
  Future<AtendimentoDetalhado?> buscarPorId(int terapeutaId, int id);
}
