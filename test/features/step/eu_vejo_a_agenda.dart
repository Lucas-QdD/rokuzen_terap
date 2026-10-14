import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vejo a agenda
Future<void> euVejoAAgenda(WidgetTester tester) async {
  expect(find.text('Agenda'), findsOneWidget);
  expect(find.text('Entrar'), findsNothing);
}
