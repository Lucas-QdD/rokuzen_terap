import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
import 'login_service.dart';

/// Tela de login (RKZ-01). Após o login, o roteador leva à agenda.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_enviando) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });

    final resultado = await ref
        .read(authControllerProvider.notifier)
        .entrar(_email.text, _senha.text);

    if (!mounted) return;
    setState(() {
      _enviando = false;
      if (resultado case LoginFalha(:final mensagem)) _erro = mensagem;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Rokuzen Terapeuta',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _email,
                      enabled: !_enviando,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _senha,
                      enabled: !_enviando,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _entrar(),
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _erro!,
                        style: TextStyle(color: tema.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _enviando ? null : _entrar,
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
