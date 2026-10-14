import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vejo o detalhe do atendimento
///   | 'campo' | 'valor' |
Future<void> euVejoODetalheDoAtendimento(
  WidgetTester tester,
  bdd.DataTable dataTable,
) async {
  expect(find.text('Atendimento'), findsOneWidget);
  for (final linha in dataTable.asMaps()) {
    final campo = linha['campo'] as String;
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, campo),
        matching: find.text(linha['valor'] as String),
      ),
      findsOneWidget,
      reason: campo,
    );
  }
}
