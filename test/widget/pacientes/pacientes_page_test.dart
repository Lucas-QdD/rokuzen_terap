import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/banco_teste.dart';
import '../../helpers/dados_teste.dart';

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

  Future<void> abrirPacientes(WidgetTester tester) async {
    await abrirApp(tester, db);
    await tester.tap(find.byTooltip('Pacientes'));
    await tester.pumpAndSettle();
  }

  group('RKZ-06 lista de pacientes', () {
    testWidgets('a agenda tem um botão para a lista de pacientes', (
      tester,
    ) async {
      await abrirPacientes(tester);

      expect(find.widgetWithText(AppBar, 'Pacientes'), findsOneWidget);
    });

    testWidgets('mostra os pacientes do terapeuta em ordem de nome', (
      tester,
    ) async {
      await dados.paciente(ana, 'Carlos Lima');
      await dados.paciente(ana, 'Ana Costa');
      final bia = await dados.terapeuta(nome: 'Bia', email: 'bia@rokuzen.com');
      await dados.paciente(bia, 'Paciente da Bia');

      await abrirPacientes(tester);

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(
        tester.getTopLeft(find.text('Ana Costa')).dy,
        lessThan(tester.getTopLeft(find.text('Carlos Lima')).dy),
      );
      expect(find.text('(11) 90000-0000'), findsNWidgets(2));
      expect(find.text('Paciente da Bia'), findsNothing);
    });

    testWidgets('sem pacientes, mostra aviso', (tester) async {
      await abrirPacientes(tester);

      expect(find.text('Nenhum paciente cadastrado.'), findsOneWidget);
    });

    testWidgets('botão Cadastrar paciente abre o formulário', (tester) async {
      await abrirPacientes(tester);

      await tester.tap(find.text('Cadastrar paciente'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Novo paciente'), findsOneWidget);
    });

    testWidgets('voltar da lista retorna à agenda', (tester) async {
      await abrirPacientes(tester);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Agenda'), findsOneWidget);
    });
  });
}
