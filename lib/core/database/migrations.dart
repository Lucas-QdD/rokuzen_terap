import 'package:sqflite/sqflite.dart';

/// Migrações do banco, indexadas pela versão do schema.
///
/// Para evoluir o schema: adicionar uma nova entrada `N + 1` com os comandos
/// incrementais. Nunca alterar uma migração já publicada.
const Map<int, List<String>> migrations = {
  1: [
    '''
    CREATE TABLE unidade (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      endereco TEXT
    )
    ''',
    '''
    CREATE TABLE terapeuta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE COLLATE NOCASE,
      senha_hash TEXT NOT NULL,
      senha_salt TEXT NOT NULL,
      telefone TEXT
    )
    ''',
    '''
    CREATE TABLE terapeuta_unidade (
      terapeuta_id INTEGER NOT NULL REFERENCES terapeuta(id) ON DELETE CASCADE,
      unidade_id INTEGER NOT NULL REFERENCES unidade(id) ON DELETE CASCADE,
      PRIMARY KEY (terapeuta_id, unidade_id)
    )
    ''',
    '''
    CREATE TABLE paciente (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      terapeuta_id INTEGER NOT NULL REFERENCES terapeuta(id) ON DELETE CASCADE,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL,
      email TEXT,
      data_nascimento TEXT,
      observacoes TEXT,
      criado_em TEXT NOT NULL
    )
    ''',
    '''
    CREATE TABLE disponibilidade (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      terapeuta_id INTEGER NOT NULL REFERENCES terapeuta(id) ON DELETE CASCADE,
      unidade_id INTEGER NOT NULL REFERENCES unidade(id),
      inicio TEXT NOT NULL,
      fim TEXT NOT NULL,
      CHECK (fim > inicio)
    )
    ''',
    '''
    CREATE TABLE atendimento (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      terapeuta_id INTEGER NOT NULL REFERENCES terapeuta(id) ON DELETE CASCADE,
      paciente_id INTEGER NOT NULL REFERENCES paciente(id),
      unidade_id INTEGER NOT NULL REFERENCES unidade(id),
      inicio TEXT NOT NULL,
      fim TEXT NOT NULL,
      tipo TEXT NOT NULL CHECK (tipo IN ('clinica', 'particular')),
      status TEXT NOT NULL DEFAULT 'agendado'
        CHECK (status IN ('agendado', 'realizado', 'cancelado', 'falta')),
      observacao TEXT,
      disponibilidade_id INTEGER REFERENCES disponibilidade(id) ON DELETE SET NULL,
      CHECK (fim > inicio)
    )
    ''',
    'CREATE INDEX idx_paciente_terapeuta ON paciente(terapeuta_id, nome)',
    'CREATE INDEX idx_atendimento_terapeuta_inicio ON atendimento(terapeuta_id, inicio)',
    'CREATE INDEX idx_disponibilidade_terapeuta_inicio ON disponibilidade(terapeuta_id, inicio)',
  ],
};

/// Versão atual do schema (a maior chave de [migrations]).
int get schemaVersion => migrations.keys.reduce((a, b) => a > b ? a : b);

/// Aplica, em ordem, as migrações de `de + 1` até `para` (inclusive).
Future<void> runMigrations(DatabaseExecutor db, int de, int para) async {
  for (var versao = de + 1; versao <= para; versao++) {
    final comandos = migrations[versao];
    if (comandos == null) {
      throw StateError('Migração da versão $versao não encontrada');
    }
    for (final sql in comandos) {
      await db.execute(sql);
    }
  }
}
