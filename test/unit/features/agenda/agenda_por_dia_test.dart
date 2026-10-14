import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/data/models/atendimento.dart';
import 'package:rokuzen_terapeuta/data/models/atendimento_detalhado.dart';
import 'package:rokuzen_terapeuta/features/agenda/agenda_por_dia.dart';

AtendimentoDetalhado _a(int id, String inicio, String fim) =>
    AtendimentoDetalhado(
      atendimento: Atendimento(
        id: id,
        terapeutaId: 1,
        pacienteId: 1,
        unidadeId: 1,
        inicio: DateTime.parse(inicio),
        fim: DateTime.parse(fim),
        tipo: TipoAtendimento.clinica,
        status: StatusAtendimento.agendado,
      ),
      pacienteNome: 'Paciente $id',
      unidadeNome: 'Unidade',
    );

List<int> _ids(List<AtendimentoDetalhado> lista) =>
    lista.map((a) => a.atendimento.id).toList();

void main() {
  group('RKZ-03 agrupar atendimentos por dia', () {
    test('lista vazia gera agenda vazia', () {
      expect(agruparPorDia(const []), isEmpty);
    });

    test('agrupa pela data de início', () {
      final agenda = agruparPorDia([
        _a(1, '2026-10-14 09:00', '2026-10-14 10:00'),
        _a(2, '2026-10-15 09:00', '2026-10-15 10:00'),
        _a(3, '2026-10-14 13:00', '2026-10-14 14:00'),
      ]);

      expect(agenda.keys, [DateTime(2026, 10, 14), DateTime(2026, 10, 15)]);
      expect(_ids(agenda[DateTime(2026, 10, 14)]!), [1, 3]);
      expect(_ids(agenda[DateTime(2026, 10, 15)]!), [2]);
    });

    test('chave do dia não tem horário', () {
      final agenda = agruparPorDia([
        _a(1, '2026-10-14 17:30', '2026-10-14 18:30'),
      ]);
      expect(agenda.keys.single, DateTime(2026, 10, 14));
    });

    test('ordena os atendimentos de cada dia pelo horário de início', () {
      final agenda = agruparPorDia([
        _a(1, '2026-10-14 16:00', '2026-10-14 17:00'),
        _a(2, '2026-10-14 09:00', '2026-10-14 10:00'),
        _a(3, '2026-10-14 13:00', '2026-10-14 14:00'),
        _a(4, '2026-10-14 10:30', '2026-10-14 11:30'),
      ]);
      expect(_ids(agenda[DateTime(2026, 10, 14)]!), [2, 4, 3, 1]);
    });

    test('dias ficam em ordem cronológica', () {
      final agenda = agruparPorDia([
        _a(1, '2026-10-20 09:00', '2026-10-20 10:00'),
        _a(2, '2026-09-30 09:00', '2026-09-30 10:00'),
        _a(3, '2026-10-14 09:00', '2026-10-14 10:00'),
      ]);
      expect(agenda.keys, [
        DateTime(2026, 9, 30),
        DateTime(2026, 10, 14),
        DateTime(2026, 10, 20),
      ]);
    });

    test('mesmo início: termina antes vem primeiro, depois pelo id', () {
      final agenda = agruparPorDia([
        _a(3, '2026-10-14 09:00', '2026-10-14 10:00'),
        _a(1, '2026-10-14 09:00', '2026-10-14 10:30'),
        _a(2, '2026-10-14 09:00', '2026-10-14 10:00'),
      ]);
      expect(_ids(agenda[DateTime(2026, 10, 14)]!), [2, 3, 1]);
    });

    test('atendimento que passa da meia-noite fica no dia em que começa', () {
      final agenda = agruparPorDia([
        _a(1, '2026-10-14 23:30', '2026-10-15 00:30'),
      ]);
      expect(agenda.keys, [DateTime(2026, 10, 14)]);
    });

    test('não altera a lista recebida', () {
      final lista = [
        _a(2, '2026-10-14 13:00', '2026-10-14 14:00'),
        _a(1, '2026-10-14 09:00', '2026-10-14 10:00'),
      ];
      agruparPorDia(lista);
      expect(_ids(lista), [2, 1]);
    });
  });
}
