import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../auth/auth_service.dart';
import '../session/session_context_store.dart';

import 'analytics_engine.dart';
import 'ai_service.dart';
import 'backends/ai_backend.dart';

import 'backends/local_ai_backend.dart';
import 'backends/groq_ai_backend.dart';
import 'backends/hybrid_ai_backend.dart';

import 'model_store.dart';
import 'pulse_ai_formatter.dart';
import 'ai_tools.dart';

/// ---------------------------------------------------------------------------
/// Formatter (UI-only, pure)
/// ---------------------------------------------------------------------------

final pulseAiFormatterProvider = Provider<PulseAiFormatter>((ref) {
  return PulseAiFormatter();
});

/// ---------------------------------------------------------------------------
/// Analytics engine (deterministic, DB-backed)
/// ---------------------------------------------------------------------------

final analyticsEngineProvider = Provider<AnalyticsEngine>((ref) {
  final db = AppDatabase.instance;
  return AnalyticsEngine(db);
});

/// ---------------------------------------------------------------------------
/// Local AI backend (GGUF / fllama)
/// ---------------------------------------------------------------------------

final localAiBackendProvider = Provider<LocalAiBackend?>((ref) {
  // Do NOT initialise local inference on unsupported platforms
  if (!Platform.isIOS && !Platform.isAndroid) {
    return null;
  }

  // Avoid iOS Simulator (Metal instability)
  if (Platform.isIOS &&
      Platform.environment.containsKey('SIMULATOR_DEVICE_NAME')) {
    return null;
  }

  final backend = LocalAiBackend();
  ref.onDispose(backend.dispose);
  return backend;
});

/// ---------------------------------------------------------------------------
/// Cloud AI backend (Groq)
/// ---------------------------------------------------------------------------

final groqAiBackendProvider = Provider<GroqAiBackend?>((ref) {
  final backend = GroqAiBackend();
  ref.onDispose(backend.dispose);
  return backend;
});

/// ---------------------------------------------------------------------------
/// Hybrid AI backend (routing)
/// ---------------------------------------------------------------------------

final hybridAiBackendProvider = Provider<AiBackend>((ref) {
  final local = ref.watch(localAiBackendProvider);
  final cloud = ref.watch(groqAiBackendProvider);

  return HybridAiBackend(
    local: local,
    cloud: cloud,
    preferLocal: true,
  );
});

/// ---------------------------------------------------------------------------
/// Model store (GGUF presence / download / verification)
/// ---------------------------------------------------------------------------

final modelStoreProvider = Provider<ModelStore>((ref) {
  final store = ModelStore(
    modelFileName: 'Llama-3.2-3B-Instruct-Q5_K_M.gguf',

    // Optional (enable later):
    // downloadUrl: '<SIGNED_URL>',
    // sha256Hex: '<EXPECTED_SHA256>',
  );

  ref.onDispose(store.dispose);
  return store;
});

/// ---------------------------------------------------------------------------
/// Main AI service (single entry point for UI)
/// ---------------------------------------------------------------------------

final aiServiceProvider = Provider<AiService>((ref) {
  final backend = ref.watch(hybridAiBackendProvider);
  final formatter = ref.watch(pulseAiFormatterProvider);

  final auth = ref.watch(authServiceProvider);
  final sessionStore = ref.watch(sessionContextStoreProvider);
  
  final aiToolsProvider = Provider<AiTools>((ref) {
  final engine = ref.watch(analyticsEngineProvider);
    return AiTools(engine, ref: ref);
  });

  final tools = ref.watch(aiToolsProvider);

  return AiService(
    tools: tools,
    backend: backend,
    formatter: formatter,
    auth: auth,
    sessionStore: sessionStore,
  );
});

/// ---------------------------------------------------------------------------
/// Convenience: readiness flag (used for gating UI / buttons)
/// ---------------------------------------------------------------------------

final pulseAiReadyProvider = FutureProvider<bool>((ref) async {
  final store = ref.watch(modelStoreProvider);

  // If no local backend exists, AI is still "ready" via cloud
  final local = ref.watch(localAiBackendProvider);
  if (local == null) return true;

  return store.isModelReady();
});