import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/agenda/agenda_page.dart';
import '../features/agenda/atendimento_page.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_page.dart';
import '../features/pacientes/cadastro_paciente_page.dart';
import '../features/pacientes/pacientes_page.dart';

abstract final class Rotas {
  static const String carregando = '/carregando';
  static const String login = '/login';
  static const String agenda = '/agenda';

  static const String pacientes = '$agenda/pacientes';
  static const String novoPaciente = '$pacientes/novo';

  static String atendimento(int id) => '$agenda/atendimento/$id';
}

/// Rotas do app. Sem sessão, qualquer rota leva ao login; com sessão, o
/// login leva à agenda (RKZ-01, RKZ-02).
final routerProvider = Provider<GoRouter>((ref) {
  final mudouLogin = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => mudouLogin.value++);

  final router = GoRouter(
    initialLocation: Rotas.agenda,
    refreshListenable: mudouLogin,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final destino = state.matchedLocation;

      if (auth.isLoading && !auth.hasValue) {
        return destino == Rotas.carregando ? null : Rotas.carregando;
      }
      if (auth.value == null) {
        return destino == Rotas.login ? null : Rotas.login;
      }
      if (destino == Rotas.login || destino == Rotas.carregando) {
        return Rotas.agenda;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Rotas.carregando,
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: Rotas.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Rotas.agenda,
        builder: (context, state) => const AgendaPage(),
        routes: [
          GoRoute(
            path: 'atendimento/:id',
            builder: (context, state) => AtendimentoPage(
              id: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(
            path: 'pacientes',
            builder: (context, state) => const PacientesPage(),
            routes: [
              GoRoute(
                path: 'novo',
                builder: (context, state) => const CadastroPacientePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    mudouLogin.dispose();
  });
  return router;
});
