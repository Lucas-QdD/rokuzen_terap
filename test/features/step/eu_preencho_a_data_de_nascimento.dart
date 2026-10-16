import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu preencho a data de nascimento {'12/04/1988'}
Future<void> euPreenchoADataDeNascimento(
  WidgetTester tester,
  String valor,
) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Data de nascimento'),
    valor,
  );
}
