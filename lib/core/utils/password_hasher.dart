import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hash de senha com SHA-256 + salt aleatório.
///
/// Classe pura (sem Flutter) para ser testável em teste unitário.
class PasswordHasher {
  const PasswordHasher._();

  static const int _saltBytes = 16;

  /// Gera um salt aleatório codificado em base64url.
  static String gerarSalt([Random? random]) {
    final rng = random ?? Random.secure();
    final bytes = List<int>.generate(_saltBytes, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// Retorna o hash SHA-256 (hex) de `salt:senha`.
  static String hash(String senha, String salt) {
    return sha256.convert(utf8.encode('$salt:$senha')).toString();
  }

  /// Compara a senha informada com o hash armazenado em tempo constante.
  static bool verificar(String senha, String salt, String hashArmazenado) {
    final calculado = hash(senha, salt);
    if (calculado.length != hashArmazenado.length) return false;
    var diff = 0;
    for (var i = 0; i < calculado.length; i++) {
      diff |= calculado.codeUnitAt(i) ^ hashArmazenado.codeUnitAt(i);
    }
    return diff == 0;
  }
}
