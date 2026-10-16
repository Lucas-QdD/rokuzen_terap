import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu continuo no cadastro de paciente
Future<void> euContinuoNoCadastroDePaciente(WidgetTester tester) async {
  expect(find.widgetWithText(AppBar, 'Novo paciente'), findsOneWidget);
}
