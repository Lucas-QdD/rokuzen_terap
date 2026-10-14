import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/data/models/atendimento.dart';
import 'package:rokuzen_terapeuta/data/models/atendimento_detalhado.dart';

void main() {
  final linha = <String, Object?>{
    'id': 5,
    'terapeuta_id': 1,
    'paciente_id': 2,
    'unidade_id': 3,
    'inicio': '2026-10-14T09:00:00.000',
    'fim': '2026-10-14T10:30:00.000',
    'tipo': 'particular',
    'status': 'realizado',
    'observacao': 'Tudo certo.',
    'disponibilidade_id': 4,
  };

  group('RKZ-05 modelo Atendimento', () {
    test('fromMap lê as colunas da tabela atendimento', () {
      final a = Atendimento.fromMap(linha);
      expect(a.id, 5);
      expect(a.terapeutaId, 1);
      expect(a.pacienteId, 2);
      expect(a.unidadeId, 3);
      expect(a.inicio, DateTime(2026, 10, 14, 9));
      expect(a.fim, DateTime(2026, 10, 14, 10, 30));
      expect(a.tipo, TipoAtendimento.particular);
      expect(a.status, StatusAtendimento.realizado);
      expect(a.observacao, 'Tudo certo.');
      expect(a.disponibilidadeId, 4);
    });

    test('toMap gera as mesmas colunas (ida e volta)', () {
      expect(Atendimento.fromMap(linha).toMap(), linha);
    });

    test('campos opcionais podem ser nulos', () {
      final a = Atendimento.fromMap({
        ...linha,
        'observacao': null,
        'disponibilidade_id': null,
      });
      expect(a.observacao, isNull);
      expect(a.disponibilidadeId, isNull);
    });

    test('duração é fim menos início', () {
      expect(Atendimento.fromMap(linha).duracao, const Duration(minutes: 90));
    });

    test('rejeita tipo ou situação desconhecidos', () {
      expect(
        () => Atendimento.fromMap({...linha, 'tipo': 'domicilio'}),
        throwsArgumentError,
      );
      expect(
        () => Atendimento.fromMap({...linha, 'status': 'pendente'}),
        throwsArgumentError,
      );
    });

    test('rótulos em português para a tela', () {
      expect(TipoAtendimento.values.map((t) => t.rotulo), [
        'Clínica',
        'Particular',
      ]);
      expect(StatusAtendimento.values.map((s) => s.rotulo), [
        'Agendado',
        'Realizado',
        'Cancelado',
        'Falta',
      ]);
    });
  });

  group('RKZ-03 modelo AtendimentoDetalhado', () {
    test('fromMap lê o atendimento e os nomes de paciente e unidade', () {
      final d = AtendimentoDetalhado.fromMap({
        ...linha,
        'paciente_nome': 'Mariana Souza',
        'unidade_nome': 'West Plaza — São Paulo',
      });
      expect(d.atendimento.id, 5);
      expect(d.pacienteNome, 'Mariana Souza');
      expect(d.unidadeNome, 'West Plaza — São Paulo');
    });
  });
}
