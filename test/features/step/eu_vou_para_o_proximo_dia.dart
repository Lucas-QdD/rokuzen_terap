import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vou para o próximo dia
Future<void> euVouParaOProximoDia(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Próximo dia'));
  await tester.pumpAndSettle();
}
