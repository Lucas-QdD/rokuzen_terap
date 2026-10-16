import '../../core/utils/datas.dart';
import '../../core/utils/telefone.dart';
import '../../core/utils/validadores.dart';
import '../../data/models/paciente.dart';
import '../../data/repositories/paciente_repository.dart';

enum CampoPaciente { nome, telefone, email, dataNascimento }

/// Resultado de uma tentativa de cadastro.
sealed class CadastroResultado {
  const CadastroResultado();
}

final class CadastroSucesso extends CadastroResultado {
  const CadastroSucesso(this.paciente);

  final Paciente paciente;
}

final class CadastroInvalido extends CadastroResultado {
  const CadastroInvalido(this.erros);

  /// Mensagem de erro de cada campo inválido.
  final Map<CampoPaciente, String> erros;
}

/// Regras do cadastro de paciente (RKZ-06, RN09): valida, normaliza e grava
/// vinculado ao terapeuta.
///
/// Classe pura (sem Flutter) para ser testável em teste unitário.
class CadastroPacienteService {
  CadastroPacienteService(this._repository, {DateTime Function()? agora})
    : _agora = agora ?? DateTime.now;

  final PacienteRepository _repository;
  final DateTime Function() _agora;

  static final RegExp _espacos = RegExp(r'\s+');

  Future<CadastroResultado> cadastrar({
    required int terapeutaId,
    required String nome,
    required String telefone,
    String email = '',
    String dataNascimento = '',
    String observacoes = '',
  }) async {
    final erros = <CampoPaciente, String>{
      CampoPaciente.nome: ?Validadores.nome(nome),
      CampoPaciente.telefone: ?Validadores.telefone(telefone),
      CampoPaciente.email: ?Validadores.emailOpcional(email),
      CampoPaciente.dataNascimento: ?Validadores.dataNascimento(
        dataNascimento,
        _agora(),
      ),
    };
    if (erros.isNotEmpty) return CadastroInvalido(erros);

    final paciente = await _repository.cadastrar(
      terapeutaId,
      NovoPaciente(
        nome: nome.trim().replaceAll(_espacos, ' '),
        telefone: formatarTelefone(telefone),
        email: _vazioComoNulo(email.trim().toLowerCase()),
        dataNascimento: lerData(dataNascimento),
        observacoes: _vazioComoNulo(observacoes.trim()),
      ),
    );
    return CadastroSucesso(paciente);
  }

  static String? _vazioComoNulo(String texto) => texto.isEmpty ? null : texto;
}
