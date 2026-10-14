// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/que_estou_logado_e_hoje_e.dart';
import './step/tenho_os_atendimentos.dart';
import './step/eu_abro_a_agenda.dart';
import './step/eu_toco_em.dart';
import './step/eu_vejo_a_semana.dart';
import './step/eu_vejo_a_quantidade_de_atendimentos_por_dia.dart';
import './step/eu_vejo_o_dia.dart';
import './step/eu_vejo_os_atendimentos_nesta_ordem.dart';
import './step/eu_vou_para_a_proxima_semana.dart';

void main() {
  group('''RKZ-04 Agenda semanal''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await queEstouLogadoEHojeE(tester, '2026-10-14');
      await tenhoOsAtendimentos(
          tester,
          const bdd.DataTable([
            ['inicio', 'fim', 'paciente', 'unidade', 'tipo', 'situacao'],
            [
              '2026-10-14 09:00',
              '2026-10-14 10:30',
              'Mariana Souza',
              'West Plaza — São Paulo',
              'particular',
              'agendado'
            ],
            [
              '2026-10-14 14:30',
              '2026-10-14 15:30',
              'Carlos Lima',
              'Grand Plaza — Santo André',
              'clinica',
              'agendado'
            ],
            [
              '2026-10-15 10:00',
              '2026-10-15 11:00',
              'Roberto Takahashi',
              'Mooca Plaza — São Paulo',
              'clinica',
              'agendado'
            ],
            [
              '2026-10-17 09:00',
              '2026-10-17 10:00',
              'Fernanda Oliveira',
              'Mooca Plaza — São Paulo',
              'clinica',
              'agendado'
            ],
            [
              '2026-10-17 11:00',
              '2026-10-17 12:00',
              'Juliana Pereira',
              'Mooca Plaza — São Paulo',
              'clinica',
              'cancelado'
            ],
            [
              '2026-10-17 13:00',
              '2026-10-17 14:00',
              'Paulo Nakamura',
              'Mooca Plaza — São Paulo',
              'particular',
              'agendado'
            ],
            [
              '2026-10-20 16:00',
              '2026-10-20 17:00',
              'Mariana Souza',
              'West Plaza — São Paulo',
              'clinica',
              'agendado'
            ]
          ]));
    }

    testWidgets('''Quantidade de atendimentos em cada dia da semana''',
        (tester) async {
      await bddSetUp(tester);
      await euAbroAAgenda(tester);
      await euTocoEm(tester, 'Semana');
      await euVejoASemana(tester, '11 a 17 de outubro');
      await euVejoAQuantidadeDeAtendimentosPorDia(
          tester,
          const bdd.DataTable([
            ['dia', 'quantidade'],
            ['domingo, 11 de outubro', 'Nenhum atendimento'],
            ['segunda-feira, 12 de outubro', 'Nenhum atendimento'],
            ['terça-feira, 13 de outubro', 'Nenhum atendimento'],
            ['quarta-feira, 14 de outubro', '2 atendimentos'],
            ['quinta-feira, 15 de outubro', '1 atendimento'],
            ['sexta-feira, 16 de outubro', 'Nenhum atendimento'],
            ['sábado, 17 de outubro', '3 atendimentos']
          ]));
    });
    testWidgets('''Tocar no dia abre a agenda diária daquele dia''',
        (tester) async {
      await bddSetUp(tester);
      await euAbroAAgenda(tester);
      await euTocoEm(tester, 'Semana');
      await euTocoEm(tester, 'quinta-feira, 15 de outubro');
      await euVejoODia(tester, 'quinta-feira, 15 de outubro');
      await euVejoOsAtendimentosNestaOrdem(
          tester,
          const bdd.DataTable([
            ['horario', 'paciente', 'unidade', 'situacao'],
            [
              '10:00',
              'Roberto Takahashi',
              'Mooca Plaza — São Paulo',
              'Agendado'
            ]
          ]));
    });
    testWidgets('''Navegar para a próxima semana''', (tester) async {
      await bddSetUp(tester);
      await euAbroAAgenda(tester);
      await euTocoEm(tester, 'Semana');
      await euVouParaAProximaSemana(tester);
      await euVejoASemana(tester, '18 a 24 de outubro');
      await euVejoAQuantidadeDeAtendimentosPorDia(
          tester,
          const bdd.DataTable([
            ['dia', 'quantidade'],
            ['domingo, 18 de outubro', 'Nenhum atendimento'],
            ['terça-feira, 20 de outubro', '1 atendimento']
          ]));
    });
    testWidgets('''Voltar da visão semanal para a diária''', (tester) async {
      await bddSetUp(tester);
      await euAbroAAgenda(tester);
      await euTocoEm(tester, 'Semana');
      await euTocoEm(tester, 'Dia');
      await euVejoODia(tester, 'quarta-feira, 14 de outubro');
      await euVejoOsAtendimentosNestaOrdem(
          tester,
          const bdd.DataTable([
            ['horario', 'paciente', 'unidade', 'situacao'],
            ['09:00', 'Mariana Souza', 'West Plaza — São Paulo', 'Agendado'],
            ['14:30', 'Carlos Lima', 'Grand Plaza — Santo André', 'Agendado']
          ]));
    });
  });
}
