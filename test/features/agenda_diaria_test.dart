// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/que_estou_logado_e_hoje_e.dart';
import './step/tenho_os_atendimentos.dart';
import './step/eu_abro_a_agenda.dart';
import './step/eu_vejo_o_dia.dart';
import './step/eu_vejo_os_atendimentos_nesta_ordem.dart';
import './step/eu_vou_para_o_proximo_dia.dart';
import './step/eu_volto_para_o_dia_anterior.dart';
import './step/eu_vejo_a_mensagem.dart';
import './step/eu_nao_vejo_nenhum_atendimento.dart';

void main() {
  group('''RKZ-03 Agenda do dia''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await queEstouLogadoEHojeE(tester, '2026-10-14');
      await tenhoOsAtendimentos(
          tester,
          const bdd.DataTable([
            ['inicio', 'fim', 'paciente', 'unidade', 'tipo', 'situacao'],
            [
              '2026-10-14 14:30',
              '2026-10-14 15:30',
              'Carlos Lima',
              'Grand Plaza — Santo André',
              'clinica',
              'agendado'
            ],
            [
              '2026-10-14 09:00',
              '2026-10-14 10:30',
              'Mariana Souza',
              'West Plaza — São Paulo',
              'particular',
              'realizado'
            ],
            [
              '2026-10-14 11:00',
              '2026-10-14 12:00',
              'Fernanda Oliveira',
              'Mooca Plaza — São Paulo',
              'clinica',
              'cancelado'
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
              '2026-10-13 16:00',
              '2026-10-13 17:00',
              'Juliana Pereira',
              'West Plaza — São Paulo',
              'clinica',
              'falta'
            ]
          ]));
    }

    testWidgets('''Atendimentos do dia aparecem em ordem de horário''',
        (tester) async {
      await bddSetUp(tester);
      await euAbroAAgenda(tester);
      await euVejoODia(tester, 'quarta-feira, 14 de outubro');
      await euVejoOsAtendimentosNestaOrdem(
          tester,
          const bdd.DataTable([
            ['horario', 'paciente', 'unidade', 'situacao'],
            ['09:00', 'Mariana Souza', 'West Plaza — São Paulo', 'Realizado'],
            [
              '11:00',
              'Fernanda Oliveira',
              'Mooca Plaza — São Paulo',
              'Cancelado'
            ],
            ['14:30', 'Carlos Lima', 'Grand Plaza — Santo André', 'Agendado']
          ]));
    });
    testWidgets('''Navegar para o próximo dia''', (tester) async {
      await bddSetUp(tester);
      await euAbroAAgenda(tester);
      await euVouParaOProximoDia(tester);
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
    testWidgets('''Navegar para o dia anterior''', (tester) async {
      await bddSetUp(tester);
      await euAbroAAgenda(tester);
      await euVoltoParaODiaAnterior(tester);
      await euVejoODia(tester, 'terça-feira, 13 de outubro');
      await euVejoOsAtendimentosNestaOrdem(
          tester,
          const bdd.DataTable([
            ['horario', 'paciente', 'unidade', 'situacao'],
            ['16:00', 'Juliana Pereira', 'West Plaza — São Paulo', 'Falta']
          ]));
    });
    testWidgets('''Dia sem atendimentos mostra aviso''', (tester) async {
      await bddSetUp(tester);
      await euAbroAAgenda(tester);
      await euVouParaOProximoDia(tester);
      await euVouParaOProximoDia(tester);
      await euVejoODia(tester, 'sexta-feira, 16 de outubro');
      await euVejoAMensagem(tester, 'Nenhum atendimento neste dia.');
      await euNaoVejoNenhumAtendimento(tester);
    });
  });
}
