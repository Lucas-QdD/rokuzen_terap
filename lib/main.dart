import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/localizacao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configurarLocalizacao();
  runApp(const ProviderScope(child: RokuzenApp()));
}
