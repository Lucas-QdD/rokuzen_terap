import '../models/terapeuta.dart';

/// Autenticação do terapeuta e sessão no aparelho (RKZ-01, RKZ-02).
abstract interface class AuthRepository {
  /// Retorna o terapeuta se [email] e [senha] conferem; senão, `null`.
  ///
  /// Não abre sessão: isso é responsabilidade de quem chama.
  Future<Terapeuta?> autenticar(String email, String senha);

  /// Terapeuta com sessão salva no aparelho, se houver.
  Future<Terapeuta?> sessaoAtual();

  /// Salva a sessão de [terapeutaId], substituindo a anterior.
  Future<void> salvarSessao(int terapeutaId);

  /// Remove a sessão salva (botão Sair).
  Future<void> encerrarSessao();
}
