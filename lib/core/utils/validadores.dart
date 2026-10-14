/// Validadores de campos de formulário.
///
/// Classe pura (sem Flutter) para ser testável em teste unitário.
abstract final class Validadores {
  // Formato prático: algo@dominio.tld, sem espaços e com um único "@".
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@.]+(\.[^\s@.]+)+$');

  /// Indica se [email] tem formato de e-mail.
  static bool emailValido(String email) => _email.hasMatch(email);
}
