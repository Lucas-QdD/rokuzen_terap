// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/que_estou_logado_e_hoje_e.dart';
import './step/tenho_os_atendimentos.dart';
import './step/eu_abro_a_agenda.dart';
import './step/eu_toco_em.dart';
import './step/eu_vejo_o_detalhe_do_atendimento.dart';

void main() {
  group('''RKZ-05 Detalhe do atendimento''', () {
    testWidgets('''Tocar no atendimento abre o detalhe''', (tester) async {
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
              'realizado'
            ]
          ]));
      await euAbroAAgenda(tester);
      await euTocoEm(tester, 'Mariana Souza');
      await euVejoODetalheDoAtendimento(
          tester,
          const bdd.DataTable([
            ['campo', 'valor'],
            ['Paciente', 'Mariana Souza'],
            ['Data', 'quarta-feira, 14 de outubro'],
            ['Horário', '09:00 – 10:30'],
            ['Duração', '1 h 30 min'],
            ['Unidade', 'West Plaza — São Paulo'],
            ['Tipo', 'Particular'],
            ['Situação', 'Realizado']
          ]));
    });
  });
}
