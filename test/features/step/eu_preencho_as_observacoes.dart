import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu preencho as observações {'Prefere pressão leve.'}
Future<void> euPreenchoAsObservacoes(WidgetTester tester, String valor) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Observações'),
    valor,
  );
}
