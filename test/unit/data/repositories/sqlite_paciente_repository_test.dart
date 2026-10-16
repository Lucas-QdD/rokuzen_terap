import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/data/models/paciente.dart';
import 'package:rokuzen_terapeuta/data/repositories/sqlite_paciente_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/banco_teste.dart';
import '../../../helpers/dados_teste.dart';

void main() {
  late Database db;
  late SqlitePacienteRepository repository;
  late int ana;
  late int bia;

  const completo = NovoPaciente(
    nome: 'Ana Beatriz Costa',
    telefone: '(11) 91234-5678',
    email: 'ana.costa@exemplo.com',
    dataNascimento: null,
    observacoes: 'Prefere pressão leve.',
  );

  group('RKZ-06 PacienteRepository — cadastrar', () {
    setUp(() async {
      db = await abrirBancoDeTeste(seed: false);
      final dados = DadosTeste(db);
      ana = await dados.terapeuta();
      bia = await dados.terapeuta(nome: 'Bia', email: 'bia@rokuzen.com');
      repository = SqlitePacienteRepository(
        db,
        agora: () => DateTime(2026, 10, 14, 10, 15),
      );
    });

    test('grava o paciente vinculado ao terapeuta e devolve com id', () async {
      final p = await repository.cadastrar(ana, completo);

      expect(p.id, greaterThan(0));
      expect(p.terapeutaId, ana);
      expect(p.nome, 'Ana Beatriz Costa');
      expect(p.telefone, '(11) 91234-5678');
      expect(p.email, 'ana.costa@exemplo.com');
      expect(p.observacoes, 'Prefere pressão leve.');

      final linha = (await db.query(
        'paciente',
        where: 'id = ?',
        whereArgs: [p.id],
      )).single;
      expect(linha['terapeuta_id'], ana);
      expect(linha['nome'], 'Ana Beatriz Costa');
    });

    test('registra o momento do cadastro', () async {
      final p = await repository.cadastrar(ana, completo);
      expect(p.criadoEm, DateTime(2026, 10, 14, 10, 15));
      final linha = (await db.query('paciente')).single;
      expect(linha['criado_em'], '2026-10-14T10:15:00.000');
    });

    test('data de nascimento é gravada sem horário', () async {
      await repository.cadastrar(
        ana,
        NovoPaciente(
          nome: 'Com nascimento',
          telefone: '(11) 91234-5678',
          dataNascimento: DateTime(1988, 4, 12, 15),
        ),
      );
      final linha = (await db.query('paciente')).single;
      expect(linha['data_nascimento'], '1988-04-12');
    });

    test('campos opcionais vazios ficam nulos no banco', () async {
      await repository.cadastrar(
        ana,
        const NovoPaciente(nome: 'Só o básico', telefone: '(11) 3456-7890'),
      );
      final linha = (await db.query('paciente')).single;
      expect(linha['email'], isNull);
      expect(linha['data_nascimento'], isNull);
      expect(linha['observacoes'], isNull);
    });

    test('rejeita terapeuta inexistente', () async {
      expect(
        () => repository.cadastrar(999, completo),
        throwsA(isA<DatabaseException>()),
      );
    });

    group('listar', () {
      test('sem pacientes, a lista é vazia', () async {
        expect(await repository.listar(ana), isEmpty);
      });

      test('traz só os pacientes do terapeuta', () async {
        await repository.cadastrar(ana, completo);
        await repository.cadastrar(
          bia,
          const NovoPaciente(nome: 'Paciente da Bia', telefone: '11987654321'),
        );

        final lista = await repository.listar(ana);

        expect(lista.map((p) => p.nome), ['Ana Beatriz Costa']);
        expect(lista.single.terapeutaId, ana);
      });

      test('ordena por nome sem diferenciar maiúsculas', () async {
        for (final nome in ['carlos', 'Bruno', 'ana', 'Daniela']) {
          await repository.cadastrar(
            ana,
            NovoPaciente(nome: nome, telefone: '(11) 91234-5678'),
          );
        }
        final nomes = (await repository.listar(ana)).map((p) => p.nome);
        expect(nomes, ['ana', 'Bruno', 'carlos', 'Daniela']);
      });

      test('o paciente cadastrado aparece na lista', () async {
        final novo = await repository.cadastrar(ana, completo);
        final lista = await repository.listar(ana);
        expect(lista.single.id, novo.id);
      });
    });
  });

  group('RKZ-06 PacienteRepository com o seed de demonstração', () {
    test('lista os pacientes fictícios do terapeuta de teste', () async {
      final seedDb = await abrirBancoDeTeste();
      final demo = (await seedDb.query('terapeuta')).single['id']! as int;

      final lista = await SqlitePacienteRepository(seedDb).listar(demo);

      expect(lista, hasLength(6));
      expect(lista.first.nome, 'Carlos Henrique Lima');
    });
  });
}
