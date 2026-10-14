import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Data de referência do seed nos testes.
final hojeTeste = DateTime(2026, 10, 14);

/// Abre um banco em memória isolado para o teste e o fecha ao final.
///
/// Usa a factory FFI sem isolate para funcionar também dentro de `testWidgets`
/// (o fake async do teste de widget não espera respostas de outro isolate).
///
/// Atenção: enquanto um banco em memória estiver aberto, abrir outro devolve a
/// mesma instância. Use um só por teste.
Future<Database> abrirBancoDeTeste({bool seed = true}) async {
  sqfliteFfiInit();
  final db = await openAppDatabase(
    factory: databaseFactoryFfiNoIsolate,
    path: inMemoryDatabasePath,
    seed: seed,
    hoje: hojeTeste,
  );
  addTearDown(db.close);
  return db;
}
