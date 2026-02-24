// lib/core/ai/pulse_ai_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulseedge/core/database/app_database.dart';
import 'package:pulseedge/core/ai/ai_backend_provider.dart';
import 'package:pulseedge/core/ai/ai_service.dart';
import 'package:pulseedge/core/ai/ai_tools.dart';
import 'package:pulseedge/core/ai/analytics_engine.dart';
import 'package:pulseedge/core/ai/pulse_ai_formatter.dart';
import 'package:pulseedge/core/ai/backends/ai_backend.dart';
import 'package:pulseedge/core/ai/backends/groq_ai_backend.dart';

/// DB-backed analytics engine (deterministic queries)
final analyticsEngineProvider = Provider<AnalyticsEngine>((ref) {
  return AnalyticsEngine(AppDatabase.instance);
});

/// Deterministic tool router (offline-first)
final aiToolsProvider = Provider<AiTools>((ref) {
  final engine = ref.watch(analyticsEngineProvider);
  return AiTools(engine, ref: ref);
});

/// Optional formatting (UI polish)
final aiResponseFormatterProvider = Provider<AiResponseFormatter>((ref) {
  return PulseAiFormatter();
});

/// AI backend (async): local / cloud / hybrid based on prefs.
/// IMPORTANT: AiBackendProvider.get() should NEVER crash the app.
/// If nothing is available, it should return a Disabled backend (implements AiBackend).
final aiBackendProvider = FutureProvider<AiBackend>((ref) async {
  return AiBackendProvider.get();
});

/// AI service used by chat UI (tools first; backend optional via provider)
final aiServiceProvider = Provider<AiService>((ref) {
  final tools = ref.watch(aiToolsProvider);
  final formatter = ref.watch(aiResponseFormatterProvider);

  return AiService(
    tools: tools,
    formatter: formatter,
    backendProvider: () async {
      // This ensures ref.invalidate(aiBackendProvider) actually affects AiService.
      return ref.read(aiBackendProvider.future);
    },
  );
});

/// ✅ Groq-only backend (ignores GGUF/local readiness completely)
final groqBackendProvider = Provider<GroqAiBackend>((ref) {
  final backend = GroqAiBackend();
  ref.onDispose(backend.dispose);
  return backend;
});