import 'package:flutter_test/flutter_test.dart';

/// Usage: eu toco em {'Entrar'}
///
/// Rola a tela até o texto antes de tocar, como o terapeuta faria.
Future<void> euTocoEm(WidgetTester tester, String texto) async {
  final alvo = find.text(texto);
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}
