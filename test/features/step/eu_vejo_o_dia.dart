import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vejo o dia {'quarta-feira, 14 de outubro'}
Future<void> euVejoODia(WidgetTester tester, String dia) async {
  expect(find.text(dia), findsOneWidget);
}
