import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rokuzen_terapeuta/core/database/app_database.dart';
import 'package:rokuzen_terapeuta/core/database/seed.dart';
import 'package:rokuzen_terapeuta/data/repositories/sqlite_auth_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/banco_teste.dart';

void main() {
  late Database db;
  late SqliteAuthRepository repository;
  late int demoId;

  setUp(() async {
    db = await abrirBancoDeTeste();
    repository = SqliteAuthRepository(
      db,
      agora: () => DateTime(2026, 10, 14, 8, 30),
    );
    demoId =
        (await db.query(
              'terapeuta',
              where: 'email = ?',
              whereArgs: [demoEmail],
            )).single['id']!
            as int;
  });

  group('RKZ-01 AuthRepository — autenticação', () {
    test('autentica o terapeuta de demonstração', () async {
      final t = await repository.autenticar(demoEmail, demoSenha);
      expect(t, isNotNull);
      expect(t!.id, demoId);
      expect(t.email, demoEmail);
      expect(t.nome, 'Terapeuta Demonstração');
    });

    test('e-mail não diferencia maiúsculas', () async {
      final t = await repository.autenticar('Terapeuta@Rokuzen.COM', demoSenha);
      expect(t?.id, demoId);
    });

    test('senha incorreta não autentica', () async {
      expect(await repository.autenticar(demoEmail, 'rokuzen124'), isNull);
      expect(await repository.autenticar(demoEmail, ''), isNull);
    });

    test('senha diferencia maiúsculas', () async {
      expect(await repository.autenticar(demoEmail, 'ROKUZEN123'), isNull);
    });

    test('e-mail não cadastrado não autentica', () async {
      expect(
        await repository.autenticar('outra@rokuzen.com', demoSenha),
        isNull,
      );
    });

    test('autenticar não cria sessão por conta própria', () async {
      await repository.autenticar(demoEmail, demoSenha);
      expect(await repository.sessaoAtual(), isNull);
    });
  });

  group('RKZ-02 AuthRepository — sessão', () {
    test('sem login, não há sessão', () async {
      expect(await repository.sessaoAtual(), isNull);
    });

    test('salvarSessao guarda o terapeuta logado', () async {
      await repository.salvarSessao(demoId);
      final t = await repository.sessaoAtual();
      expect(t?.id, demoId);
      expect(t?.email, demoEmail);
    });

    test('registra o momento do login', () async {
      await repository.salvarSessao(demoId);
      final linha = (await db.query('sessao')).single;
      expect(linha['iniciada_em'], '2026-10-14T08:30:00.000');
    });

    test('só existe uma sessão por aparelho', () async {
      final outroId = await db.insert('terapeuta', {
        'nome': 'Outro',
        'email': 'outro@rokuzen.com',
        'senha_hash': 'h',
        'senha_salt': 's',
      });
      await repository.salvarSessao(demoId);
      await repository.salvarSessao(outroId);

      expect(await db.query('sessao'), hasLength(1));
      expect((await repository.sessaoAtual())?.id, outroId);
    });

    test('encerrarSessao remove a sessão', () async {
      await repository.salvarSessao(demoId);
      await repository.encerrarSessao();
      expect(await repository.sessaoAtual(), isNull);
      expect(await db.query('sessao'), isEmpty);
    });

    test('encerrarSessao sem sessão ativa não falha', () async {
      await repository.encerrarSessao();
      expect(await repository.sessaoAtual(), isNull);
    });

    test('rejeita sessão de terapeuta inexistente', () async {
      expect(
        () => repository.salvarSessao(999),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('sessão some se o terapeuta for removido', () async {
      await repository.salvarSessao(demoId);
      await db.delete('terapeuta', where: 'id = ?', whereArgs: [demoId]);
      expect(await repository.sessaoAtual(), isNull);
    });
  });

  group('RKZ-02 sessão mantida ao reabrir o app', () {
    late Directory dir;

    setUp(
      () async => dir = await Directory.systemTemp.createTemp('rokuzen_auth_'),
    );
    tearDown(() => dir.delete(recursive: true));

    test('sessão salva continua ativa após fechar e reabrir o banco', () async {
      final caminho = p.join(dir.path, databaseFileName);

      var arquivo = await openAppDatabase(
        factory: databaseFactoryFfiNoIsolate,
        path: caminho,
        hoje: hojeTeste,
      );
      final id = (await SqliteAuthRepository(
        arquivo,
      ).autenticar(demoEmail, demoSenha))!.id;
      await SqliteAuthRepository(arquivo).salvarSessao(id);
      await arquivo.close();

      arquivo = await openAppDatabase(
        factory: databaseFactoryFfiNoIsolate,
        path: caminho,
        hoje: hojeTeste,
      );
      expect((await SqliteAuthRepository(arquivo).sessaoAtual())?.id, id);
      await arquivo.close();
    });
  });
}
