import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

/// Raiz do app: tema e rotas (go_router).
class RokuzenApp extends ConsumerWidget {
  const RokuzenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Rokuzen Terapeuta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E5E4E)),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
