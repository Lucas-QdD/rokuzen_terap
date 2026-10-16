import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Configuração dos testes da pasta `capturas/` (só vale para ela).
///
/// - Carrega as fontes reais do Material (Roboto e ícones) do SDK do Flutter,
///   para o texto não sair como quadradinhos.
/// - Sempre grava os PNGs (`autoUpdateGoldenFiles`): aqui as imagens são
///   capturas de tela para a documentação, não comparações.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fontes = _pastaDeFontesDoSdk();

  await _carregar('Roboto', [
    for (final estilo in [
      'thin',
      'light',
      'regular',
      'medium',
      'bold',
      'black',
      'italic',
      'mediumitalic',
      'bolditalic',
    ])
      p.join(fontes, 'roboto-$estilo.ttf'),
  ]);
  await _carregar('MaterialIcons', [
    p.join(fontes, 'materialicons-regular.otf'),
  ]);

  autoUpdateGoldenFiles = true;
  await testMain();
}

Future<void> _carregar(String familia, List<String> arquivos) async {
  final loader = FontLoader(familia);
  for (final arquivo in arquivos) {
    final bytes = File(arquivo).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// `<FLUTTER_ROOT>/bin/cache/artifacts/material_fonts`.
///
/// Usa a variável FLUTTER_ROOT; sem ela, sobe a partir do `flutter_tester`,
/// que fica em `bin/cache/artifacts/engine/<plataforma>/`.
String _pastaDeFontesDoSdk() {
  final raiz = Platform.environment['FLUTTER_ROOT'];
  final candidatas = [
    if (raiz != null)
      p.join(raiz, 'bin', 'cache', 'artifacts', 'material_fonts'),
    p.join(
      File(Platform.resolvedExecutable).parent.parent.parent.path,
      'material_fonts',
    ),
  ];
  for (final pasta in candidatas) {
    if (File(p.join(pasta, 'roboto-regular.ttf')).existsSync()) return pasta;
  }
  throw StateError(
    'Fontes do Material não encontradas no SDK do Flutter. '
    'Procurei em: ${candidatas.join(', ')}. '
    'Rode "flutter precache" ou defina FLUTTER_ROOT.',
  );
}
