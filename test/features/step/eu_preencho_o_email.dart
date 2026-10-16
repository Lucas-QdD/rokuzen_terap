import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu preencho o e-mail {'ana.costa@exemplo.com'}
Future<void> euPreenchoOEmail(WidgetTester tester, String valor) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), valor);
}
