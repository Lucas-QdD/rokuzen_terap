// Capturas das telas para a documentação (PNG em capturas/telas/).
//
// Não roda no `flutter test` normal nem no CI: fica fora de test/.
// Gerar com:  flutter test capturas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/app/app.dart';
import 'package:rokuzen_terapeuta/core/database/seed.dart';
import 'package:rokuzen_terapeuta/data/repositories/sqlite_auth_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test/helpers/app_teste.dart';
import '../test/helpers/banco_teste.dart';

/// Tela de celular comum: 1080 × 2340 px a 2,625 (≈ 411 × 891 pontos).
const Size _tela = Size(1080, 2340);
const double _densidade = 2.625;

/// Declara uma captura: banco em memória com o seed, relógio fixo em
/// 14/10/2026 às 8h e tela de celular.
void _cena(
  String descricao,
  Future<void> Function(WidgetTester, Database) corpo,
) {
  testWidgets(descricao, (tester) async {
    tester.view.physicalSize = _tela;
    tester.view.devicePixelRatio = _densidade;
    addTearDown(tester.view.reset);

    // Sombras de verdade nas capturas (o padrão dos testes é desligá-las).
    debugDisableShadows = false;
    try {
      final db = await abrirBancoDeTeste();
      await corpo(tester, db);
    } finally {
      debugDisableShadows = true;
    }
  });
}

/// Grava a tela atual em `capturas/telas/<nome>.png`.
Future<void> _capturar(WidgetTester tester, String nome) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(RokuzenApp),
    matchesGoldenFile('telas/$nome.png'),
  );
}

Future<void> _logarDemo(Database db) async {
  final auth = SqliteAuthRepository(db);
  final terapeuta = await auth.autenticar(demoEmail, demoSenha);
  await auth.salvarSessao(terapeuta!.id);
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

Future<void> _abrirCadastro(WidgetTester tester, Database db) async {
  await _logarDemo(db);
  await abrirApp(tester, db);
  await _tocar(tester, find.byTooltip('Pacientes'));
  await _tocar(tester, find.text('Cadastrar paciente'));
}

void main() {
  group('Capturas de tela', () {
    _cena('01 login vazio', (tester, db) async {
      await abrirApp(tester, db);
      await _capturar(tester, '01_login_vazio');
    });

    _cena('02 login com erro', (tester, db) async {
      await abrirApp(tester, db);
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        demoEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'senha-errada',
      );
      await _tocar(tester, find.text('Entrar'));
      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
      await _capturar(tester, '02_login_erro');
    });

    _cena('03 agenda do dia', (tester, db) async {
      await _logarDemo(db);
      await abrirApp(tester, db);
      expect(find.byType(Card), findsWidgets);
      await _capturar(tester, '03_agenda_dia');
    });

    _cena('04 dia sem atendimentos', (tester, db) async {
      await _logarDemo(db);
      await abrirApp(tester, db);
      // No seed, 16/10 (depois de amanhã) não tem atendimentos.
      await _tocar(tester, find.byTooltip('Próximo dia'));
      await _tocar(tester, find.byTooltip('Próximo dia'));
      expect(find.text('Nenhum atendimento neste dia.'), findsOneWidget);
      await _capturar(tester, '04_dia_sem_atendimentos');
    });

    _cena('05 detalhe do atendimento', (tester, db) async {
      await _logarDemo(db);
      await abrirApp(tester, db);
      await _tocar(tester, find.byType(Card).first);
      expect(find.widgetWithText(AppBar, 'Atendimento'), findsOneWidget);
      await _capturar(tester, '05_detalhe_atendimento');
    });

    _cena('06 agenda semanal', (tester, db) async {
      await _logarDemo(db);
      await abrirApp(tester, db);
      await _tocar(tester, find.text('Semana'));
      expect(find.text('11 a 17 de outubro'), findsOneWidget);
      await _capturar(tester, '06_agenda_semanal');
    });

    _cena('07 lista de pacientes', (tester, db) async {
      await _logarDemo(db);
      await abrirApp(tester, db);
      await _tocar(tester, find.byTooltip('Pacientes'));
      expect(find.byType(ListTile), findsWidgets);
      await _capturar(tester, '07_lista_pacientes');
    });

    _cena('08 cadastro com erros nos campos', (tester, db) async {
      await _abrirCadastro(tester, db);
      await tester.enterText(_campo('Telefone *'), '91234-5678');
      await tester.enterText(_campo('E-mail'), 'ana@');
      await tester.enterText(_campo('Data de nascimento'), '15/03/2030');
      await _tocar(tester, find.text('Salvar'));
      await tester.ensureVisible(_campo('Nome *'));
      expect(find.text('Informe o nome.'), findsOneWidget);
      await _capturar(tester, '08_cadastro_erros');
    });

    _cena('09 lista depois do cadastro', (tester, db) async {
      await _abrirCadastro(tester, db);
      await tester.enterText(_campo('Nome *'), 'Ana Beatriz Costa');
      await tester.enterText(_campo('Telefone *'), '11912345678');
      await tester.enterText(_campo('E-mail'), 'ana.costa@exemplo.com');
      await tester.enterText(_campo('Data de nascimento'), '12/04/1988');
      await _tocar(tester, find.text('Salvar'));
      expect(find.text('Paciente cadastrado.'), findsOneWidget);
      expect(find.text('Ana Beatriz Costa'), findsOneWidget);
      await _capturar(tester, '09_lista_apos_cadastro');
    });
  });
}
