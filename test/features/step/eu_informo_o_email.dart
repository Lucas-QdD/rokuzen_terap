import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu informo o e-mail {'terapeuta@rokuzen.com'}
Future<void> euInformoOEmail(WidgetTester tester, String email) async {
  await tester.enterText(find.widgetWithText(TextField, 'E-mail'), email);
}
