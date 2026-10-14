import 'package:flutter_test/flutter_test.dart';

/// Usage: eu vejo a mensagem {'E-mail ou senha incorretos.'}
Future<void> euVejoAMensagem(WidgetTester tester, String mensagem) async {
  expect(find.text(mensagem), findsOneWidget);
}
