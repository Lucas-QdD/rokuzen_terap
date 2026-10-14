import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';
import 'seed.dart';

const String databaseFileName = 'rokuzen.db';

/// Abre (ou cria) o banco SQLite local do app.
///
/// - [factory]: permite injetar `databaseFactoryFfi` nos testes.
/// - [path]: caminho do arquivo; padrão é `rokuzen.db` na pasta de bancos do
///   aparelho. Use `inMemoryDatabasePath` nos testes.
/// - [seed]: se `true`, popula os dados de demonstração na primeira execução
///   (quando o banco é criado) — RKZ-07.
/// - [hoje]: data de referência para o seed (útil em testes).
Future<Database> openAppDatabase({
  DatabaseFactory? factory,
  String? path,
  bool seed = true,
  DateTime? hoje,
}) async {
  final dbFactory = factory ?? databaseFactory;
  final dbPath =
      path ?? p.join(await dbFactory.getDatabasesPath(), databaseFileName);

  return dbFactory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: schemaVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, versao) async {
        await runMigrations(db, 0, versao);
        if (seed) await seedDemoData(db, hoje: hoje);
      },
      onUpgrade: (db, de, para) => runMigrations(db, de, para),
    ),
  );
}
