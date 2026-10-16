// Telefone brasileiro com DDD (RN09).
//
// Funções puras (sem Flutter). Aceita digitação com ou sem máscara: dígitos,
// espaços, parênteses, hífen e ponto.

final RegExp _caracteresPermitidos = RegExp(r'^[\d\s().-]*$');
final RegExp _naoDigito = RegExp(r'\D');

/// Indica se [telefone] tem DDD válido (11 a 99, sem zero) e 10 dígitos
/// (fixo) ou 11 (celular).
bool telefoneValido(String telefone) {
  if (!_caracteresPermitidos.hasMatch(telefone)) return false;
  final digitos = telefone.replaceAll(_naoDigito, '');
  if (digitos.length != 10 && digitos.length != 11) return false;
  return digitos[0] != '0' && digitos[1] != '0';
}

/// Telefone no formato de exibição: `(11) 98765-4321` ou `(11) 3456-7890`.
///
/// Lança [ArgumentError] se [telefone] não for válido. A mensagem não inclui o
/// número (dado pessoal).
String formatarTelefone(String telefone) {
  if (!telefoneValido(telefone)) throw ArgumentError('Telefone inválido.');
  final d = telefone.replaceAll(_naoDigito, '');
  final ddd = d.substring(0, 2);
  final numero = d.substring(2);
  final corte = numero.length - 4;
  return '($ddd) ${numero.substring(0, corte)}-${numero.substring(corte)}';
}
