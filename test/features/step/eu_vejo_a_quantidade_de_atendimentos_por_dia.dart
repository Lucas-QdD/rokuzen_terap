import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vejo a quantidade de atendimentos por dia
///   | 'dia' | 'quantidade' |
Future<void> euVejoAQuantidadeDeAtendimentosPorDia(
  WidgetTester tester,
  bdd.DataTable dataTable,
) async {
  for (final linha in dataTable.asMaps()) {
    final dia = linha['dia'] as String;
    final item = find.widgetWithText(ListTile, dia);
    // Em telas pequenas, o terapeuta rola a lista até o dia.
    await tester.ensureVisible(item);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: item,
        matching: find.text(linha['quantidade'] as String),
      ),
      findsOneWidget,
      reason: dia,
    );
  }
}
