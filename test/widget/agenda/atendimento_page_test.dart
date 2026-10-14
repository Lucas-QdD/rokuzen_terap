import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rokuzen_terapeuta/app/router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/banco_teste.dart';
import '../../helpers/dados_teste.dart';

/// Valor exibido no campo [rotulo] do detalhe.
Finder _campo(String rotulo, String valor) => find.descendant(
  of: find.widgetWithText(ListTile, rotulo),
  matching: find.text(valor),
);

void main() {
  late Database db;
  late DadosTeste dados;
  late int ana;

  setUp(() async {
    db = await abrirBancoDeTeste(seed: false);
    dados = DadosTeste(db);
    ana = await dados.terapeuta();
    await dados.logar(ana);
  });

  Future<void> irPara(WidgetTester tester, String rota) async {
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(rota);
    await tester.pumpAndSettle();
  }

  group('RKZ-05 detalhe do atendimento', () {
    testWidgets(
      'mostra paciente, data, horário, duração, unidade, tipo e situação',
      (tester) async {
        await dados.atendimento(
          terapeutaId: ana,
          paciente: 'Mariana Souza',
          unidade: 'West Plaza — São Paulo',
          inicio: DateTime(2026, 10, 14, 9),
          fim: DateTime(2026, 10, 14, 10, 30),
          tipo: 'particular',
          status: 'realizado',
        );
        await abrirApp(tester, db);

        await tester.tap(find.text('Mariana Souza'));
        await tester.pumpAndSettle();

        expect(find.text('Atendimento'), findsOneWidget);
        expect(_campo('Paciente', 'Mariana Souza'), findsOneWidget);
        expect(_campo('Data', 'quarta-feira, 14 de outubro'), findsOneWidget);
        expect(_campo('Horário', '09:00 – 10:30'), findsOneWidget);
        expect(_campo('Duração', '1 h 30 min'), findsOneWidget);
        expect(_campo('Unidade', 'West Plaza — São Paulo'), findsOneWidget);
        expect(_campo('Tipo', 'Particular'), findsOneWidget);
        expect(_campo('Situação', 'Realizado'), findsOneWidget);
      },
    );

    testWidgets('atendimento de clínica com uma hora', (tester) async {
      final id = await dados.atendimento(
        terapeutaId: ana,
        paciente: 'Carlos Lima',
        unidade: 'Mooca Plaza — São Paulo',
        inicio: DateTime(2026, 10, 20, 16),
        fim: DateTime(2026, 10, 20, 17),
      );
      await abrirApp(tester, db);

      await irPara(tester, Rotas.atendimento(id));

      expect(_campo('Duração', '1 h'), findsOneWidget);
      expect(_campo('Tipo', 'Clínica'), findsOneWidget);
      expect(_campo('Situação', 'Agendado'), findsOneWidget);
    });

    testWidgets('atendimento de outro terapeuta não é exibido', (tester) async {
      final bia = await dados.terapeuta(nome: 'Bia', email: 'bia@rokuzen.com');
      final id = await dados.atendimento(
        terapeutaId: bia,
        paciente: 'Paciente da Bia',
        unidade: 'U',
        inicio: DateTime(2026, 10, 14, 9),
        fim: DateTime(2026, 10, 14, 10),
      );
      await abrirApp(tester, db);

      await irPara(tester, Rotas.atendimento(id));

      expect(find.text('Atendimento não encontrado.'), findsOneWidget);
      expect(find.text('Paciente da Bia'), findsNothing);
    });

    testWidgets('id inválido na rota mostra não encontrado', (tester) async {
      await abrirApp(tester, db);

      await irPara(tester, '/agenda/atendimento/abc');

      expect(find.text('Atendimento não encontrado.'), findsOneWidget);
    });

    testWidgets('cabe em celular pequeno sem estourar a tela', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final id = await dados.atendimento(
        terapeutaId: ana,
        paciente: 'Maria Aparecida dos Santos Albuquerque',
        unidade: 'Golden Square — São Bernardo do Campo',
        inicio: DateTime(2026, 10, 14, 9),
        fim: DateTime(2026, 10, 14, 10),
      );
      await abrirApp(tester, db);

      await irPara(tester, Rotas.atendimento(id));

      expect(tester.takeException(), isNull);
    });
  });
}
