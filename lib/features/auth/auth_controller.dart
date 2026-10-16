import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import '../../data/models/terapeuta.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/sqlite_auth_repository.dart';
import 'login_service.dart';

final authRepositoryProvider = FutureProvider<AuthRepository>(
  (ref) async => SqliteAuthRepository(await ref.watch(databaseProvider.future)),
);

final loginServiceProvider = FutureProvider<LoginService>(
  (ref) async => LoginService(await ref.watch(authRepositoryProvider.future)),
);

/// Terapeuta logado (`null` quando não há sessão).
///
/// Ao iniciar, restaura a sessão salva no aparelho (RKZ-02).
final authControllerProvider =
    AsyncNotifierProvider<AuthController, Terapeuta?>(AuthController.new);

class AuthController extends AsyncNotifier<Terapeuta?> {
  @override
  Future<Terapeuta?> build() async {
    final service = await ref.watch(loginServiceProvider.future);
    return service.restaurarSessao();
  }

  Future<LoginResultado> entrar(String email, String senha) async {
    final service = await ref.read(loginServiceProvider.future);
    final resultado = await service.entrar(email, senha);
    if (resultado case LoginSucesso(:final terapeuta)) {
      state = AsyncData(terapeuta);
    }
    return resultado;
  }

  Future<void> sair() async {
    final service = await ref.read(loginServiceProvider.future);
    await service.sair();
    state = const AsyncData(null);
  }
}

/// Id do terapeuta logado (`null` sem sessão). Só muda quando outro terapeuta
/// entra ou sai, então quem depende dele não recarrega à toa.
final terapeutaLogadoIdProvider = Provider<int?>(
  (ref) => ref.watch(authControllerProvider.select((a) => a.value?.id)),
);
