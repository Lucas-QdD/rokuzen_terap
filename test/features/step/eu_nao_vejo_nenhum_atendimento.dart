import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu não vejo nenhum atendimento
Future<void> euNaoVejoNenhumAtendimento(WidgetTester tester) async {
  expect(find.byType(Card), findsNothing);
}
