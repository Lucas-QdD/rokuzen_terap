// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/que_estou_logado_e_hoje_e.dart';
import './step/eu_abro_a_agenda.dart';
import './step/eu_abro_o_cadastro_de_paciente.dart';
import './step/eu_preencho_o_nome.dart';
import './step/eu_preencho_o_telefone.dart';
import './step/eu_preencho_o_email.dart';
import './step/eu_preencho_a_data_de_nascimento.dart';
import './step/eu_preencho_as_observacoes.dart';
import './step/eu_toco_em.dart';
import './step/eu_vejo_o_paciente_com_telefone_na_lista.dart';
import './step/eu_vejo_a_mensagem.dart';
import './step/eu_continuo_no_cadastro_de_paciente.dart';

void main() {
  group('''RKZ-06 Cadastro de paciente''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await queEstouLogadoEHojeE(tester, '2026-10-14');
      await euAbroAAgenda(tester);
      await euAbroOCadastroDePaciente(tester);
    }

    testWidgets('''Cadastro com todos os campos''', (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Ana Beatriz Costa');
      await euPreenchoOTelefone(tester, '(11) 91234-5678');
      await euPreenchoOEmail(tester, 'ana.costa@exemplo.com');
      await euPreenchoADataDeNascimento(tester, '12/04/1988');
      await euPreenchoAsObservacoes(tester, 'Prefere pressão leve.');
      await euTocoEm(tester, 'Salvar');
      await euVejoOPacienteComTelefoneNaLista(
          tester, 'Ana Beatriz Costa', '(11) 91234-5678');
    });
    testWidgets(
        '''Telefone com ou sem máscara é aceito e formatado ('11987654321', '(11) 98765-4321')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Carlos Lima');
      await euPreenchoOTelefone(tester, '11987654321');
      await euTocoEm(tester, 'Salvar');
      await euVejoOPacienteComTelefoneNaLista(
          tester, 'Carlos Lima', '(11) 98765-4321');
    });
    testWidgets(
        '''Telefone com ou sem máscara é aceito e formatado ('11 98765 4321', '(11) 98765-4321')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Carlos Lima');
      await euPreenchoOTelefone(tester, '11 98765 4321');
      await euTocoEm(tester, 'Salvar');
      await euVejoOPacienteComTelefoneNaLista(
          tester, 'Carlos Lima', '(11) 98765-4321');
    });
    testWidgets(
        '''Telefone com ou sem máscara é aceito e formatado ('(19) 3456-7890', '(19) 3456-7890')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Carlos Lima');
      await euPreenchoOTelefone(tester, '(19) 3456-7890');
      await euTocoEm(tester, 'Salvar');
      await euVejoOPacienteComTelefoneNaLista(
          tester, 'Carlos Lima', '(19) 3456-7890');
    });
    testWidgets(
        '''Campos inválidos impedem o cadastro (\'\', \'(11) 91234-5678\', \'\', \'\', \'Informe o nome.\')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, '');
      await euPreenchoOTelefone(tester, '(11) 91234-5678');
      await euPreenchoOEmail(tester, '');
      await euPreenchoADataDeNascimento(tester, '');
      await euTocoEm(tester, 'Salvar');
      await euVejoAMensagem(tester, 'Informe o nome.');
      await euContinuoNoCadastroDePaciente(tester);
    });
    testWidgets(
        '''Campos inválidos impedem o cadastro (\'Ana\', \'\', \'\', \'\', \'Informe o telefone.\')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Ana');
      await euPreenchoOTelefone(tester, '');
      await euPreenchoOEmail(tester, '');
      await euPreenchoADataDeNascimento(tester, '');
      await euTocoEm(tester, 'Salvar');
      await euVejoAMensagem(tester, 'Informe o telefone.');
      await euContinuoNoCadastroDePaciente(tester);
    });
    testWidgets(
        '''Campos inválidos impedem o cadastro (\'Ana\', \'91234-5678\', \'\', \'\', \'Telefone inválido: informe DDD e número (10 ou 11 dígitos).\')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Ana');
      await euPreenchoOTelefone(tester, '91234-5678');
      await euPreenchoOEmail(tester, '');
      await euPreenchoADataDeNascimento(tester, '');
      await euTocoEm(tester, 'Salvar');
      await euVejoAMensagem(tester,
          'Telefone inválido: informe DDD e número (10 ou 11 dígitos).');
      await euContinuoNoCadastroDePaciente(tester);
    });
    testWidgets(
        '''Campos inválidos impedem o cadastro (\'Ana\', \'(11) 91234-56789\', \'\', \'\', \'Telefone inválido: informe DDD e número (10 ou 11 dígitos).\')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Ana');
      await euPreenchoOTelefone(tester, '(11) 91234-56789');
      await euPreenchoOEmail(tester, '');
      await euPreenchoADataDeNascimento(tester, '');
      await euTocoEm(tester, 'Salvar');
      await euVejoAMensagem(tester,
          'Telefone inválido: informe DDD e número (10 ou 11 dígitos).');
      await euContinuoNoCadastroDePaciente(tester);
    });
    testWidgets(
        '''Campos inválidos impedem o cadastro (\'Ana\', \'(11) 91234-5678\', \'ana@\', \'\', \'E-mail inválido.\')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Ana');
      await euPreenchoOTelefone(tester, '(11) 91234-5678');
      await euPreenchoOEmail(tester, 'ana@');
      await euPreenchoADataDeNascimento(tester, '');
      await euTocoEm(tester, 'Salvar');
      await euVejoAMensagem(tester, 'E-mail inválido.');
      await euContinuoNoCadastroDePaciente(tester);
    });
    testWidgets(
        '''Campos inválidos impedem o cadastro (\'Ana\', \'(11) 91234-5678\', \'\', \'15/03/2030\', \'A data de nascimento não pode ser futura.\')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Ana');
      await euPreenchoOTelefone(tester, '(11) 91234-5678');
      await euPreenchoOEmail(tester, '');
      await euPreenchoADataDeNascimento(tester, '15/03/2030');
      await euTocoEm(tester, 'Salvar');
      await euVejoAMensagem(
          tester, 'A data de nascimento não pode ser futura.');
      await euContinuoNoCadastroDePaciente(tester);
    });
    testWidgets(
        '''Campos inválidos impedem o cadastro (\'Ana\', \'(11) 91234-5678\', \'\', \'31/02/1990\', \'Data inválida. Use dd/mm/aaaa.\')''',
        (tester) async {
      await bddSetUp(tester);
      await euPreenchoONome(tester, 'Ana');
      await euPreenchoOTelefone(tester, '(11) 91234-5678');
      await euPreenchoOEmail(tester, '');
      await euPreenchoADataDeNascimento(tester, '31/02/1990');
      await euTocoEm(tester, 'Salvar');
      await euVejoAMensagem(tester, 'Data inválida. Use dd/mm/aaaa.');
      await euContinuoNoCadastroDePaciente(tester);
    });
  });
}
