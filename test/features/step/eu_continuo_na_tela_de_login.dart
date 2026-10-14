import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu continuo na tela de login
Future<void> euContinuoNaTelaDeLogin(WidgetTester tester) async {
  expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
  expect(find.text('Agenda'), findsNothing);
}
