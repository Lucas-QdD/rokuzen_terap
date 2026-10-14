import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: eu informo a senha {'rokuzen123'}
Future<void> euInformoASenha(WidgetTester tester, String senha) async {
  await tester.enterText(find.widgetWithText(TextField, 'Senha'), senha);
}
