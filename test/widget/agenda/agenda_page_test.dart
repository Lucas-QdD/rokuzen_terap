import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/banco_teste.dart';
import '../../helpers/dados_teste.dart';

/// Card da lista que contém o paciente [nome].
Finder _card(String nome) =>
    find.ancestor(of: find.text(nome), matching: find.byType(Card));

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

  Future<int> atendimento(
    String paciente,
    DateTime inicio, {
    int minutos = 60,
    String unidade = 'West Plaza — São Paulo',
    String status = 'agendado',
    int? terapeutaId,
  }) => dados.atendimento(
    terapeutaId: terapeutaId ?? ana,
    paciente: paciente,
    unidade: unidade,
    inicio: inicio,
    fim: inicio.add(Duration(minutes: minutos)),
    status: status,
  );

  group('RKZ-03 agenda do dia', () {
    testWidgets('abre no dia de hoje', (tester) async {
      await abrirApp(tester, db);

      expect(find.text('Hoje'), findsOneWidget);
      expect(find.text('quarta-feira, 14 de outubro'), findsOneWidget);
    });

    testWidgets('lista os atendimentos em ordem de horário', (tester) async {
      await atendimento('Carlos Lima', DateTime(2026, 10, 14, 14, 30));
      await atendimento('Mariana Souza', DateTime(2026, 10, 14, 9));
      await atendimento('Fernanda Oliveira', DateTime(2026, 10, 14, 11));

      await abrirApp(tester, db);

      final ys = [
        'Mariana Souza',
        'Fernanda Oliveira',
        'Carlos Lima',
      ].map((n) => tester.getTopLeft(_card(n)).dy).toList();
      expect(ys, orderedEquals([...ys]..sort()));
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets(
      'cada atendimento mostra horário, paciente, unidade e situação',
      (tester) async {
        await atendimento(
          'Mariana Souza',
          DateTime(2026, 10, 14, 9),
          minutos: 90,
          unidade: 'Grand Plaza — Santo André',
          status: 'realizado',
        );

        await abrirApp(tester, db);

        final card = _card('Mariana Souza');
        for (final texto in [
          '09:00',
          '10:30',
          'Grand Plaza — Santo André',
          'Realizado',
        ]) {
          expect(
            find.descendant(of: card, matching: find.text(texto)),
            findsOneWidget,
            reason: texto,
          );
        }
      },
    );

    testWidgets('mostra todas as situações', (tester) async {
      for (final (i, status) in [
        'agendado',
        'realizado',
        'cancelado',
        'falta',
      ].indexed) {
        await atendimento('P$i', DateTime(2026, 10, 14, 9 + i), status: status);
      }

      await abrirApp(tester, db);

      for (final rotulo in ['Agendado', 'Realizado', 'Cancelado', 'Falta']) {
        expect(find.text(rotulo), findsOneWidget);
      }
    });

    testWidgets(
      'não mostra atendimentos de outros dias nem de outro terapeuta',
      (tester) async {
        final bia = await dados.terapeuta(
          nome: 'Bia',
          email: 'bia@rokuzen.com',
        );
        await atendimento('Paciente de quinta', DateTime(2026, 10, 15, 9));
        await atendimento('Paciente de terça', DateTime(2026, 10, 13, 9));
        await atendimento(
          'Da Bia',
          DateTime(2026, 10, 14, 9),
          terapeutaId: bia,
        );
        await atendimento('Meu', DateTime(2026, 10, 14, 10));

        await abrirApp(tester, db);

        expect(find.text('Meu'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
        expect(find.text('Da Bia'), findsNothing);
      },
    );

    testWidgets('dia sem atendimentos mostra aviso', (tester) async {
      await abrirApp(tester, db);

      expect(find.text('Nenhum atendimento neste dia.'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('próximo dia e dia anterior navegam entre os dias', (
      tester,
    ) async {
      await atendimento('Paciente de quinta', DateTime(2026, 10, 15, 9));
      await atendimento('Paciente de terça', DateTime(2026, 10, 13, 9));
      await abrirApp(tester, db);

      await tester.tap(find.byTooltip('Próximo dia'));
      await tester.pumpAndSettle();
      expect(find.text('quinta-feira, 15 de outubro'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Card),
          matching: find.text('Paciente de quinta'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Dia anterior'));
      await tester.tap(find.byTooltip('Dia anterior'));
      await tester.pumpAndSettle();
      expect(find.text('terça-feira, 13 de outubro'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Card),
          matching: find.text('Paciente de terça'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('botão Hoje aparece fora de hoje e volta para hoje', (
      tester,
    ) async {
      await abrirApp(tester, db);
      expect(find.byTooltip('Ir para hoje'), findsNothing);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byTooltip('Próximo dia'));
      }
      await tester.pumpAndSettle();
      expect(find.text('sábado, 17 de outubro'), findsOneWidget);

      await tester.tap(find.byTooltip('Ir para hoje'));
      await tester.pumpAndSettle();
      expect(find.text('quarta-feira, 14 de outubro'), findsOneWidget);
      expect(find.byTooltip('Ir para hoje'), findsNothing);
    });

    testWidgets('botão Sair continua na agenda', (tester) async {
      await abrirApp(tester, db);
      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets('tocar no atendimento abre o detalhe e voltar mantém o dia', (
      tester,
    ) async {
      await atendimento('Paciente de quinta', DateTime(2026, 10, 15, 9));
      await abrirApp(tester, db);
      await tester.tap(find.byTooltip('Próximo dia'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(Card),
          matching: find.text('Paciente de quinta'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Atendimento'), findsOneWidget);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('quinta-feira, 15 de outubro'), findsOneWidget);
    });

    testWidgets('cabe em celular pequeno sem estourar a tela', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await atendimento(
        'Maria Aparecida dos Santos Albuquerque',
        DateTime(2026, 10, 14, 9),
        unidade: 'Golden Square — São Bernardo do Campo',
        status: 'cancelado',
      );

      await abrirApp(tester, db);
      await tester.tap(find.byTooltip('Próximo dia'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
