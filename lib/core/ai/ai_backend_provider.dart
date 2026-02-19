// lib/core/ai/ai_backend_provider.dart
import 'package:pulseedge/core/ai/backends/ai_backend.dart';
import 'package:pulseedge/core/ai/backends/groq_ai_backend.dart';
import 'package:pulseedge/core/ai/backends/hybrid_ai_backend.dart';
import 'package:pulseedge/core/ai/backends/local_ai_backend.dart';
import 'package:pulseedge/core/settings/ai_prefs.dart';

/// AI backend wiring only.
/// No AI logic here.
class AiBackendProvider {
  AiBackendProvider._();

  static AiBackend? _cached;

  /// Build (or return cached) backend
  static Future<AiBackend> get() async {
    final cached = _cached;
    if (cached != null) return cached;

    final prefs = AiPrefs();

    final bool preferLocal = await prefs.readPreferLocal();
    final String? groqKeyRaw = await prefs.readGroqApiKey();
    final String? groqKey = groqKeyRaw?.trim();

    final local = LocalAiBackend();

    // Groq backend exists ONLY if API key is present
    final GroqAiBackend? cloud =
        (groqKey != null && groqKey.isNotEmpty) ? GroqAiBackend() : null;

    late final AiBackend backend;

    if (cloud != null) {
      // Hybrid decides per-request based on preferLocal + local readiness.
      backend = HybridAiBackend(
        local: local,
        cloud: cloud,
        preferLocal: preferLocal,
      );
    } else {
      // No cloud available => local only
      backend = local;
    }

    _cached = backend;
    return backend;
  }

  /// Call when settings change
  static void invalidate() {
    _cached = null;
  }

  /// Optional: useful for debugging in UI (safe even if not used)
  static bool get hasCached => _cached != null;
}