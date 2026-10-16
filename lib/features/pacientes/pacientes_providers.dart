import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import '../../core/relogio.dart';
import '../../data/models/paciente.dart';
import '../../data/repositories/paciente_repository.dart';
import '../../data/repositories/sqlite_paciente_repository.dart';
import '../auth/auth_controller.dart';
import 'cadastro_paciente_service.dart';

final pacienteRepositoryProvider = FutureProvider<PacienteRepository>(
  (ref) async => SqlitePacienteRepository(
    await ref.watch(databaseProvider.future),
    agora: ref.watch(agoraProvider),
  ),
);

final cadastroPacienteServiceProvider = FutureProvider<CadastroPacienteService>(
  (ref) async => CadastroPacienteService(
    await ref.watch(pacienteRepositoryProvider.future),
    agora: ref.watch(agoraProvider),
  ),
);

/// Pacientes do terapeuta logado, em ordem alfabética (RKZ-06).
final pacientesProvider = FutureProvider.autoDispose<List<Paciente>>((
  ref,
) async {
  final terapeutaId = ref.watch(terapeutaLogadoIdProvider);
  if (terapeutaId == null) return const [];
  final repository = await ref.watch(pacienteRepositoryProvider.future);
  return repository.listar(terapeutaId);
});
