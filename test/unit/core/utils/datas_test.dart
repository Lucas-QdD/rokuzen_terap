import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rokuzen_terapeuta/core/utils/datas.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('RKZ-03 datas da agenda', () {
    test('somenteData remove o horário', () {
      expect(
        somenteData(DateTime(2026, 10, 14, 17, 45, 12)),
        DateTime(2026, 10, 14),
      );
    });

    test('formatarHora usa 24 horas com dois dígitos', () {
      expect(formatarHora(DateTime(2026, 10, 14, 9, 5)), '09:05');
      expect(formatarHora(DateTime(2026, 10, 14, 17, 30)), '17:30');
    });

    test('formatarDiaLongo mostra dia da semana e mês em português', () {
      expect(
        formatarDiaLongo(DateTime(2026, 10, 14)),
        'quarta-feira, 14 de outubro',
      );
      expect(
        formatarDiaLongo(DateTime(2026, 11, 1, 10)),
        'domingo, 1 de novembro',
      );
    });

    test('diaRelativo identifica hoje, ontem e amanhã', () {
      final hoje = DateTime(2026, 10, 14, 8);
      expect(diaRelativo(DateTime(2026, 10, 14), hoje), 'Hoje');
      expect(diaRelativo(DateTime(2026, 10, 13), hoje), 'Ontem');
      expect(diaRelativo(DateTime(2026, 10, 15, 23), hoje), 'Amanhã');
      expect(diaRelativo(DateTime(2026, 10, 16), hoje), isNull);
      expect(diaRelativo(DateTime(2025, 10, 14), hoje), isNull);
    });

    test('diaRelativo atravessa a virada de mês', () {
      expect(
        diaRelativo(DateTime(2026, 11, 1), DateTime(2026, 10, 31)),
        'Amanhã',
      );
    });
  });

  group('RKZ-04 datas da semana', () {
    test(
      'somenteData converte dia em UTC (table_calendar) para o dia local',
      () {
        final convertido = somenteData(DateTime.utc(2026, 10, 15));
        expect(convertido, DateTime(2026, 10, 15));
        expect(convertido.isUtc, isFalse);
      },
    );

    test('a semana começa no domingo', () {
      expect(
        inicioDaSemana(DateTime(2026, 10, 14, 15)),
        DateTime(2026, 10, 11),
      );
      expect(inicioDaSemana(DateTime(2026, 10, 11)), DateTime(2026, 10, 11));
      expect(
        inicioDaSemana(DateTime(2026, 10, 17, 23)),
        DateTime(2026, 10, 11),
      );
    });

    test('inicioDaSemana atravessa a virada de mês e de ano', () {
      expect(inicioDaSemana(DateTime(2026, 10, 31)), DateTime(2026, 10, 25));
      expect(inicioDaSemana(DateTime(2026, 11, 3)), DateTime(2026, 11, 1));
      expect(inicioDaSemana(DateTime(2027, 1, 1)), DateTime(2026, 12, 27));
    });

    test('diasDaSemana lista os sete dias de domingo a sábado', () {
      expect(diasDaSemana(DateTime(2026, 10, 14)), [
        for (var d = 11; d <= 17; d++) DateTime(2026, 10, d),
      ]);
      expect(diasDaSemana(DateTime(2026, 12, 30)).last, DateTime(2027, 1, 2));
    });

    test('formatarSemana mostra o intervalo de dias', () {
      expect(formatarSemana(DateTime(2026, 10, 14)), '11 a 17 de outubro');
      expect(formatarSemana(DateTime(2026, 10, 28)), '25 a 31 de outubro');
      expect(
        formatarSemana(DateTime(2026, 9, 30)),
        '27 de setembro a 3 de outubro',
      );
      expect(formatarSemana(DateTime(2026, 11, 2)), '1 a 7 de novembro');
      expect(
        formatarSemana(DateTime(2026, 12, 30)),
        '27 de dezembro a 2 de janeiro',
      );
    });
  });

  group('RKZ-05 duração do atendimento', () {
    test('menos de uma hora em minutos', () {
      expect(formatarDuracao(const Duration(minutes: 45)), '45 min');
    });

    test('horas cheias', () {
      expect(formatarDuracao(const Duration(hours: 1)), '1 h');
      expect(formatarDuracao(const Duration(hours: 2)), '2 h');
    });

    test('horas e minutos', () {
      expect(formatarDuracao(const Duration(minutes: 90)), '1 h 30 min');
      expect(formatarDuracao(const Duration(minutes: 125)), '2 h 5 min');
    });

    test('ignora segundos', () {
      expect(
        formatarDuracao(const Duration(minutes: 59, seconds: 59)),
        '59 min',
      );
    });
  });

  group('RKZ-06 data digitada (dd/mm/aaaa)', () {
    test('lerData aceita dia e mês com um ou dois dígitos', () {
      expect(lerData('12/04/1988'), DateTime(1988, 4, 12));
      expect(lerData('1/4/1988'), DateTime(1988, 4, 1));
      expect(lerData(' 05/11/2000 '), DateTime(2000, 11, 5));
    });

    test('lerData rejeita datas inexistentes e outros formatos', () {
      for (final texto in [
        '',
        '31/02/1990',
        '29/02/2023',
        '00/01/2000',
        '12/13/1988',
        '12-04-1988',
        '1988-04-12',
        '12/04/88',
        '12/04/1988 10:00',
      ]) {
        expect(lerData(texto), isNull, reason: texto);
      }
    });

    test('lerData aceita 29 de fevereiro em ano bissexto', () {
      expect(lerData('29/02/2024'), DateTime(2024, 2, 29));
    });

    test('formatarData usa dd/mm/aaaa', () {
      expect(formatarData(DateTime(1988, 4, 12)), '12/04/1988');
      expect(formatarData(DateTime(2000, 11, 5, 15)), '05/11/2000');
    });
  });
}
