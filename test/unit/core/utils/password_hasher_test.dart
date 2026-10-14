import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/core/utils/password_hasher.dart';

void main() {
  group('RKZ-01 hash de senha', () {
    test('gera hash SHA-256 em hexadecimal (64 caracteres)', () {
      final hash = PasswordHasher.hash('rokuzen123', 'salt');
      expect(hash, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('mesma senha e salt geram o mesmo hash', () {
      expect(
        PasswordHasher.hash('rokuzen123', 'abc'),
        PasswordHasher.hash('rokuzen123', 'abc'),
      );
    });

    test('salts diferentes geram hashes diferentes', () {
      expect(
        PasswordHasher.hash('rokuzen123', 'abc'),
        isNot(PasswordHasher.hash('rokuzen123', 'xyz')),
      );
    });

    test('gerarSalt produz valores distintos', () {
      final rng = Random(42);
      expect(
        PasswordHasher.gerarSalt(rng),
        isNot(PasswordHasher.gerarSalt(rng)),
      );
      expect(PasswordHasher.gerarSalt(), isNotEmpty);
    });

    test('verificar aceita a senha correta e rejeita a incorreta', () {
      final salt = PasswordHasher.gerarSalt();
      final hash = PasswordHasher.hash('rokuzen123', salt);
      expect(PasswordHasher.verificar('rokuzen123', salt, hash), isTrue);
      expect(PasswordHasher.verificar('rokuzen124', salt, hash), isFalse);
      expect(PasswordHasher.verificar('', salt, hash), isFalse);
      expect(PasswordHasher.verificar('rokuzen123', salt, 'curto'), isFalse);
    });
  });
}
