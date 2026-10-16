import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu preencho o telefone {'(11) 91234-5678'}
Future<void> euPreenchoOTelefone(WidgetTester tester, String valor) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Telefone *'),
    valor,
  );
}
