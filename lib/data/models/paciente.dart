/// Linha da tabela `paciente`. Dado pessoal (LGPD): não registrar em logs.
class Paciente {
  const Paciente({
    required this.id,
    required this.terapeutaId,
    required this.nome,
    required this.telefone,
    required this.criadoEm,
    this.email,
    this.dataNascimento,
    this.observacoes,
  });

  final int id;
  final int terapeutaId;
  final String nome;
  final String telefone;
  final String? email;

  /// Somente a data (gravada como `aaaa-mm-dd`).
  final DateTime? dataNascimento;
  final String? observacoes;
  final DateTime criadoEm;

  factory Paciente.fromMap(Map<String, Object?> map) {
    final nascimento = map['data_nascimento'] as String?;
    return Paciente(
      id: map['id']! as int,
      terapeutaId: map['terapeuta_id']! as int,
      nome: map['nome']! as String,
      telefone: map['telefone']! as String,
      email: map['email'] as String?,
      dataNascimento: nascimento == null ? null : DateTime.parse(nascimento),
      observacoes: map['observacoes'] as String?,
      criadoEm: DateTime.parse(map['criado_em']! as String),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'terapeuta_id': terapeutaId,
    'nome': nome,
    'telefone': telefone,
    'email': email,
    'data_nascimento': dataSemHorario(dataNascimento),
    'observacoes': observacoes,
    'criado_em': criadoEm.toIso8601String(),
  };
}

/// Dados de um paciente ainda não cadastrado, já validados e normalizados.
class NovoPaciente {
  const NovoPaciente({
    required this.nome,
    required this.telefone,
    this.email,
    this.dataNascimento,
    this.observacoes,
  });

  final String nome;
  final String telefone;
  final String? email;
  final DateTime? dataNascimento;
  final String? observacoes;
}

/// [data] como `aaaa-mm-dd` (formato da coluna `data_nascimento`).
String? dataSemHorario(DateTime? data) =>
    data?.toIso8601String().substring(0, 10);
