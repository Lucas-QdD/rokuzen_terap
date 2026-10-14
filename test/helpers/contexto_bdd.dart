import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dados_teste.dart';

/// Estado compartilhado entre os steps de um mesmo cenário BDD.
///
/// Cada cenário começa pelo step que chama [iniciar], que recria tudo.
class ContextoBdd {
  ContextoBdd._(this.db, this.dados, this.terapeutaId, this.agora);

  static ContextoBdd? _atual;

  static ContextoBdd get atual =>
      _atual ?? (throw StateError('Cenário sem contexto: falta o step "Dado"'));

  static void iniciar(
    Database db,
    DadosTeste dados,
    int terapeutaId,
    DateTime agora,
  ) => _atual = ContextoBdd._(db, dados, terapeutaId, agora);

  final Database db;
  final DadosTeste dados;
  final int terapeutaId;
  final DateTime agora;
}
