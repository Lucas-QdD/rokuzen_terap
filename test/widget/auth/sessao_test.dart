import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/core/database/seed.dart';
import 'package:rokuzen_terapeuta/data/repositories/sqlite_auth_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/banco_teste.dart';

void main() {
  late Database db;
  late SqliteAuthRepository repository;

  setUp(() async {
    db = await abrirBancoDeTeste();
    repository = SqliteAuthRepository(db);
  });

  Future<void> salvarSessaoDemo() async {
    final t = await repository.autenticar(demoEmail, demoSenha);
    await repository.salvarSessao(t!.id);
  }

  group('RKZ-02 sessão e botão Sair', () {
    testWidgets('com sessão salva, o app abre direto na agenda', (
      tester,
    ) async {
      await salvarSessaoDemo();

      await abrirApp(tester, db);

      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Hoje'), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
    });

    testWidgets('login bem-sucedido grava a sessão no aparelho', (
      tester,
    ) async {
      await abrirApp(tester, db);

      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        demoEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        demoSenha,
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect((await repository.sessaoAtual())?.email, demoEmail);
    });

    testWidgets('Sair volta ao login e encerra a sessão', (tester) async {
      await salvarSessaoDemo();
      await abrirApp(tester, db);

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Agenda'), findsNothing);
      expect(await repository.sessaoAtual(), isNull);
    });

    testWidgets('depois de sair, reabrir o app pede login de novo', (
      tester,
    ) async {
      await salvarSessaoDemo();
      await abrirApp(tester, db);
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      // Simula fechar e reabrir: descarta a árvore e monta o app de novo.
      await tester.pumpWidget(const SizedBox());
      await abrirApp(tester, db);

      expect(find.text('Entrar'), findsOneWidget);
    });
  });
}
