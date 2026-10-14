/// Tipo do atendimento. O nome do valor é o gravado no banco.
enum TipoAtendimento {
  clinica('Clínica'),
  particular('Particular');

  const TipoAtendimento(this.rotulo);

  /// Texto exibido na tela.
  final String rotulo;
}

/// Situação do atendimento. O nome do valor é o gravado no banco.
enum StatusAtendimento {
  agendado('Agendado'),
  realizado('Realizado'),
  cancelado('Cancelado'),
  falta('Falta');

  const StatusAtendimento(this.rotulo);

  /// Texto exibido na tela.
  final String rotulo;
}

/// Linha da tabela `atendimento`.
///
/// [inicio] e [fim] são horários locais, gravados em ISO-8601 sem fuso.
class Atendimento {
  const Atendimento({
    required this.id,
    required this.terapeutaId,
    required this.pacienteId,
    required this.unidadeId,
    required this.inicio,
    required this.fim,
    required this.tipo,
    required this.status,
    this.observacao,
    this.disponibilidadeId,
  });

  final int id;
  final int terapeutaId;
  final int pacienteId;
  final int unidadeId;
  final DateTime inicio;
  final DateTime fim;
  final TipoAtendimento tipo;
  final StatusAtendimento status;
  final String? observacao;
  final int? disponibilidadeId;

  Duration get duracao => fim.difference(inicio);

  factory Atendimento.fromMap(Map<String, Object?> map) => Atendimento(
    id: map['id']! as int,
    terapeutaId: map['terapeuta_id']! as int,
    pacienteId: map['paciente_id']! as int,
    unidadeId: map['unidade_id']! as int,
    inicio: DateTime.parse(map['inicio']! as String),
    fim: DateTime.parse(map['fim']! as String),
    tipo: TipoAtendimento.values.byName(map['tipo']! as String),
    status: StatusAtendimento.values.byName(map['status']! as String),
    observacao: map['observacao'] as String?,
    disponibilidadeId: map['disponibilidade_id'] as int?,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'terapeuta_id': terapeutaId,
    'paciente_id': pacienteId,
    'unidade_id': unidadeId,
    'inicio': inicio.toIso8601String(),
    'fim': fim.toIso8601String(),
    'tipo': tipo.name,
    'status': status.name,
    'observacao': observacao,
    'disponibilidade_id': disponibilidadeId,
  };
}
