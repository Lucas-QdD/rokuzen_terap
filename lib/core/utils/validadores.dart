import 'datas.dart';
import 'telefone.dart';

/// Validadores de campos de formulário.
///
/// Classe pura (sem Flutter) para ser testável em teste unitário. Os métodos
/// que retornam `String?` devolvem a mensagem de erro, ou `null` se válido.
abstract final class Validadores {
  // Formato prático: algo@dominio.tld, sem espaços e com um único "@".
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@.]+(\.[^\s@.]+)+$');

  static const String mensagemNomeVazio = 'Informe o nome.';
  static const String mensagemTelefoneVazio = 'Informe o telefone.';
  static const String mensagemTelefoneInvalido =
      'Telefone inválido: informe DDD e número (10 ou 11 dígitos).';
  static const String mensagemEmailInvalido = 'E-mail inválido.';
  static const String mensagemDataInvalida = 'Data inválida. Use dd/mm/aaaa.';
  static const String mensagemDataFutura =
      'A data de nascimento não pode ser futura.';

  /// Indica se [email] tem formato de e-mail.
  static bool emailValido(String email) => _email.hasMatch(email);

  /// Nome obrigatório (RN09).
  static String? nome(String valor) =>
      valor.trim().isEmpty ? mensagemNomeVazio : null;

  /// Telefone obrigatório, com DDD e 10 ou 11 dígitos (RN09).
  static String? telefone(String valor) {
    if (valor.trim().isEmpty) return mensagemTelefoneVazio;
    return telefoneValido(valor) ? null : mensagemTelefoneInvalido;
  }

  /// E-mail opcional, validado se preenchido.
  static String? emailOpcional(String valor) {
    final email = valor.trim();
    if (email.isEmpty) return null;
    return emailValido(email) ? null : mensagemEmailInvalido;
  }

  /// Data de nascimento opcional (`dd/mm/aaaa`), que não pode ser depois de
  /// [hoje].
  static String? dataNascimento(String valor, DateTime hoje) {
    if (valor.trim().isEmpty) return null;
    final data = lerData(valor);
    if (data == null) return mensagemDataInvalida;
    return data.isAfter(somenteData(hoje)) ? mensagemDataFutura : null;
  }
}
