import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/contexto_bdd.dart';

/// Usage: eu abro a agenda
Future<void> euAbroAAgenda(WidgetTester tester) async {
  final ctx = ContextoBdd.atual;
  await abrirApp(tester, ctx.db, agora: ctx.agora);
}
