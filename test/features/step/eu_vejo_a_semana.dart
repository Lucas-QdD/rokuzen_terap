import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vejo a semana {'11 a 17 de outubro'}
Future<void> euVejoASemana(WidgetTester tester, String semana) async {
  expect(find.text(semana), findsOneWidget);
}
