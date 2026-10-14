import 'package:intl/intl.dart';

/// Utilitários de data e hora em pt-BR para a agenda.
///
/// Funções puras (sem Flutter). As que usam nomes de dia e mês exigem
/// `initializeDateFormatting('pt_BR')` antes (feito em `configurarLocalizacao`).

const String _locale = 'pt_BR';

/// [data] à meia-noite (sem horário), no fuso local.
///
/// Também converte os dias em UTC do table_calendar para o dia local
/// equivalente (mesmo ano, mês e dia).
DateTime somenteData(DateTime data) =>
    DateTime(data.year, data.month, data.day);

/// Domingo da semana de [dia] (a semana vai de domingo a sábado).
DateTime inicioDaSemana(DateTime dia) =>
    DateTime(dia.year, dia.month, dia.day - dia.weekday % DateTime.daysPerWeek);

/// Os sete dias da semana de [dia], de domingo a sábado.
List<DateTime> diasDaSemana(DateTime dia) {
  final domingo = inicioDaSemana(dia);
  return [
    for (var i = 0; i < DateTime.daysPerWeek; i++)
      DateTime(domingo.year, domingo.month, domingo.day + i),
  ];
}

/// Intervalo da semana de [dia], ex.: `11 a 17 de outubro` ou
/// `27 de setembro a 3 de outubro`.
String formatarSemana(DateTime dia) {
  final dias = diasDaSemana(dia);
  final inicio = dias.first;
  final fim = dias.last;
  final diaEMes = DateFormat("d 'de' MMMM", _locale);
  final de = inicio.month == fim.month
      ? '${inicio.day}'
      : diaEMes.format(inicio);
  return '$de a ${diaEMes.format(fim)}';
}

/// Hora no formato 24 h, ex.: `09:05`.
String formatarHora(DateTime data) => DateFormat('HH:mm', _locale).format(data);

/// Dia da semana, dia e mês, ex.: `quarta-feira, 14 de outubro`.
String formatarDiaLongo(DateTime data) =>
    DateFormat("EEEE, d 'de' MMMM", _locale).format(data);

/// `Hoje`, `Ontem` ou `Amanhã` em relação a [agora]; senão, `null`.
String? diaRelativo(DateTime dia, DateTime agora) {
  final hoje = somenteData(agora);
  final alvo = somenteData(dia);
  if (alvo == hoje) return 'Hoje';
  if (alvo == DateTime(hoje.year, hoje.month, hoje.day - 1)) return 'Ontem';
  if (alvo == DateTime(hoje.year, hoje.month, hoje.day + 1)) return 'Amanhã';
  return null;
}

/// Duração legível, ex.: `45 min`, `1 h`, `1 h 30 min`.
String formatarDuracao(Duration duracao) {
  final horas = duracao.inHours;
  final minutos = duracao.inMinutes % 60;
  if (horas == 0) return '$minutos min';
  if (minutos == 0) return '$horas h';
  return '$horas h $minutos min';
}
