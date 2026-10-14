import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rokuzen_terapeuta/data/models/terapeuta.dart';
import 'package:rokuzen_terapeuta/data/repositories/auth_repository.dart';
import 'package:rokuzen_terapeuta/features/auth/login_service.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const terapeuta = Terapeuta(id: 7, nome: 'Ana', email: 'ana@rokuzen.com');

  late _MockAuthRepository repository;
  late LoginService service;

  setUp(() {
    repository = _MockAuthRepository();
    service = LoginService(repository);
    when(() => repository.salvarSessao(any())).thenAnswer((_) async {});
    when(() => repository.encerrarSessao()).thenAnswer((_) async {});
  });

  group('RKZ-01 serviço de login — validação dos campos', () {
    test('e-mail vazio é rejeitado sem consultar o banco', () async {
      final r = await service.entrar('   ', 'rokuzen123');
      expect(r, const LoginFalha(LoginService.mensagemEmailVazio));
      verifyZeroInteractions(repository);
    });

    test('e-mail mal formado é rejeitado sem consultar o banco', () async {
      final r = await service.entrar('terapeuta@', 'rokuzen123');
      expect(r, const LoginFalha(LoginService.mensagemEmailInvalido));
      verifyZeroInteractions(repository);
    });

    test('senha vazia é rejeitada sem consultar o banco', () async {
      final r = await service.entrar('ana@rokuzen.com', '');
      expect(r, const LoginFalha(LoginService.mensagemSenhaVazia));
      verifyZeroInteractions(repository);
    });
  });

  group('RKZ-01 serviço de login — credenciais', () {
    test('credenciais válidas retornam o terapeuta e abrem sessão', () async {
      when(() => repository.autenticar('ana@rokuzen.com', 'segredo'))
          .thenAnswer((_) async => terapeuta);

      final r = await service.entrar('ana@rokuzen.com', 'segredo');

      expect(r, const LoginSucesso(terapeuta));
      verify(() => repository.salvarSessao(7)).called(1);
    });

    test('e-mail é normalizado (espaços e maiúsculas)', () async {
      when(() => repository.autenticar(any(), any()))
          .thenAnswer((_) async => terapeuta);

      await service.entrar('  Ana@Rokuzen.COM ', 'segredo');

      verify(() => repository.autenticar('ana@rokuzen.com', 'segredo'));
    });

    test('senha é usada exatamente como digitada', () async {
      when(() => repository.autenticar(any(), any()))
          .thenAnswer((_) async => null);

      await service.entrar('ana@rokuzen.com', ' segredo ');

      verify(() => repository.autenticar('ana@rokuzen.com', ' segredo '));
    });

    test(
      'credenciais inválidas retornam erro genérico e não abrem sessão',
      () async {
        when(() => repository.autenticar(any(), any()))
            .thenAnswer((_) async => null);

        final r = await service.entrar('ana@rokuzen.com', 'errada');

        expect(r, const LoginFalha(LoginService.mensagemCredenciaisInvalidas));
        verifyNever(() => repository.salvarSessao(any()));
      },
    );
  });

  group('RKZ-01 resultado do login', () {
    test('resultados com o mesmo conteúdo são iguais', () {
      expect(const LoginSucesso(terapeuta), const LoginSucesso(terapeuta));
      expect(
        const LoginSucesso(terapeuta).hashCode,
        const LoginSucesso(terapeuta).hashCode,
      );
      expect(const LoginFalha('x').hashCode, const LoginFalha('x').hashCode);
      expect(const LoginFalha('x'), isNot(const LoginFalha('y')));
      expect(const LoginFalha('x'), isNot(const LoginSucesso(terapeuta)));
    });
  });

  group('RKZ-02 serviço de login — sessão', () {
    test('restaurarSessao retorna o terapeuta com sessão salva', () async {
      when(() => repository.sessaoAtual()).thenAnswer((_) async => terapeuta);
      expect(await service.restaurarSessao(), terapeuta);
    });

    test('restaurarSessao retorna null sem sessão salva', () async {
      when(() => repository.sessaoAtual()).thenAnswer((_) async => null);
      expect(await service.restaurarSessao(), isNull);
    });

    test('sair encerra a sessão', () async {
      await service.sair();
      verify(() => repository.encerrarSessao()).called(1);
    });
  });
}
