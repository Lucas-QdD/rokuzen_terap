import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/app/app.dart';
import 'package:rokuzen_terapeuta/app/localizacao.dart';
import 'package:rokuzen_terapeuta/core/database/database_provider.dart';
import 'package:rokuzen_terapeuta/core/relogio.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'banco_teste.dart';

/// Abre o app completo (rotas, telas e repositórios reais) sobre [db].
///
/// O relógio fica fixo em [agora] (padrão: 14/10/2026 às 8h, o "hoje" do seed).
Future<void> abrirApp(
  WidgetTester tester,
  Database db, {
  DateTime? agora,
}) async {
  await configurarLocalizacao();
  final momento = agora ?? hojeTeste.add(const Duration(hours: 8));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWith((ref) => db),
        agoraProvider.overrideWithValue(() => momento),
      ],
      child: const RokuzenApp(),
    ),
  );
  await tester.pumpAndSettle();
}
