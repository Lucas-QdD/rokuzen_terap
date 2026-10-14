/// Terapeuta da Rokuzen (usuário do app).
///
/// Não carrega hash nem salt da senha: as credenciais ficam restritas ao
/// repositório de autenticação.
class Terapeuta {
  const Terapeuta({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
  });

  final int id;
  final String nome;
  final String email;
  final String? telefone;

  factory Terapeuta.fromMap(Map<String, Object?> map) => Terapeuta(
    id: map['id']! as int,
    nome: map['nome']! as String,
    email: map['email']! as String,
    telefone: map['telefone'] as String?,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'nome': nome,
    'email': email,
    'telefone': telefone,
  };

  @override
  bool operator ==(Object other) =>
      other is Terapeuta &&
      other.id == id &&
      other.nome == nome &&
      other.email == email &&
      other.telefone == telefone;

  @override
  int get hashCode => Object.hash(id, nome, email, telefone);
}
