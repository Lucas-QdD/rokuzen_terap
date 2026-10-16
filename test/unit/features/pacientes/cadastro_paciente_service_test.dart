import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rokuzen_terapeuta/core/utils/validadores.dart';
import 'package:rokuzen_terapeuta/data/models/paciente.dart';
import 'package:rokuzen_terapeuta/data/repositories/paciente_repository.dart';
import 'package:rokuzen_terapeuta/features/pacientes/cadastro_paciente_service.dart';

class _MockPacienteRepository extends Mock implements PacienteRepository {}

void main() {
  late _MockPacienteRepository repository;
  late CadastroPacienteService service;

  final salvo = Paciente(
    id: 10,
    terapeutaId: 7,
    nome: 'Ana Beatriz Costa',
    telefone: '(11) 91234-5678',
    criadoEm: DateTime(2026, 10, 14, 10),
  );

  setUpAll(
    () => registerFallbackValue(const NovoPaciente(nome: '', telefone: '')),
  );

  setUp(() {
    repository = _MockPacienteRepository();
    service = CadastroPacienteService(
      repository,
      agora: () => DateTime(2026, 10, 14, 10),
    );
    when(() => repository.cadastrar(any(), any()))
        .thenAnswer((_) async => salvo);
  });

  NovoPaciente gravado() =>
      verify(() => repository.cadastrar(7, captureAny())).captured.single
          as NovoPaciente;

  group('RKZ-06 serviço de cadastro — dados válidos', () {
    test('cadastra com todos os campos, vinculado ao terapeuta', () async {
      final r = await service.cadastrar(
        terapeutaId: 7,
        nome: 'Ana Beatriz Costa',
        telefone: '(11) 91234-5678',
        email: 'ana.costa@exemplo.com',
        dataNascimento: '12/04/1988',
        observacoes: 'Prefere pressão leve.',
      );

      expect(r, isA<CadastroSucesso>());
      expect((r as CadastroSucesso).paciente, salvo);
      final novo = gravado();
      expect(novo.nome, 'Ana Beatriz Costa');
      expect(novo.telefone, '(11) 91234-5678');
      expect(novo.email, 'ana.costa@exemplo.com');
      expect(novo.dataNascimento, DateTime(1988, 4, 12));
      expect(novo.observacoes, 'Prefere pressão leve.');
    });

    test('só nome e telefone já bastam', () async {
      final r = await service.cadastrar(
        terapeutaId: 7,
        nome: 'Ana',
        telefone: '11912345678',
      );
      expect(r, isA<CadastroSucesso>());
      final novo = gravado();
      expect(novo.email, isNull);
      expect(novo.dataNascimento, isNull);
      expect(novo.observacoes, isNull);
    });

    test('normaliza: espaços, telefone formatado e e-mail minúsculo', () async {
      await service.cadastrar(
        terapeutaId: 7,
        nome: '  Ana   Costa ',
        telefone: '11 91234 5678',
        email: ' Ana.Costa@Exemplo.COM ',
        observacoes: '   ',
      );
      final novo = gravado();
      expect(novo.nome, 'Ana Costa');
      expect(novo.telefone, '(11) 91234-5678');
      expect(novo.email, 'ana.costa@exemplo.com');
      expect(novo.observacoes, isNull);
    });
  });

  group('RKZ-06 serviço de cadastro — dados inválidos', () {
    Future<Map<CampoPaciente, String>> erros({
      String nome = 'Ana',
      String telefone = '(11) 91234-5678',
      String email = '',
      String dataNascimento = '',
    }) async {
      final r = await service.cadastrar(
        terapeutaId: 7,
        nome: nome,
        telefone: telefone,
        email: email,
        dataNascimento: dataNascimento,
      );
      expect(r, isA<CadastroInvalido>());
      verifyNever(() => repository.cadastrar(any(), any()));
      return (r as CadastroInvalido).erros;
    }

    test('nome vazio', () async {
      expect(await erros(nome: ' '), {
        CampoPaciente.nome: Validadores.mensagemNomeVazio,
      });
    });

    test('telefone vazio', () async {
      expect(await erros(telefone: ''), {
        CampoPaciente.telefone: Validadores.mensagemTelefoneVazio,
      });
    });

    test('telefone sem DDD', () async {
      expect(await erros(telefone: '91234-5678'), {
        CampoPaciente.telefone: Validadores.mensagemTelefoneInvalido,
      });
    });

    test('e-mail mal formado', () async {
      expect(await erros(email: 'ana@'), {
        CampoPaciente.email: Validadores.mensagemEmailInvalido,
      });
    });

    test('data de nascimento futura', () async {
      expect(await erros(dataNascimento: '15/10/2026'), {
        CampoPaciente.dataNascimento: Validadores.mensagemDataFutura,
      });
    });

    test('data de nascimento inexistente', () async {
      expect(await erros(dataNascimento: '31/02/1990'), {
        CampoPaciente.dataNascimento: Validadores.mensagemDataInvalida,
      });
    });

    test('mostra todos os erros de uma vez', () async {
      expect(
        (await erros(
          nome: '',
          telefone: 'abc',
          email: 'x',
          dataNascimento: '99/99/9999',
        )).keys,
        CampoPaciente.values,
      );
    });
  });
}
