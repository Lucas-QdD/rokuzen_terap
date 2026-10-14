// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/que_o_app_foi_aberto_sem_sessao_ativa.dart';
import './step/eu_informo_o_email.dart';
import './step/eu_informo_a_senha.dart';
import './step/eu_toco_em.dart';
import './step/eu_vejo_a_agenda.dart';
import './step/eu_vejo_a_mensagem.dart';
import './step/eu_continuo_na_tela_de_login.dart';

void main() {
  group('''RKZ-01 Login do terapeuta''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await queOAppFoiAbertoSemSessaoAtiva(tester);
    }

    testWidgets('''Credenciais válidas abrem a agenda''', (tester) async {
      await bddSetUp(tester);
      await euInformoOEmail(tester, 'terapeuta@rokuzen.com');
      await euInformoASenha(tester, 'rokuzen123');
      await euTocoEm(tester, 'Entrar');
      await euVejoAAgenda(tester);
    });
    testWidgets(
        '''Credenciais inválidas mostram erro e não dão acesso ('terapeuta@rokuzen.com', 'senha-errada')''',
        (tester) async {
      await bddSetUp(tester);
      await euInformoOEmail(tester, 'terapeuta@rokuzen.com');
      await euInformoASenha(tester, 'senha-errada');
      await euTocoEm(tester, 'Entrar');
      await euVejoAMensagem(tester, 'E-mail ou senha incorretos.');
      await euContinuoNaTelaDeLogin(tester);
    });
    testWidgets(
        '''Credenciais inválidas mostram erro e não dão acesso ('outra@rokuzen.com', 'rokuzen123')''',
        (tester) async {
      await bddSetUp(tester);
      await euInformoOEmail(tester, 'outra@rokuzen.com');
      await euInformoASenha(tester, 'rokuzen123');
      await euTocoEm(tester, 'Entrar');
      await euVejoAMensagem(tester, 'E-mail ou senha incorretos.');
      await euContinuoNaTelaDeLogin(tester);
    });
  });
}
