import 'dart:io';

import 'ai_backend.dart';
import 'local_ai_backend.dart';
import 'groq_ai_backend.dart';

/// Hybrid AI backend.
///
/// Routing rules (in priority order):
/// 1. If local backend is preferred AND ready → use local
/// 2. Else if cloud backend exists → use cloud
/// 3. Else if local backend is ready → use local
/// 4. Else → error
///
/// Notes:
/// - Simulator defaults to cloud (local GGUF is unstable there)
/// - Real devices prefer local when model is ready
class HybridAiBackend implements AiBackend {
  HybridAiBackend({
    required this.local,
    required this.cloud,
    this.preferLocal = true,
  });

  final LocalAiBackend? local;
  final GroqAiBackend? cloud;
  final bool preferLocal;

  /// Determine if we should even attempt local inference on this platform.
  bool get _localAllowed {
    if (!Platform.isIOS && !Platform.isAndroid) return false;

    // Avoid local inference on iOS Simulator
    if (Platform.isIOS &&
        Platform.environment.containsKey('SIMULATOR_DEVICE_NAME')) {
      return false;
    }

    return true;
  }

  AiBackend _selectBackend({required bool localReady}) {
    // Prefer local if explicitly enabled and safe
    if (preferLocal && _localAllowed && localReady && local != null) {
      return local!;
    }

    // Fallback to cloud if available
    if (cloud != null) {
      return cloud!;
    }

    // Last resort: local if available
    if (_localAllowed && localReady && local != null) {
      return local!;
    }

    throw StateError('No AI backend available.');
  }

  // ---------------------------------------------------------------------------
  // AiBackend interface
  // ---------------------------------------------------------------------------

  @override
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  }) {
    final backend = _selectBackend(
      localReady: local != null,
    );

    return backend.draftNote(
      transcript: transcript,
      patientContext: patientContext,
    );
  }

  @override
  Future<Map<String, dynamic>> extractIntakeJson({
    required String rawText,
  }) async {
    final backend = _selectBackend(
      localReady: local != null,
    );

    return backend.extractIntakeJson(
      rawText: rawText,
    );
  }
}