import 'package:sqflite/sqflite.dart';

import '../../core/utils/password_hasher.dart';
import '../models/terapeuta.dart';
import 'auth_repository.dart';

/// [AuthRepository] sobre o banco SQLite local.
///
/// A sessão fica na tabela `sessao`, que tem no máximo uma linha (id = 1).
class SqliteAuthRepository implements AuthRepository {
  SqliteAuthRepository(this._db, {DateTime Function()? agora})
    : _agora = agora ?? DateTime.now;

  final DatabaseExecutor _db;
  final DateTime Function() _agora;

  static const List<String> _colunasTerapeuta = [
    'id',
    'nome',
    'email',
    'telefone',
  ];

  @override
  Future<Terapeuta?> autenticar(String email, String senha) async {
    // A coluna email usa COLLATE NOCASE: a busca não diferencia maiúsculas.
    final linhas = await _db.query(
      'terapeuta',
      columns: [..._colunasTerapeuta, 'senha_hash', 'senha_salt'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (linhas.isEmpty) return null;

    final linha = linhas.single;
    final confere = PasswordHasher.verificar(
      senha,
      linha['senha_salt']! as String,
      linha['senha_hash']! as String,
    );
    return confere ? Terapeuta.fromMap(linha) : null;
  }

  @override
  Future<Terapeuta?> sessaoAtual() async {
    final colunas = _colunasTerapeuta.map((c) => 't.$c').join(', ');
    final linhas = await _db.rawQuery(
      'SELECT $colunas FROM sessao s '
      'JOIN terapeuta t ON t.id = s.terapeuta_id '
      'LIMIT 1',
    );
    return linhas.isEmpty ? null : Terapeuta.fromMap(linhas.single);
  }

  @override
  Future<void> salvarSessao(int terapeutaId) async {
    await _db.insert('sessao', {
      'id': 1,
      'terapeuta_id': terapeutaId,
      'iniciada_em': _agora().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> encerrarSessao() async {
    await _db.delete('sessao');
  }
}
