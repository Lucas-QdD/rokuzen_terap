import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/core/utils/validadores.dart';

void main() {
  group('RKZ-01 validação de e-mail', () {
    test('aceita e-mails bem formados', () {
      for (final email in [
        'terapeuta@rokuzen.com',
        'nome.sobrenome@clinica.com.br',
        'a+b@x.io',
        'TERAPEUTA@ROKUZEN.COM',
      ]) {
        expect(Validadores.emailValido(email), isTrue, reason: email);
      }
    });

    test('rejeita e-mails mal formados', () {
      for (final email in [
        '',
        'terapeuta',
        'terapeuta@',
        '@rokuzen.com',
        'terapeuta@rokuzen',
        'tera peuta@rokuzen.com',
        'a@b@rokuzen.com',
        'terapeuta@rokuzen.',
      ]) {
        expect(Validadores.emailValido(email), isFalse, reason: email);
      }
    });
  });

  group('RKZ-06 RN09 validação dos campos do paciente', () {
    final hoje = DateTime(2026, 10, 14, 8);

    test('nome é obrigatório', () {
      expect(Validadores.nome('Ana Souza'), isNull);
      expect(Validadores.nome(''), Validadores.mensagemNomeVazio);
      expect(Validadores.nome('   '), Validadores.mensagemNomeVazio);
    });

    test('telefone é obrigatório', () {
      expect(Validadores.telefone(''), Validadores.mensagemTelefoneVazio);
      expect(Validadores.telefone('  '), Validadores.mensagemTelefoneVazio);
    });

    test('telefone precisa de DDD e 10 ou 11 dígitos', () {
      expect(Validadores.telefone('(11) 98765-4321'), isNull);
      expect(Validadores.telefone('1134567890'), isNull);
      expect(
        Validadores.telefone('98765-4321'),
        Validadores.mensagemTelefoneInvalido,
      );
      expect(
        Validadores.telefone('(11) 98765-43210'),
        Validadores.mensagemTelefoneInvalido,
      );
    });

    test('e-mail é opcional, mas validado se preenchido', () {
      expect(Validadores.emailOpcional(''), isNull);
      expect(Validadores.emailOpcional('  '), isNull);
      expect(Validadores.emailOpcional('ana@exemplo.com'), isNull);
      expect(Validadores.emailOpcional(' Ana@Exemplo.com '), isNull);
      expect(
        Validadores.emailOpcional('ana@'),
        Validadores.mensagemEmailInvalido,
      );
    });

    test('data de nascimento é opcional', () {
      expect(Validadores.dataNascimento('', hoje), isNull);
      expect(Validadores.dataNascimento('  ', hoje), isNull);
      expect(Validadores.dataNascimento('12/04/1988', hoje), isNull);
    });

    test('data de nascimento precisa ser uma data válida em dd/mm/aaaa', () {
      for (final texto in ['31/02/1990', '12-04-1988', '12/04/88', 'ontem']) {
        expect(
          Validadores.dataNascimento(texto, hoje),
          Validadores.mensagemDataInvalida,
          reason: texto,
        );
      }
    });

    test('data de nascimento não pode ser futura', () {
      expect(Validadores.dataNascimento('14/10/2026', hoje), isNull);
      expect(
        Validadores.dataNascimento('15/10/2026', hoje),
        Validadores.mensagemDataFutura,
      );
      expect(
        Validadores.dataNascimento('15/03/2030', hoje),
        Validadores.mensagemDataFutura,
      );
    });
  });
}
