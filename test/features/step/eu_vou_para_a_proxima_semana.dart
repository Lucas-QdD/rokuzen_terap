import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vou para a próxima semana
Future<void> euVouParaAProximaSemana(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Próxima semana'));
  await tester.pumpAndSettle();
}
