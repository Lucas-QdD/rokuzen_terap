import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/banco_teste.dart';

/// Usage: que o app foi aberto sem sessão ativa
///
/// Abre o app real sobre um banco em memória com o seed de demonstração.
Future<void> queOAppFoiAbertoSemSessaoAtiva(WidgetTester tester) async {
  final db = await abrirBancoDeTeste();
  await abrirApp(tester, db);
}
