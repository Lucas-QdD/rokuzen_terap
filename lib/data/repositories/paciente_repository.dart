import '../models/paciente.dart';

/// Pacientes do terapeuta (RKZ-06). Todo acesso é filtrado pelo terapeuta.
abstract interface class PacienteRepository {
  /// Grava [novo] vinculado a [terapeutaId] e devolve o paciente com id.
  Future<Paciente> cadastrar(int terapeutaId, NovoPaciente novo);

  /// Pacientes de [terapeutaId] em ordem alfabética.
  Future<List<Paciente>> listar(int terapeutaId);
}
