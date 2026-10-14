import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Banco aberto uma única vez para todo o app.
///
/// Nos testes, sobrescrever com `databaseProvider.overrideWith(...)` usando um
/// banco em memória (`sqflite_common_ffi`).
final databaseProvider = FutureProvider<Database>((ref) async {
  final db = await openAppDatabase();
  ref.onDispose(db.close);
  return db;
});
