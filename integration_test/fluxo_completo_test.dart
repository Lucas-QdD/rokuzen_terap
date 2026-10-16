import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:rokuzen_terapeuta/app/app.dart';
import 'package:rokuzen_terapeuta/app/localizacao.dart';
import 'package:rokuzen_terapeuta/core/database/app_database.dart';
import 'package:rokuzen_terapeuta/core/database/database_provider.dart';
import 'package:rokuzen_terapeuta/core/database/seed.dart';
import 'package:sqflite/sqflite.dart';

/// Banco só do teste: não mexe no `rokuzen.db` do app instalado no aparelho.
const String _bancoDoTeste = 'rokuzen_integracao.db';

/// Pumpa até [alvo] aparecer. No aparelho o banco responde de forma
/// assíncrona de verdade, então `pumpAndSettle` sozinho não basta.
Future<void> _esperar(
  WidgetTester tester,
  Finder alvo, {
  Duration limite = const Duration(seconds: 15),
}) async {
  final fim = DateTime.now().add(limite);
  while (DateTime.now().isBefore(fim)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (alvo.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Não apareceu a tempo: $alvo');
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Database db;

  setUp(() async {
    await configurarLocalizacao();
    final caminho = p.join(await getDatabasesPath(), _bancoDoTeste);
    await deleteDatabase(caminho);
    // Banco novo a cada execução, com o seed gerado em torno de hoje.
    db = await openAppDatabase(path: caminho);
  });

  tearDown(() async {
    await db.close();
    await deleteDatabase(db.path);
  });

  testWidgets(
    'fluxo completo: login, agenda do dia, detalhe, cadastro de paciente '
    '[RKZ-01] [RKZ-03] [RKZ-05] [RKZ-06]',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWith((ref) => db)],
          child: const RokuzenApp(),
        ),
      );

      // RKZ-01: login de demonstração.
      await _esperar(tester, find.text('Entrar'));
      await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'),
        demoEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        demoSenha,
      );
      await _tocar(tester, find.text('Entrar'));

      // RKZ-03: agenda de hoje com os atendimentos do seed.
      await _esperar(tester, find.text('Hoje'));
      await _esperar(tester, find.byType(Card));
      expect(find.widgetWithText(AppBar, 'Agenda'), findsOneWidget);

      // RKZ-05: detalhe do primeiro atendimento do dia.
      await _tocar(tester, find.byType(Card).first);
      await _esperar(tester, find.widgetWithText(ListTile, 'Paciente'));
      for (final rotulo in [
        'Horário',
        'Duração',
        'Unidade',
        'Tipo',
        'Situação',
      ]) {
        expect(
          find.widgetWithText(ListTile, rotulo),
          findsOneWidget,
          reason: rotulo,
        );
      }
      await _tocar(tester, find.byTooltip('Voltar'));
      await _esperar(tester, find.text('Hoje'));

      // RKZ-06: lista de pacientes e cadastro.
      await _tocar(tester, find.byTooltip('Pacientes'));
      await _esperar(tester, find.text('Cadastrar paciente'));
      expect(find.text('Paciente Integração'), findsNothing);

      await _tocar(tester, find.text('Cadastrar paciente'));
      await _esperar(tester, find.widgetWithText(AppBar, 'Novo paciente'));
      await tester.enterText(_campo('Nome *'), 'Paciente Integração');
      await tester.enterText(_campo('Telefone *'), '11912345678');
      await tester.enterText(_campo('E-mail'), 'integracao@exemplo.com');
      await tester.enterText(_campo('Data de nascimento'), '12/04/1988');
      await _tocar(tester, find.text('Salvar'));

      // O paciente aparece na lista, com o telefone formatado.
      final item = find.widgetWithText(ListTile, 'Paciente Integração');
      await _esperar(tester, item);
      expect(find.widgetWithText(AppBar, 'Pacientes'), findsOneWidget);
      expect(
        find.descendant(of: item, matching: find.text('(11) 91234-5678')),
        findsOneWidget,
      );
    },
  );
}
