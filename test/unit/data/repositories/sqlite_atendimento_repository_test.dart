import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/data/models/atendimento.dart';
import 'package:rokuzen_terapeuta/data/repositories/sqlite_atendimento_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/banco_teste.dart';
import '../../../helpers/dados_teste.dart';

void main() {
  late Database db;
  late DadosTeste dados;
  late SqliteAtendimentoRepository repository;
  late int ana;
  late int bia;

  final dia14 = DateTime(2026, 10, 14);
  final dia15 = DateTime(2026, 10, 15);

  Future<void> bancoComDoisTerapeutas() async {
    db = await abrirBancoDeTeste(seed: false);
    dados = DadosTeste(db);
    repository = SqliteAtendimentoRepository(db);
    ana = await dados.terapeuta();
    bia = await dados.terapeuta(nome: 'Bia', email: 'bia@rokuzen.com');
  }

  group('RKZ-03 AtendimentoRepository — listar por período', () {
    setUp(bancoComDoisTerapeutas);

    test('traz os atendimentos do terapeuta com paciente e unidade', () async {
      final id = await dados.atendimento(
        terapeutaId: ana,
        paciente: 'Mariana Souza',
        unidade: 'West Plaza — São Paulo',
        inicio: DateTime(2026, 10, 14, 9),
        fim: DateTime(2026, 10, 14, 10, 30),
        tipo: 'particular',
        status: 'realizado',
      );

      final lista = await repository.listarPorPeriodo(ana, dia14, dia15);

      expect(lista, hasLength(1));
      final d = lista.single;
      expect(d.atendimento.id, id);
      expect(d.atendimento.inicio, DateTime(2026, 10, 14, 9));
      expect(d.atendimento.fim, DateTime(2026, 10, 14, 10, 30));
      expect(d.atendimento.tipo, TipoAtendimento.particular);
      expect(d.atendimento.status, StatusAtendimento.realizado);
      expect(d.pacienteNome, 'Mariana Souza');
      expect(d.unidadeNome, 'West Plaza — São Paulo');
    });

    test('não traz atendimentos de outro terapeuta', () async {
      await dados.atendimento(
        terapeutaId: bia,
        paciente: 'Paciente da Bia',
        unidade: 'Grand Plaza — Santo André',
        inicio: DateTime(2026, 10, 14, 9),
        fim: DateTime(2026, 10, 14, 10),
      );
      expect(await repository.listarPorPeriodo(ana, dia14, dia15), isEmpty);
    });

    test('período inclui o início e exclui o fim', () async {
      Future<int> em(DateTime inicio) => dados.atendimento(
        terapeutaId: ana,
        paciente: 'P',
        unidade: 'U',
        inicio: inicio,
        fim: inicio.add(const Duration(minutes: 30)),
      );
      final antes = await em(DateTime(2026, 10, 13, 23, 30));
      final meiaNoite = await em(dia14);
      final ultimo = await em(DateTime(2026, 10, 14, 23, 59));
      final depois = await em(dia15);

      final ids = (await repository.listarPorPeriodo(
        ana,
        dia14,
        dia15,
      )).map((d) => d.atendimento.id);

      expect(ids, [meiaNoite, ultimo]);
      expect(ids, isNot(contains(antes)));
      expect(ids, isNot(contains(depois)));
    });

    test('vem em ordem de horário', () async {
      for (final hora in [16, 9, 13]) {
        await dados.atendimento(
          terapeutaId: ana,
          paciente: 'P$hora',
          unidade: 'U',
          inicio: DateTime(2026, 10, 14, hora),
          fim: DateTime(2026, 10, 14, hora + 1),
        );
      }
      final horas = (await repository.listarPorPeriodo(
        ana,
        dia14,
        dia15,
      )).map((d) => d.atendimento.inicio.hour);
      expect(horas, [9, 13, 16]);
    });

    test('inclui todas as situações (inclusive cancelado e falta)', () async {
      for (final (i, status) in [
        'agendado',
        'realizado',
        'cancelado',
        'falta',
      ].indexed) {
        await dados.atendimento(
          terapeutaId: ana,
          paciente: 'P$i',
          unidade: 'U',
          inicio: DateTime(2026, 10, 14, 9 + i),
          fim: DateTime(2026, 10, 14, 10 + i),
          status: status,
        );
      }
      expect(
        await repository.listarPorPeriodo(ana, dia14, dia15),
        hasLength(4),
      );
    });
  });

  group('RKZ-05 AtendimentoRepository — buscar por id', () {
    setUp(bancoComDoisTerapeutas);

    test('traz o atendimento com paciente e unidade', () async {
      final id = await dados.atendimento(
        terapeutaId: ana,
        paciente: 'Carlos Lima',
        unidade: 'Mooca Plaza — São Paulo',
        inicio: DateTime(2026, 10, 14, 14, 30),
        fim: DateTime(2026, 10, 14, 15, 30),
      );
      final d = await repository.buscarPorId(ana, id);
      expect(d?.atendimento.id, id);
      expect(d?.pacienteNome, 'Carlos Lima');
      expect(d?.unidadeNome, 'Mooca Plaza — São Paulo');
    });

    test('não traz atendimento de outro terapeuta', () async {
      final id = await dados.atendimento(
        terapeutaId: bia,
        paciente: 'Paciente da Bia',
        unidade: 'U',
        inicio: DateTime(2026, 10, 14, 9),
        fim: DateTime(2026, 10, 14, 10),
      );
      expect(await repository.buscarPorId(ana, id), isNull);
    });

    test('id inexistente retorna null', () async {
      expect(await repository.buscarPorId(ana, 999), isNull);
    });
  });

  group('RKZ-03 AtendimentoRepository com o seed de demonstração', () {
    test('hoje tem atendimentos e há um dia vazio na semana', () async {
      final seedDb = await abrirBancoDeTeste();
      final repo = SqliteAtendimentoRepository(seedDb);
      final demo = (await seedDb.query('terapeuta')).single['id']! as int;

      expect(await repo.listarPorPeriodo(demo, dia14, dia15), isNotEmpty);

      var diasVazios = 0;
      for (var i = 0; i < 7; i++) {
        final de = DateTime(2026, 10, 14 + i);
        final ate = DateTime(2026, 10, 15 + i);
        if ((await repo.listarPorPeriodo(demo, de, ate)).isEmpty) diasVazios++;
      }
      expect(diasVazios, greaterThan(0));
    });
  });
}
