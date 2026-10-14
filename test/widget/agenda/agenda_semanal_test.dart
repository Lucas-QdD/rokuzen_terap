import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/banco_teste.dart';
import '../../helpers/dados_teste.dart';

/// Quantidade mostrada na lista da semana para o [dia].
Finder _quantidade(String dia, String quantidade) => find.descendant(
  of: find.widgetWithText(ListTile, dia),
  matching: find.text(quantidade),
);

Finder _noCalendario(String texto) => find.descendant(
  of: find.byType(TableCalendar<void>),
  matching: find.text(texto),
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

  Future<void> atendimento(
    DateTime inicio, {
    String paciente = 'Paciente',
    int? terapeutaId,
    String status = 'agendado',
  }) => dados.atendimento(
    terapeutaId: terapeutaId ?? ana,
    paciente: paciente,
    unidade: 'West Plaza — São Paulo',
    inicio: inicio,
    fim: inicio.add(const Duration(hours: 1)),
    status: status,
  );

  Future<void> abrirSemana(WidgetTester tester) async {
    await abrirApp(tester, db);
    await tester.tap(find.text('Semana'));
    await tester.pumpAndSettle();
  }

  group('RKZ-04 alternar entre visão diária e semanal', () {
    testWidgets('a agenda abre na visão diária', (tester) async {
      await abrirApp(tester, db);

      expect(find.text('Dia'), findsOneWidget);
      expect(find.text('Semana'), findsOneWidget);
      expect(find.text('quarta-feira, 14 de outubro'), findsOneWidget);
      expect(find.byType(TableCalendar<void>), findsNothing);
    });

    testWidgets('Semana mostra o calendário da semana atual', (tester) async {
      await abrirSemana(tester);

      expect(find.byType(TableCalendar<void>), findsOneWidget);
      expect(find.text('Esta semana'), findsOneWidget);
      expect(find.text('11 a 17 de outubro'), findsOneWidget);
      for (final dia in ['dom.', 'seg.', 'sáb.']) {
        expect(_noCalendario(dia), findsOneWidget, reason: dia);
      }
    });

    testWidgets('Dia volta para a agenda do dia', (tester) async {
      await abrirSemana(tester);

      await tester.tap(find.text('Dia'));
      await tester.pumpAndSettle();

      expect(find.byType(TableCalendar<void>), findsNothing);
      expect(find.text('Hoje'), findsOneWidget);
    });
  });

  group('RKZ-04 agenda semanal', () {
    testWidgets('mostra a quantidade de atendimentos de cada dia', (
      tester,
    ) async {
      await atendimento(DateTime(2026, 10, 14, 9));
      await atendimento(DateTime(2026, 10, 14, 14));
      await atendimento(DateTime(2026, 10, 15, 10));
      for (final hora in [9, 11, 15]) {
        await atendimento(DateTime(2026, 10, 17, hora), status: 'cancelado');
      }

      await abrirSemana(tester);

      expect(
        _quantidade('domingo, 11 de outubro', 'Nenhum atendimento'),
        findsOneWidget,
      );
      expect(
        _quantidade('quarta-feira, 14 de outubro', '2 atendimentos'),
        findsOneWidget,
      );
      expect(
        _quantidade('quinta-feira, 15 de outubro', '1 atendimento'),
        findsOneWidget,
      );
      expect(
        _quantidade('sábado, 17 de outubro', '3 atendimentos'),
        findsOneWidget,
      );
      expect(find.byType(ListTile), findsNWidgets(7));
    });

    testWidgets('o calendário marca a quantidade nos dias com atendimento', (
      tester,
    ) async {
      await atendimento(DateTime(2026, 10, 14, 9));
      await atendimento(DateTime(2026, 10, 14, 14));
      await atendimento(DateTime(2026, 10, 15, 10));

      await abrirSemana(tester);

      expect(_noCalendario('2'), findsOneWidget);
      expect(_noCalendario('1'), findsOneWidget);
      expect(_noCalendario('0'), findsNothing);
    });

    testWidgets(
      'não conta atendimentos de fora da semana nem de outro terapeuta',
      (tester) async {
        final bia = await dados.terapeuta(
          nome: 'Bia',
          email: 'bia@rokuzen.com',
        );
        await atendimento(DateTime(2026, 10, 14, 9), terapeutaId: bia);
        await atendimento(DateTime(2026, 10, 10, 9));
        await atendimento(DateTime(2026, 10, 18, 9));

        await abrirSemana(tester);

        expect(find.text('Nenhum atendimento'), findsNWidgets(7));
      },
    );

    testWidgets('tocar num dia da lista abre a agenda diária daquele dia', (
      tester,
    ) async {
      await atendimento(
        DateTime(2026, 10, 15, 10),
        paciente: 'Roberto Takahashi',
      );
      await abrirSemana(tester);

      await tester.tap(find.text('quinta-feira, 15 de outubro'));
      await tester.pumpAndSettle();

      expect(find.byType(TableCalendar<void>), findsNothing);
      expect(find.text('Amanhã'), findsOneWidget);
      expect(find.text('quinta-feira, 15 de outubro'), findsOneWidget);
      expect(find.text('Roberto Takahashi'), findsOneWidget);
    });

    testWidgets('tocar num dia do calendário abre a agenda diária', (
      tester,
    ) async {
      await abrirSemana(tester);

      await tester.tap(_noCalendario('16'));
      await tester.pumpAndSettle();

      expect(find.byType(TableCalendar<void>), findsNothing);
      expect(find.text('sexta-feira, 16 de outubro'), findsOneWidget);
    });

    testWidgets('próxima semana e semana anterior navegam entre as semanas', (
      tester,
    ) async {
      await atendimento(DateTime(2026, 10, 20, 9));
      await abrirSemana(tester);

      await tester.tap(find.byTooltip('Próxima semana'));
      await tester.pumpAndSettle();
      expect(find.text('18 a 24 de outubro'), findsOneWidget);
      expect(find.text('Esta semana'), findsNothing);
      expect(
        _quantidade('terça-feira, 20 de outubro', '1 atendimento'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Semana anterior'));
      await tester.tap(find.byTooltip('Semana anterior'));
      await tester.pumpAndSettle();
      expect(find.text('4 a 10 de outubro'), findsOneWidget);
    });

    testWidgets('deslizar o calendário muda de semana', (tester) async {
      await abrirSemana(tester);

      await tester.fling(
        find.byType(TableCalendar<void>),
        const Offset(-300, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('18 a 24 de outubro'), findsOneWidget);
    });

    testWidgets(
      'trocar de semana e voltar para Dia mostra o dia correspondente',
      (tester) async {
        await abrirSemana(tester);
        await tester.tap(find.byTooltip('Próxima semana'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Dia'));
        await tester.pumpAndSettle();

        expect(find.text('quarta-feira, 21 de outubro'), findsOneWidget);
      },
    );

    testWidgets('Ir para hoje volta para a semana atual', (tester) async {
      await abrirSemana(tester);
      await tester.tap(find.byTooltip('Próxima semana'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Ir para hoje'));
      await tester.pumpAndSettle();

      expect(find.text('11 a 17 de outubro'), findsOneWidget);
      expect(find.byType(TableCalendar<void>), findsOneWidget);
    });

    testWidgets('depois de sair e entrar de novo, a agenda volta para o dia', (
      tester,
    ) async {
      await abrirSemana(tester);

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        'ana@rokuzen.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'senha123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.byType(TableCalendar<void>), findsNothing);
      expect(find.text('Hoje'), findsOneWidget);
    });

    testWidgets('cabe em celular pequeno sem estourar a tela', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (var d = 11; d <= 17; d++) {
        await atendimento(DateTime(2026, 10, d, 9));
      }

      await abrirSemana(tester);
      expect(tester.takeException(), isNull);

      // Semana com o cabeçalho mais longo (atravessa o mês).
      await tester.tap(find.byTooltip('Semana anterior'));
      await tester.tap(find.byTooltip('Semana anterior'));
      await tester.pumpAndSettle();
      expect(find.text('27 de setembro a 3 de outubro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
