import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/data/models/paciente.dart';

void main() {
  final linha = <String, Object?>{
    'id': 3,
    'terapeuta_id': 1,
    'nome': 'Mariana Souza',
    'telefone': '(11) 98765-4321',
    'email': 'mariana@exemplo.com',
    'data_nascimento': '1988-04-12',
    'observacoes': 'Tensão cervical.',
    'criado_em': '2026-10-14T08:30:00.000',
  };

  group('RKZ-06 modelo Paciente', () {
    test('fromMap lê as colunas da tabela paciente', () {
      final p = Paciente.fromMap(linha);
      expect(p.id, 3);
      expect(p.terapeutaId, 1);
      expect(p.nome, 'Mariana Souza');
      expect(p.telefone, '(11) 98765-4321');
      expect(p.email, 'mariana@exemplo.com');
      expect(p.dataNascimento, DateTime(1988, 4, 12));
      expect(p.observacoes, 'Tensão cervical.');
      expect(p.criadoEm, DateTime(2026, 10, 14, 8, 30));
    });

    test('toMap grava a data de nascimento sem horário (ida e volta)', () {
      expect(Paciente.fromMap(linha).toMap(), linha);
    });

    test('campos opcionais podem ser nulos', () {
      final p = Paciente.fromMap({
        ...linha,
        'email': null,
        'data_nascimento': null,
        'observacoes': null,
      });
      expect(p.email, isNull);
      expect(p.dataNascimento, isNull);
      expect(p.observacoes, isNull);
      expect(p.toMap()['data_nascimento'], isNull);
    });
  });
}
