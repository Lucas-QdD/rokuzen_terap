import 'package:flutter_test/flutter_test.dart';

/// Usage: eu volto para o dia anterior
Future<void> euVoltoParaODiaAnterior(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Dia anterior'));
  await tester.pumpAndSettle();
}
