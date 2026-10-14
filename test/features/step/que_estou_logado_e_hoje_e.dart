import 'package:flutter_test/flutter_test.dart';

import '../../helpers/banco_teste.dart';
import '../../helpers/contexto_bdd.dart';
import '../../helpers/dados_teste.dart';

/// Usage: que estou logado e hoje é {'2026-10-14'}
///
/// Banco em memória sem o seed, com um terapeuta já logado.
Future<void> queEstouLogadoEHojeE(WidgetTester tester, String hoje) async {
  final db = await abrirBancoDeTeste(seed: false);
  final dados = DadosTeste(db);
  final terapeutaId = await dados.terapeuta();
  await dados.logar(terapeutaId);
  ContextoBdd.iniciar(
    db,
    dados,
    terapeutaId,
    DateTime.parse(hoje).add(const Duration(hours: 8)),
  );
}
