import 'package:flutter/material.dart';

/// Raiz do app. Tema e rotas (go_router) entram aqui nas próximas histórias.
class RokuzenApp extends StatelessWidget {
  const RokuzenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rokuzen Terapeuta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E5E4E)),
      ),
      home: const Scaffold(body: Center(child: Text('Rokuzen Terapeuta'))),
    );
  }
}
