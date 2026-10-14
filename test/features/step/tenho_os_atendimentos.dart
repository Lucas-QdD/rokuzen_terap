import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/contexto_bdd.dart';

/// Usage: tenho os atendimentos
///   | 'inicio' | 'fim' | 'paciente' | 'unidade' | 'tipo' | 'situacao' |
Future<void> tenhoOsAtendimentos(
  WidgetTester tester,
  bdd.DataTable dataTable,
) async {
  final ctx = ContextoBdd.atual;
  for (final linha in dataTable.asMaps()) {
    await ctx.dados.atendimento(
      terapeutaId: ctx.terapeutaId,
      paciente: linha['paciente'] as String,
      unidade: linha['unidade'] as String,
      inicio: DateTime.parse(linha['inicio'] as String),
      fim: DateTime.parse(linha['fim'] as String),
      tipo: linha['tipo'] as String,
      status: linha['situacao'] as String,
    );
  }
}
