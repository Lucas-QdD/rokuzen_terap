import 'package:flutter_test/flutter_test.dart';

/// Usage: eu toco em {'Entrar'}
Future<void> euTocoEm(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}
