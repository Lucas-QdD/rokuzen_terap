import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vejo os atendimentos nesta ordem
///   | 'horario' | 'paciente' | 'unidade' | 'situacao' |
///
/// Confere que a lista tem exatamente esses atendimentos, nessa ordem, e que
/// cada um mostra horário, paciente, unidade e situação.
Future<void> euVejoOsAtendimentosNestaOrdem(
  WidgetTester tester,
  bdd.DataTable dataTable,
) async {
  final linhas = dataTable.asMaps();
  expect(find.byType(Card), findsNWidgets(linhas.length));

  final posicoes = <double>[];
  for (final linha in linhas) {
    final card = find.ancestor(
      of: find.text(linha['paciente'] as String),
      matching: find.byType(Card),
    );
    expect(card, findsOneWidget, reason: '${linha['paciente']}');
    for (final campo in ['horario', 'unidade', 'situacao']) {
      expect(
        find.descendant(of: card, matching: find.text(linha[campo] as String)),
        findsOneWidget,
        reason: '$campo de ${linha['paciente']}',
      );
    }
    posicoes.add(tester.getTopLeft(card).dy);
  }
  expect(posicoes, orderedEquals([...posicoes]..sort()));
}
