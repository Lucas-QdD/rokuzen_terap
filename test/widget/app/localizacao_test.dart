import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/banco_teste.dart';
import '../../helpers/dados_teste.dart';

void main() {
  late Database db;
  late DadosTeste dados;

  setUp(() async {
    db = await abrirBancoDeTeste(seed: false);
    dados = DadosTeste(db);
  });

  group('Interface em pt-BR', () {
    testWidgets('textos do próprio Flutter ficam em português', (tester) async {
      await abrirApp(tester, db);

      final contexto = tester.element(find.byType(Scaffold).first);
      expect(Localizations.localeOf(contexto), const Locale('pt', 'BR'));
      expect(MaterialLocalizations.of(contexto).backButtonTooltip, 'Voltar');
    });

    testWidgets('botão de voltar do detalhe tem a dica "Voltar"', (
      tester,
    ) async {
      final ana = await dados.terapeuta();
      await dados.logar(ana);
      await dados.atendimento(
        terapeutaId: ana,
        paciente: 'Mariana Souza',
        unidade: 'West Plaza — São Paulo',
        inicio: DateTime(2026, 10, 14, 9),
        fim: DateTime(2026, 10, 14, 10),
      );
      await abrirApp(tester, db);

      await tester.tap(find.text('Mariana Souza'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Voltar'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
    });
  });
}
