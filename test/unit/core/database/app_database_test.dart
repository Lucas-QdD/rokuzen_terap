import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rokuzen_terapeuta/core/database/app_database.dart';
import 'package:rokuzen_terapeuta/core/database/migrations.dart';
import 'package:rokuzen_terapeuta/core/database/seed.dart';
import 'package:rokuzen_terapeuta/core/utils/password_hasher.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final _hoje = DateTime(2026, 10, 14);

Future<Database> _abrirEmMemoria({bool seed = true}) => openAppDatabase(
  factory: databaseFactoryFfi,
  path: inMemoryDatabasePath,
  seed: seed,
  hoje: _hoje,
);

Future<int> _contar(Database db, String tabela) async =>
    (await db.rawQuery('SELECT COUNT(*) AS n FROM $tabela')).first['n']! as int;

void main() {
  setUpAll(sqfliteFfiInit);

  group('Banco de dados — schema e migrações', () {
    late Database db;

    setUp(() async => db = await _abrirEmMemoria(seed: false));
    tearDown(() => db.close());

    test('cria todas as tabelas do modelo de dados', () async {
      final linhas = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
      );
      final tabelas = linhas.map((l) => l['name']).toSet();
      expect(
        tabelas,
        containsAll([
          'unidade',
          'terapeuta',
          'terapeuta_unidade',
          'paciente',
          'atendimento',
          'disponibilidade',
        ]),
      );
    });

    test('versão do banco é a última migração', () async {
      expect(await db.getVersion(), schemaVersion);
      expect(schemaVersion, 1);
    });

    test('foreign keys estão habilitadas', () async {
      final r = await db.rawQuery('PRAGMA foreign_keys');
      expect(r.first.values.first, 1);
    });

    test('sem seed, o banco começa vazio', () async {
      expect(await _contar(db, 'terapeuta'), 0);
      expect(await _contar(db, 'unidade'), 0);
    });

    test('runMigrations falha para versão inexistente', () async {
      expect(
        () => runMigrations(db, schemaVersion, schemaVersion + 1),
        throwsStateError,
      );
    });
  });

  group('Banco de dados — restrições', () {
    late Database db;
    late int terapeutaId;
    late int unidadeId;
    late int pacienteId;

    Map<String, Object?> atendimento([Map<String, Object?> extra = const {}]) =>
        {
          'terapeuta_id': terapeutaId,
          'paciente_id': pacienteId,
          'unidade_id': unidadeId,
          'inicio': '2026-10-14T09:00:00.000',
          'fim': '2026-10-14T10:00:00.000',
          'tipo': 'clinica',
          ...extra,
        };

    setUp(() async {
      db = await _abrirEmMemoria(seed: false);
      unidadeId = await db.insert('unidade', {'nome': 'Unidade Teste'});
      terapeutaId = await db.insert('terapeuta', {
        'nome': 'Teste',
        'email': 'teste@rokuzen.com',
        'senha_hash': 'h',
        'senha_salt': 's',
      });
      pacienteId = await db.insert('paciente', {
        'terapeuta_id': terapeutaId,
        'nome': 'Paciente',
        'telefone': '(11) 91234-5678',
        'criado_em': '2026-10-14T08:00:00.000',
      });
    });
    tearDown(() => db.close());

    test('atendimento válido usa status "agendado" por padrão', () async {
      final id = await db.insert('atendimento', atendimento());
      final r = await db.query('atendimento', where: 'id = ?', whereArgs: [id]);
      expect(r.single['status'], 'agendado');
      expect(r.single['disponibilidade_id'], isNull);
    });

    test('e-mail do terapeuta é único (sem diferenciar maiúsculas)', () async {
      expect(
        () => db.insert('terapeuta', {
          'nome': 'Outro',
          'email': 'TESTE@rokuzen.com',
          'senha_hash': 'h',
          'senha_salt': 's',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('paciente exige nome e telefone', () async {
      expect(
        () => db.insert('paciente', {
          'terapeuta_id': terapeutaId,
          'nome': 'Sem telefone',
          'criado_em': '2026-10-14T08:00:00.000',
        }),
        throwsA(isA<DatabaseException>()),
      );
      expect(
        () => db.insert('paciente', {
          'terapeuta_id': terapeutaId,
          'telefone': '(11) 91234-5678',
          'criado_em': '2026-10-14T08:00:00.000',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('rejeita chave estrangeira inexistente', () async {
      expect(
        () => db.insert('paciente', {
          'terapeuta_id': 999,
          'nome': 'Órfão',
          'telefone': '(11) 91234-5678',
          'criado_em': '2026-10-14T08:00:00.000',
        }),
        throwsA(isA<DatabaseException>()),
      );
      expect(
        () => db.insert('atendimento', atendimento({'unidade_id': 999})),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('rejeita tipo de atendimento inválido', () async {
      expect(
        () => db.insert('atendimento', atendimento({'tipo': 'domicilio'})),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('aceita todos os status válidos e rejeita os inválidos', () async {
      for (final status in ['agendado', 'realizado', 'cancelado', 'falta']) {
        await db.insert('atendimento', atendimento({'status': status}));
      }
      expect(
        () => db.insert('atendimento', atendimento({'status': 'pendente'})),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('rejeita atendimento com fim antes ou igual ao início', () async {
      expect(
        () => db.insert(
          'atendimento',
          atendimento({'fim': '2026-10-14T09:00:00.000'}),
        ),
        throwsA(isA<DatabaseException>()),
      );
      expect(
        () => db.insert('disponibilidade', {
          'terapeuta_id': terapeutaId,
          'unidade_id': unidadeId,
          'inicio': '2026-10-14T12:00:00.000',
          'fim': '2026-10-14T11:00:00.000',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('atendimento pode referenciar uma disponibilidade', () async {
      final dispId = await db.insert('disponibilidade', {
        'terapeuta_id': terapeutaId,
        'unidade_id': unidadeId,
        'inicio': '2026-10-14T08:00:00.000',
        'fim': '2026-10-14T12:00:00.000',
      });
      await db.insert(
        'atendimento',
        atendimento({'tipo': 'particular', 'disponibilidade_id': dispId}),
      );
      expect(await _contar(db, 'atendimento'), 1);
    });
  });

  group('RKZ-07 seed de demonstração', () {
    late Database db;

    setUp(() async => db = await _abrirEmMemoria());
    tearDown(() => db.close());

    test('cria as quatro unidades reais com shopping e cidade', () async {
      final unidades = await db.query('unidade', orderBy: 'id');
      expect(unidades.map((u) => u['nome']), [
        'Golden Square — São Bernardo do Campo',
        'Grand Plaza — Santo André',
        'Mooca Plaza — São Paulo',
        'West Plaza — São Paulo',
      ]);
    });

    test('endereço das unidades fica vazio até ser confirmado', () async {
      final unidades = await db.query('unidade', columns: ['endereco']);
      expect(unidades.map((u) => u['endereco']), everyElement(isNull));
    });

    test('cria o terapeuta de teste com login de demonstração', () async {
      final r = await db.query(
        'terapeuta',
        where: 'email = ?',
        whereArgs: [demoEmail],
      );
      expect(r, hasLength(1));
      final t = r.single;
      expect(
        PasswordHasher.verificar(
          'rokuzen123',
          t['senha_salt']! as String,
          t['senha_hash']! as String,
        ),
        isTrue,
      );
      expect(
        PasswordHasher.verificar(
          'senha-errada',
          t['senha_salt']! as String,
          t['senha_hash']! as String,
        ),
        isFalse,
      );
      expect(
        t['senha_hash'],
        isNot('rokuzen123'),
        reason: 'senha não pode ficar em texto puro',
      );
    });

    test('vincula o terapeuta às unidades', () async {
      expect(await _contar(db, 'terapeuta_unidade'), unidadesDemo.length);
    });

    test('cria pacientes fictícios com nome e telefone', () async {
      final pacientes = await db.query('paciente');
      expect(pacientes.length, greaterThanOrEqualTo(5));
      for (final p in pacientes) {
        expect(
          p['nome'],
          isA<String>().having((s) => s.isNotEmpty, 'não vazio', true),
        );
        expect(
          p['telefone'],
          isA<String>().having((s) => s.isNotEmpty, 'não vazio', true),
        );
      }
    });

    test('cria atendimentos passados, de hoje e futuros', () async {
      final hojeIso = '2026-10-14';
      final todos = await db.query('atendimento');
      expect(todos, isNotEmpty);
      final datas = todos.map((a) => (a['inicio']! as String).substring(0, 10));
      expect(datas.where((d) => d.compareTo(hojeIso) < 0), isNotEmpty);
      expect(datas.where((d) => d == hojeIso), isNotEmpty);
      expect(datas.where((d) => d.compareTo(hojeIso) > 0), isNotEmpty);
    });

    test('inclui ao menos um dia sem atendimentos na semana atual', () async {
      final datas = (await db.query(
        'atendimento',
        columns: ['inicio'],
      )).map((a) => (a['inicio']! as String).substring(0, 10)).toSet();
      final semana = List.generate(
        7,
        (i) => DateTime(2026, 10, 14 + i).toIso8601String().substring(0, 10),
      );
      expect(semana.where((d) => !datas.contains(d)), isNotEmpty);
    });

    test('atendimentos futuros estão agendados e passados não', () async {
      final todos = await db.query('atendimento');
      for (final a in todos) {
        final inicio = a['inicio']! as String;
        if (inicio.compareTo('2026-10-14') >= 0) {
          expect(a['status'], 'agendado');
        } else {
          expect(a['status'], isNot('agendado'));
        }
      }
    });

    test('atendimentos de um mesmo dia não se sobrepõem', () async {
      final todos = await db.query('atendimento', orderBy: 'inicio');
      for (var i = 1; i < todos.length; i++) {
        final anterior = todos[i - 1];
        final atual = todos[i];
        final mesmoDia =
            (anterior['inicio']! as String).substring(0, 10) ==
            (atual['inicio']! as String).substring(0, 10);
        if (mesmoDia) {
          expect(
            (atual['inicio']! as String).compareTo(anterior['fim']! as String),
            greaterThanOrEqualTo(0),
          );
        }
      }
    });

    test('usa os dois tipos de atendimento', () async {
      final tipos = (await db.query(
        'atendimento',
        columns: ['tipo'],
      )).map((a) => a['tipo']).toSet();
      expect(tipos, {'clinica', 'particular'});
    });

    test('seed é idempotente', () async {
      final antes = await _contar(db, 'atendimento');
      await seedDemoData(db, hoje: _hoje);
      expect(await _contar(db, 'terapeuta'), 1);
      expect(await _contar(db, 'unidade'), unidadesDemo.length);
      expect(await _contar(db, 'atendimento'), antes);
    });
  });

  group('RKZ-07 seed apenas na primeira execução', () {
    late Directory dir;

    setUp(
      () async => dir = await Directory.systemTemp.createTemp('rokuzen_db_'),
    );
    tearDown(() => dir.delete(recursive: true));

    test('reabrir o banco não duplica nem recria os dados', () async {
      final caminho = p.join(dir.path, databaseFileName);

      var db = await openAppDatabase(
        factory: databaseFactoryFfi,
        path: caminho,
        hoje: _hoje,
      );
      final pacienteId = await db.insert('paciente', {
        'terapeuta_id': 1,
        'nome': 'Novo Paciente',
        'telefone': '(11) 99999-0000',
        'criado_em': '2026-10-14T10:00:00.000',
      });
      final totalPacientes = await _contar(db, 'paciente');
      final totalAtendimentos = await _contar(db, 'atendimento');
      await db.close();

      db = await openAppDatabase(
        factory: databaseFactoryFfi,
        path: caminho,
        hoje: _hoje,
      );
      expect(await _contar(db, 'terapeuta'), 1);
      expect(await _contar(db, 'paciente'), totalPacientes);
      expect(await _contar(db, 'atendimento'), totalAtendimentos);
      expect(
        await db.query('paciente', where: 'id = ?', whereArgs: [pacienteId]),
        hasLength(1),
      );
      await db.close();
    });
  });
}
