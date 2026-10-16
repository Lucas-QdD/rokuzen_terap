import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/core/utils/telefone.dart';

void main() {
  group('RKZ-06 RN09 telefone com DDD', () {
    test('aceita celular e fixo, com ou sem máscara', () {
      for (final telefone in [
        '(11) 98765-4321',
        '11987654321',
        '11 98765 4321',
        '11 98765-4321',
        '(11)98765-4321',
        '(11) 3456-7890',
        '1134567890',
        '(19) 3456.7890',
        ' (11) 98765-4321 ',
      ]) {
        expect(telefoneValido(telefone), isTrue, reason: telefone);
      }
    });

    test('rejeita número sem DDD', () {
      expect(telefoneValido('98765-4321'), isFalse);
      expect(telefoneValido('3456-7890'), isFalse);
    });

    test('rejeita quantidade de dígitos diferente de 10 ou 11', () {
      for (final telefone in [
        '',
        '119876543',
        '(11) 98765-43210',
        '+55 11 98765-4321',
      ]) {
        expect(telefoneValido(telefone), isFalse, reason: telefone);
      }
    });

    test('rejeita DDD com zero', () {
      for (final telefone in [
        '(01) 98765-4321',
        '(10) 3456-7890',
        '0011987654',
      ]) {
        expect(telefoneValido(telefone), isFalse, reason: telefone);
      }
    });

    test('rejeita letras e símbolos fora da máscara', () {
      for (final telefone in [
        '(11) 9876a-4321',
        '11#98765-4321',
        '11/98765-4321',
      ]) {
        expect(telefoneValido(telefone), isFalse, reason: telefone);
      }
    });
  });

  group('RKZ-06 formatação do telefone', () {
    test('celular (11 dígitos)', () {
      expect(formatarTelefone('11987654321'), '(11) 98765-4321');
      expect(formatarTelefone('11 98765 4321'), '(11) 98765-4321');
    });

    test('fixo (10 dígitos)', () {
      expect(formatarTelefone('1934567890'), '(19) 3456-7890');
      expect(formatarTelefone('(19) 3456.7890'), '(19) 3456-7890');
    });

    test('telefone já formatado não muda', () {
      expect(formatarTelefone('(11) 98765-4321'), '(11) 98765-4321');
    });

    test('telefone inválido é recusado', () {
      expect(() => formatarTelefone('98765-4321'), throwsArgumentError);
    });
  });
}
