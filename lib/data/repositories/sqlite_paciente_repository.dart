import 'package:sqflite/sqflite.dart';

import '../models/paciente.dart';
import 'paciente_repository.dart';

/// [PacienteRepository] sobre o banco SQLite local.
class SqlitePacienteRepository implements PacienteRepository {
  SqlitePacienteRepository(this._db, {DateTime Function()? agora})
    : _agora = agora ?? DateTime.now;

  final DatabaseExecutor _db;
  final DateTime Function() _agora;

  @override
  Future<Paciente> cadastrar(int terapeutaId, NovoPaciente novo) async {
    final linha = <String, Object?>{
      'terapeuta_id': terapeutaId,
      'nome': novo.nome,
      'telefone': novo.telefone,
      'email': novo.email,
      'data_nascimento': dataSemHorario(novo.dataNascimento),
      'observacoes': novo.observacoes,
      'criado_em': _agora().toIso8601String(),
    };
    final id = await _db.insert('paciente', linha);
    return Paciente.fromMap({...linha, 'id': id});
  }

  @override
  Future<List<Paciente>> listar(int terapeutaId) async {
    final linhas = await _db.query(
      'paciente',
      where: 'terapeuta_id = ?',
      whereArgs: [terapeutaId],
      orderBy: 'nome COLLATE NOCASE, id',
    );
    return linhas.map(Paciente.fromMap).toList();
  }
}
