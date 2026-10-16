import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/core/utils/validadores.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/banco_teste.dart';
import '../../helpers/dados_teste.dart';

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

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

  Future<void> abrirCadastro(WidgetTester tester) async {
    await abrirApp(tester, db);
    await tester.tap(find.byTooltip('Pacientes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cadastrar paciente'));
    await tester.pumpAndSettle();
  }

  Future<void> salvar(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }

  Future<List<Map<String, Object?>>> pacientesNoBanco() => db.query('paciente');

  group('RKZ-06 cadastro de paciente', () {
    testWidgets('mostra os campos, com nome e telefone obrigatórios', (
      tester,
    ) async {
      await abrirCadastro(tester);

      for (final rotulo in [
        'Nome *',
        'Telefone *',
        'E-mail',
        'Data de nascimento',
        'Observações',
      ]) {
        expect(_campo(rotulo), findsOneWidget, reason: rotulo);
      }
      expect(find.text('* obrigatório'), findsOneWidget);
    });

    testWidgets('cadastro válido volta para a lista com o paciente', (
      tester,
    ) async {
      await abrirCadastro(tester);

      await tester.enterText(_campo('Nome *'), 'Ana Beatriz Costa');
      await tester.enterText(_campo('Telefone *'), '11912345678');
      await tester.enterText(_campo('E-mail'), 'ana.costa@exemplo.com');
      await tester.enterText(_campo('Data de nascimento'), '12/04/1988');
      await tester.enterText(_campo('Observações'), 'Prefere pressão leve.');
      await salvar(tester);

      expect(find.widgetWithText(AppBar, 'Pacientes'), findsOneWidget);
      expect(find.text('Paciente cadastrado.'), findsOneWidget);
      final item = find.widgetWithText(ListTile, 'Ana Beatriz Costa');
      expect(
        find.descendant(of: item, matching: find.text('(11) 91234-5678')),
        findsOneWidget,
      );

      final linha = (await pacientesNoBanco()).single;
      expect(linha['terapeuta_id'], ana);
      expect(linha['telefone'], '(11) 91234-5678');
      expect(linha['email'], 'ana.costa@exemplo.com');
      expect(linha['data_nascimento'], '1988-04-12');
      expect(linha['observacoes'], 'Prefere pressão leve.');
    });

    testWidgets('campos obrigatórios vazios mostram erro e não gravam', (
      tester,
    ) async {
      await abrirCadastro(tester);

      await salvar(tester);

      expect(find.text(Validadores.mensagemNomeVazio), findsOneWidget);
      expect(find.text(Validadores.mensagemTelefoneVazio), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Novo paciente'), findsOneWidget);
      expect(await pacientesNoBanco(), isEmpty);
    });

    testWidgets('telefone sem DDD, e-mail e data futura inválidos', (
      tester,
    ) async {
      await abrirCadastro(tester);

      await tester.enterText(_campo('Nome *'), 'Ana');
      await tester.enterText(_campo('Telefone *'), '91234-5678');
      await tester.enterText(_campo('E-mail'), 'ana@');
      await tester.enterText(_campo('Data de nascimento'), '15/03/2030');
      await salvar(tester);

      expect(find.text(Validadores.mensagemTelefoneInvalido), findsOneWidget);
      expect(find.text(Validadores.mensagemEmailInvalido), findsOneWidget);
      expect(find.text(Validadores.mensagemDataFutura), findsOneWidget);
      expect(await pacientesNoBanco(), isEmpty);
    });

    testWidgets('corrigir o campo e salvar de novo cadastra', (tester) async {
      await abrirCadastro(tester);
      await tester.enterText(_campo('Nome *'), 'Ana');
      await tester.enterText(_campo('Telefone *'), '91234-5678');
      await salvar(tester);
      expect(find.text(Validadores.mensagemTelefoneInvalido), findsOneWidget);

      await tester.enterText(_campo('Telefone *'), '(11) 91234-5678');
      await salvar(tester);

      expect(find.text(Validadores.mensagemTelefoneInvalido), findsNothing);
      expect(find.widgetWithText(ListTile, 'Ana'), findsOneWidget);
    });

    testWidgets('o calendário preenche a data de nascimento', (tester) async {
      await abrirCadastro(tester);

      await tester.tap(find.byTooltip('Escolher data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: _campo('Data de nascimento'),
          matching: find.text('15/01/1990'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('teclados adequados para telefone e e-mail', (tester) async {
      await abrirCadastro(tester);

      TextField campo(String rotulo) => tester.widget<TextField>(
        find.descendant(of: _campo(rotulo), matching: find.byType(TextField)),
      );
      expect(campo('Telefone *').keyboardType, TextInputType.phone);
      expect(campo('E-mail').keyboardType, TextInputType.emailAddress);
    });

    testWidgets('cabe em celular pequeno sem estourar a tela', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await abrirCadastro(tester);
      await salvar(tester);

      expect(tester.takeException(), isNull);
    });
  });
}
