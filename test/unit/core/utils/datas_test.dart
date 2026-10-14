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
}
