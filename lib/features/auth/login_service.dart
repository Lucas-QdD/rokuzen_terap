import '../../core/utils/validadores.dart';
import '../../data/models/terapeuta.dart';
import '../../data/repositories/auth_repository.dart';

/// Resultado de uma tentativa de login.
sealed class LoginResultado {
  const LoginResultado();
}

final class LoginSucesso extends LoginResultado {
  const LoginSucesso(this.terapeuta);

  final Terapeuta terapeuta;

  @override
  bool operator ==(Object other) =>
      other is LoginSucesso && other.terapeuta == terapeuta;

  @override
  int get hashCode => terapeuta.hashCode;
}

final class LoginFalha extends LoginResultado {
  const LoginFalha(this.mensagem);

  /// Mensagem pronta para exibir ao terapeuta.
  final String mensagem;

  @override
  bool operator ==(Object other) =>
      other is LoginFalha && other.mensagem == mensagem;

  @override
  int get hashCode => mensagem.hashCode;
}

/// Regras de login e sessão (RKZ-01, RKZ-02).
///
/// Classe pura (sem Flutter) para ser testável em teste unitário.
class LoginService {
  const LoginService(this._repository);

  final AuthRepository _repository;

  static const String mensagemEmailVazio = 'Informe o e-mail.';
  static const String mensagemEmailInvalido = 'E-mail inválido.';
  static const String mensagemSenhaVazia = 'Informe a senha.';

  /// Genérica de propósito: não revela se o e-mail está cadastrado.
  static const String mensagemCredenciaisInvalidas =
      'E-mail ou senha incorretos.';

  /// Valida os campos, confere as credenciais e, se corretas, abre a sessão.
  Future<LoginResultado> entrar(String email, String senha) async {
    final emailNormalizado = email.trim().toLowerCase();
    if (emailNormalizado.isEmpty) {
      return const LoginFalha(mensagemEmailVazio);
    }
    if (!Validadores.emailValido(emailNormalizado)) {
      return const LoginFalha(mensagemEmailInvalido);
    }
    if (senha.isEmpty) return const LoginFalha(mensagemSenhaVazia);

    final terapeuta = await _repository.autenticar(emailNormalizado, senha);
    if (terapeuta == null) {
      return const LoginFalha(mensagemCredenciaisInvalidas);
    }

    await _repository.salvarSessao(terapeuta.id);
    return LoginSucesso(terapeuta);
  }

  /// Terapeuta da sessão salva no aparelho, se houver.
  Future<Terapeuta?> restaurarSessao() => _repository.sessaoAtual();

  /// Encerra a sessão (botão Sair).
  Future<void> sair() => _repository.encerrarSessao();
}
