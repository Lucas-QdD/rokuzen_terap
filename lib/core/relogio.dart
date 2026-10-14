import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Relógio do app. Nos testes, sobrescrever com um horário fixo:
/// `agoraProvider.overrideWithValue(() => DateTime(2026, 10, 14, 8))`.
final agoraProvider = Provider<DateTime Function()>((ref) => DateTime.now);
