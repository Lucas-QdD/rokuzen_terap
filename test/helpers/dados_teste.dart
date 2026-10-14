import 'package:rokuzen_terapeuta/core/utils/password_hasher.dart';
import 'package:rokuzen_terapeuta/data/repositories/sqlite_auth_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Monta dados de teste no banco, criando unidades e pacientes pelo nome.
class DadosTeste {
  DadosTeste(this.db);

  final Database db;
  final Map<String, int> _unidades = {};
  final Map<(int, String), int> _pacientes = {};

  Future<int> terapeuta({
    String nome = 'Ana Terapeuta',
    String email = 'ana@rokuzen.com',
    String senha = 'senha123',
  }) {
    final salt = PasswordHasher.gerarSalt();
    return db.insert('terapeuta', {
      'nome': nome,
      'email': email,
      'senha_hash': PasswordHasher.hash(senha, salt),
      'senha_salt': salt,
    });
  }

  /// Grava a sessão como se [terapeutaId] tivesse feito login.
  Future<void> logar(int terapeutaId) =>
      SqliteAuthRepository(db).salvarSessao(terapeutaId);

  Future<int> unidade(String nome) async =>
      _unidades[nome] ??= await db.insert('unidade', {'nome': nome});

  Future<int> paciente(int terapeutaId, String nome) async =>
      _pacientes[(terapeutaId, nome)] ??= await db.insert('paciente', {
        'terapeuta_id': terapeutaId,
        'nome': nome,
        'telefone': '(11) 90000-0000',
        'criado_em': '2026-10-01T08:00:00.000',
      });

  Future<int> atendimento({
    required int terapeutaId,
    required String paciente,
    required String unidade,
    required DateTime inicio,
    required DateTime fim,
    String tipo = 'clinica',
    String status = 'agendado',
  }) async {
    return db.insert('atendimento', {
      'terapeuta_id': terapeutaId,
      'paciente_id': await this.paciente(terapeutaId, paciente),
      'unidade_id': await this.unidade(unidade),
      'inicio': inicio.toIso8601String(),
      'fim': fim.toIso8601String(),
      'tipo': tipo,
      'status': status,
    });
  }
}
