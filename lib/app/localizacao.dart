import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Carrega nomes de dias e meses em pt-BR. Chamar antes de `runApp`.
Future<void> configurarLocalizacao() async {
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR');
}
