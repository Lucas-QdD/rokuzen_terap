import 'package:sqflite/sqflite.dart';

import '../utils/password_hasher.dart';

/// Credenciais do login de demonstração (RKZ-07).
const String demoEmail = 'terapeuta@rokuzen.com';
const String demoSenha = 'rokuzen123';

/// Unidades reais da Rokuzen usadas na demonstração: nome do shopping e cidade.
///
/// O endereço fica nulo até ser confirmado pela Rokuzen.
const List<Map<String, String?>> unidadesDemo = [
  {'nome': 'Golden Square — São Bernardo do Campo', 'endereco': null},
  {'nome': 'Grand Plaza — Santo André', 'endereco': null},
  {'nome': 'Mooca Plaza — São Paulo', 'endereco': null},
  {'nome': 'West Plaza — São Paulo', 'endereco': null},
];

/// Pacientes fictícios (nomes e telefones inventados).
const List<Map<String, String?>> _pacientesDemo = [
  {
    'nome': 'Mariana Souza',
    'telefone': '(11) 98765-4321',
    'email': 'mariana.souza@exemplo.com',
    'data_nascimento': '1988-04-12',
    'observacoes': 'Tensão na região cervical.',
  },
  {
    'nome': 'Carlos Henrique Lima',
    'telefone': '(11) 97654-3210',
    'email': null,
    'data_nascimento': '1975-09-30',
    'observacoes': 'Prefere pressão moderada.',
  },
  {
    'nome': 'Fernanda Oliveira',
    'telefone': '(11) 96543-2109',
    'email': 'fernanda.oliveira@exemplo.com',
    'data_nascimento': null,
    'observacoes': null,
  },
  {
    'nome': 'Roberto Takahashi',
    'telefone': '(11) 95432-1098',
    'email': null,
    'data_nascimento': '1962-01-05',
    'observacoes': 'Dor lombar crônica.',
  },
  {
    'nome': 'Juliana Pereira',
    'telefone': '(11) 94321-0987',
    'email': 'juliana.pereira@exemplo.com',
    'data_nascimento': '1993-11-21',
    'observacoes': null,
  },
  {
    'nome': 'Paulo Nakamura',
    'telefone': '(11) 93210-9876',
    'email': null,
    'data_nascimento': null,
    'observacoes': null,
  },
];

/// Quantidade de atendimentos por dia, ciclando a partir de 7 dias atrás.
/// Inclui dias vazios para demonstrar o aviso de agenda vazia (RKZ-03).
const List<int> _atendimentosPorDia = [2, 3, 0, 4, 1, 3, 2];

/// Horários de início possíveis em um dia (hora, minuto).
const List<(int, int)> _horarios = [
  (9, 0),
  (10, 30),
  (13, 0),
  (14, 30),
  (16, 0),
  (17, 30),
];

const int _diasAntes = 7;
const int _diasDepois = 13;

/// Popula o banco com os dados de demonstração (RKZ-07).
///
/// Idempotente: se o terapeuta de demonstração já existir, não faz nada.
/// Os atendimentos são gerados em torno de [hoje] (padrão: data atual) para
/// que a agenda sempre tenha dados passados e futuros.
Future<void> seedDemoData(DatabaseExecutor db, {DateTime? hoje}) async {
  final existente = await db.query(
    'terapeuta',
    columns: ['id'],
    where: 'email = ?',
    whereArgs: [demoEmail],
    limit: 1,
  );
  if (existente.isNotEmpty) return;

  final agora = hoje ?? DateTime.now();
  final dataBase = DateTime(agora.year, agora.month, agora.day);

  final unidadeIds = <int>[];
  for (final unidade in unidadesDemo) {
    unidadeIds.add(await db.insert('unidade', unidade));
  }

  final salt = PasswordHasher.gerarSalt();
  final terapeutaId = await db.insert('terapeuta', {
    'nome': 'Terapeuta Demonstração',
    'email': demoEmail,
    'senha_hash': PasswordHasher.hash(demoSenha, salt),
    'senha_salt': salt,
    'telefone': '(11) 90000-0000',
  });

  for (final unidadeId in unidadeIds) {
    await db.insert('terapeuta_unidade', {
      'terapeuta_id': terapeutaId,
      'unidade_id': unidadeId,
    });
  }

  final criadoEm = dataBase
      .subtract(const Duration(days: 30))
      .toIso8601String();
  final pacienteIds = <int>[];
  for (final paciente in _pacientesDemo) {
    pacienteIds.add(
      await db.insert('paciente', {
        ...paciente,
        'terapeuta_id': terapeutaId,
        'criado_em': criadoEm,
      }),
    );
  }

  var sequencia = 0;
  for (var offset = -_diasAntes; offset <= _diasDepois; offset++) {
    final dia = DateTime(dataBase.year, dataBase.month, dataBase.day + offset);
    final indiceDia = offset + _diasAntes;
    final quantidade =
        _atendimentosPorDia[indiceDia % _atendimentosPorDia.length];
    final unidadeId = unidadeIds[indiceDia % unidadeIds.length];

    for (var i = 0; i < quantidade; i++) {
      final (hora, minuto) = _horarios[i];
      final inicio = DateTime(dia.year, dia.month, dia.day, hora, minuto);
      final duracao = Duration(minutes: sequencia % 3 == 0 ? 90 : 60);
      final fim = inicio.add(duracao);

      await db.insert('atendimento', {
        'terapeuta_id': terapeutaId,
        'paciente_id': pacienteIds[sequencia % pacienteIds.length],
        'unidade_id': unidadeId,
        'inicio': inicio.toIso8601String(),
        'fim': fim.toIso8601String(),
        'tipo': sequencia % 5 == 4 ? 'particular' : 'clinica',
        'status': _statusPara(offset, sequencia),
        'observacao': null,
      });
      sequencia++;
    }
  }
}

String _statusPara(int offsetDia, int sequencia) {
  if (offsetDia >= 0) return 'agendado';
  if (sequencia % 7 == 3) return 'falta';
  if (sequencia % 11 == 5) return 'cancelado';
  return 'realizado';
}
