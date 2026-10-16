import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu preencho o nome {'Ana Beatriz Costa'}
Future<void> euPreenchoONome(WidgetTester tester, String valor) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Nome *'), valor);
}
