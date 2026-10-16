import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vejo o paciente {'Ana Beatriz Costa'} com telefone {'(11) 91234-5678'} na lista
Future<void> euVejoOPacienteComTelefoneNaLista(
  WidgetTester tester,
  String nome,
  String telefone,
) async {
  expect(find.widgetWithText(AppBar, 'Pacientes'), findsOneWidget);
  expect(
    find.descendant(
      of: find.widgetWithText(ListTile, nome),
      matching: find.text(telefone),
    ),
    findsOneWidget,
  );
}
