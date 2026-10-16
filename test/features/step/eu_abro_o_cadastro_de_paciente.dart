import 'package:flutter_test/flutter_test.dart';

/// Usage: eu abro o cadastro de paciente
///
/// Da agenda: botão Pacientes e depois Cadastrar paciente.
Future<void> euAbroOCadastroDePaciente(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Pacientes'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Cadastrar paciente'));
  await tester.pumpAndSettle();
}
