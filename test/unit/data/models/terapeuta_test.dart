import 'package:flutter_test/flutter_test.dart';
import 'package:rokuzen_terapeuta/data/models/terapeuta.dart';

void main() {
  group('RKZ-01 modelo Terapeuta', () {
    const terapeuta = Terapeuta(
      id: 1,
      nome: 'Ana',
      email: 'ana@rokuzen.com',
      telefone: '(11) 90000-0000',
    );

    test('fromMap lê as colunas da tabela terapeuta', () {
      final t = Terapeuta.fromMap({
        'id': 1,
        'nome': 'Ana',
        'email': 'ana@rokuzen.com',
        'telefone': '(11) 90000-0000',
        'senha_hash': 'h',
        'senha_salt': 's',
      });
      expect(t, terapeuta);
    });

    test('toMap não expõe hash nem salt da senha', () {
      expect(terapeuta.toMap(), {
        'id': 1,
        'nome': 'Ana',
        'email': 'ana@rokuzen.com',
        'telefone': '(11) 90000-0000',
      });
    });

    test('telefone é opcional', () {
      final t = Terapeuta.fromMap({'id': 2, 'nome': 'Bia', 'email': 'b@r.com'});
      expect(t.telefone, isNull);
    });

    test('igualdade por valor', () {
      expect(
        terapeuta,
        const Terapeuta(
          id: 1,
          nome: 'Ana',
          email: 'ana@rokuzen.com',
          telefone: '(11) 90000-0000',
        ),
      );
      expect(terapeuta.hashCode, terapeuta.copyComId(1).hashCode);
      expect(terapeuta, isNot(terapeuta.copyComId(2)));
    });
  });
}

extension on Terapeuta {
  Terapeuta copyComId(int id) =>
      Terapeuta(id: id, nome: nome, email: email, telefone: telefone);
}
