import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/app/app.dart';
import 'package:rokuzen_terapeuta/core/database/database_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Abre o app completo (rotas, telas e repositórios reais) sobre [db].
Future<void> abrirApp(WidgetTester tester, Database db) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWith((ref) => db)],
      child: const RokuzenApp(),
    ),
  );
  await tester.pumpAndSettle();
}
