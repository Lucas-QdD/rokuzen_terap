import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/relogio.dart';
import '../../core/utils/datas.dart';
import '../auth/auth_controller.dart';
import 'cadastro_paciente_service.dart';
import 'pacientes_providers.dart';

/// Formulário de cadastro de paciente (RKZ-06, RN09).
///
/// A validação fica no [CadastroPacienteService]; a tela só exibe os erros
/// que ele devolve.
class CadastroPacientePage extends ConsumerStatefulWidget {
  const CadastroPacientePage({super.key});

  @override
  ConsumerState<CadastroPacientePage> createState() =>
      _CadastroPacientePageState();
}

class _CadastroPacientePageState extends ConsumerState<CadastroPacientePage> {
  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _email = TextEditingController();
  final _nascimento = TextEditingController();
  final _observacoes = TextEditingController();
  Map<CampoPaciente, String> _erros = const {};
  bool _salvando = false;

  @override
  void dispose() {
    for (final c in [_nome, _telefone, _email, _nascimento, _observacoes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _limparErro(CampoPaciente campo) {
    if (_erros.containsKey(campo)) {
      setState(() => _erros = {..._erros}..remove(campo));
    }
  }

  Future<void> _escolherData() async {
    final hoje = somenteData(ref.read(agoraProvider)());
    final digitada = lerData(_nascimento.text);
    final inicial = digitada != null && !digitada.isAfter(hoje)
        ? digitada
        : DateTime(1990);
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(1900),
      lastDate: hoje,
    );
    if (escolhida == null) return;
    _nascimento.text = formatarData(escolhida);
    _limparErro(CampoPaciente.dataNascimento);
  }

  Future<void> _salvar() async {
    final terapeutaId = ref.read(terapeutaLogadoIdProvider);
    if (_salvando || terapeutaId == null) return;
    setState(() => _salvando = true);

    final service = await ref.read(cadastroPacienteServiceProvider.future);
    final resultado = await service.cadastrar(
      terapeutaId: terapeutaId,
      nome: _nome.text,
      telefone: _telefone.text,
      email: _email.text,
      dataNascimento: _nascimento.text,
      observacoes: _observacoes.text,
    );

    if (!mounted) return;
    switch (resultado) {
      case CadastroInvalido(:final erros):
        setState(() {
          _erros = erros;
          _salvando = false;
        });
      case CadastroSucesso():
        ref.invalidate(pacientesProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Paciente cadastrado.')));
        context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    Widget campo({
      required TextEditingController controller,
      required String rotulo,
      CampoPaciente? validado,
      TextInputType? teclado,
      String? dica,
      Widget? sufixo,
      int linhas = 1,
      TextCapitalization capitalizacao = TextCapitalization.none,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: !_salvando,
        keyboardType: teclado,
        textCapitalization: capitalizacao,
        minLines: linhas,
        maxLines: linhas,
        forceErrorText: validado == null ? null : _erros[validado],
        onChanged: validado == null ? null : (_) => _limparErro(validado),
        decoration: InputDecoration(
          labelText: rotulo,
          hintText: dica,
          suffixIcon: sufixo,
          errorMaxLines: 2,
          border: const OutlineInputBorder(),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Novo paciente')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              campo(
                controller: _nome,
                rotulo: 'Nome *',
                validado: CampoPaciente.nome,
                capitalizacao: TextCapitalization.words,
              ),
              campo(
                controller: _telefone,
                rotulo: 'Telefone *',
                validado: CampoPaciente.telefone,
                teclado: TextInputType.phone,
                dica: '(11) 98765-4321',
              ),
              campo(
                controller: _email,
                rotulo: 'E-mail',
                validado: CampoPaciente.email,
                teclado: TextInputType.emailAddress,
              ),
              campo(
                controller: _nascimento,
                rotulo: 'Data de nascimento',
                validado: CampoPaciente.dataNascimento,
                teclado: TextInputType.datetime,
                dica: 'dd/mm/aaaa',
                sufixo: IconButton(
                  tooltip: 'Escolher data',
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: _salvando ? null : _escolherData,
                ),
              ),
              campo(
                controller: _observacoes,
                rotulo: 'Observações',
                linhas: 3,
                capitalizacao: TextCapitalization.sentences,
              ),
              Text('* obrigatório', style: tema.textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
