import 'atendimento.dart';

/// Atendimento com os nomes do paciente e da unidade, para exibir na agenda
/// e no detalhe sem consultas extras.
class AtendimentoDetalhado {
  const AtendimentoDetalhado({
    required this.atendimento,
    required this.pacienteNome,
    required this.unidadeNome,
  });

  final Atendimento atendimento;
  final String pacienteNome;
  final String unidadeNome;

  /// Lê uma linha de `atendimento` com as colunas extras `paciente_nome` e
  /// `unidade_nome`.
  factory AtendimentoDetalhado.fromMap(Map<String, Object?> map) =>
      AtendimentoDetalhado(
        atendimento: Atendimento.fromMap(map),
        pacienteNome: map['paciente_nome']! as String,
        unidadeNome: map['unidade_nome']! as String,
      );
}
