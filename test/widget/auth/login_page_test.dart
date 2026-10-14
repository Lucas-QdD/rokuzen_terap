import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/core/database/seed.dart';
import 'package:rokuzen_terapeuta/features/auth/login_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/banco_teste.dart';

Finder _campo(String rotulo) => find.widgetWithText(TextField, rotulo);

void main() {
  late Database db;

  setUp(() async => db = await abrirBancoDeTeste());

  group('RKZ-01 tela de login', () {
    testWidgets('sem sessão, o app abre na tela de login', (tester) async {
      await abrirApp(tester, db);

      expect(_campo('E-mail'), findsOneWidget);
      expect(_campo('Senha'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
    });

    testWidgets('senha fica oculta', (tester) async {
      await abrirApp(tester, db);

      final senha = tester.widget<TextField>(_campo('Senha'));
      expect(senha.obscureText, isTrue);
    });

    testWidgets('campos vazios mostram aviso e não entram', (tester) async {
      await abrirApp(tester, db);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text(LoginService.mensagemEmailVazio), findsOneWidget);
      expect(find.text('Agenda'), findsNothing);
    });

    testWidgets('senha vazia mostra aviso', (tester) async {
      await abrirApp(tester, db);

      await tester.enterText(_campo('E-mail'), demoEmail);
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text(LoginService.mensagemSenhaVazia), findsOneWidget);
    });

    testWidgets('erro some quando o login dá certo', (tester) async {
      await abrirApp(tester, db);

      await tester.enterText(_campo('E-mail'), demoEmail);
      await tester.enterText(_campo('Senha'), 'errada');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(
        find.text(LoginService.mensagemCredenciaisInvalidas),
        findsOneWidget,
      );

      await tester.enterText(_campo('Senha'), demoSenha);
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Agenda'), findsOneWidget);
      expect(
        find.text(LoginService.mensagemCredenciaisInvalidas),
        findsNothing,
      );
    });

    testWidgets('Enter no campo de senha também envia', (tester) async {
      await abrirApp(tester, db);

      await tester.enterText(_campo('E-mail'), demoEmail);
      await tester.enterText(_campo('Senha'), demoSenha);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Agenda'), findsOneWidget);
    });
  });
}
