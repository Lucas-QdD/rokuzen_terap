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
}
