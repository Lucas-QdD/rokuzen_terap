import 'package:sqflite/sqflite.dart';

import '../models/atendimento_detalhado.dart';
import 'atendimento_repository.dart';

/// [AtendimentoRepository] sobre o banco SQLite local.
class SqliteAtendimentoRepository implements AtendimentoRepository {
  SqliteAtendimentoRepository(this._db);

  final DatabaseExecutor _db;

  static const String _select =
      'SELECT a.*, p.nome AS paciente_nome, u.nome AS unidade_nome '
      'FROM atendimento a '
      'JOIN paciente p ON p.id = a.paciente_id '
      'JOIN unidade u ON u.id = a.unidade_id ';

  @override
  Future<List<AtendimentoDetalhado>> listarPorPeriodo(
    int terapeutaId,
    DateTime de,
    DateTime ate,
  ) async {
    // Datas gravadas em ISO-8601 local: a comparação de texto respeita a ordem.
    final linhas = await _db.rawQuery(
      '$_select'
      'WHERE a.terapeuta_id = ? AND a.inicio >= ? AND a.inicio < ? '
      'ORDER BY a.inicio, a.fim, a.id',
      [terapeutaId, de.toIso8601String(), ate.toIso8601String()],
    );
    return linhas.map(AtendimentoDetalhado.fromMap).toList();
  }

  @override
  Future<AtendimentoDetalhado?> buscarPorId(int terapeutaId, int id) async {
    final linhas = await _db.rawQuery(
      '${_select}WHERE a.id = ? AND a.terapeuta_id = ? LIMIT 1',
      [id, terapeutaId],
    );
    return linhas.isEmpty ? null : AtendimentoDetalhado.fromMap(linhas.single);
  }
}
