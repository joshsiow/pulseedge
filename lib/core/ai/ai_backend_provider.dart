// lib/core/ai/ai_backend_provider.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:pulseedge/core/ai/backends/ai_backend.dart';
import 'package:pulseedge/core/ai/backends/groq_ai_backend.dart';
import 'package:pulseedge/core/ai/backends/hybrid_ai_backend.dart';
import 'package:pulseedge/core/ai/backends/local_ai_backend.dart';
import 'package:pulseedge/core/settings/ai_prefs.dart';

/// Central place to build the AI backend (local / cloud / hybrid) based on prefs.
///
/// Design goals:
/// - Offline-first, but cloud can be used as fallback if configured.
/// - Never crash the app when not configured: returns a disabled backend.
/// - Cache the constructed backend; call [invalidate] when settings change.
///
/// IMPORTANT:
/// - GroqAiBackend in this project reads API key from FlutterSecureStorage key: 'groq_api_key'.
/// - Settings UI currently writes via AiPrefs; we "mirror" that into secure storage here.
class AiBackendProvider {
  AiBackendProvider._();

  static AiBackend? _cached;

  static const _secure = FlutterSecureStorage();
  static const _kGroqSecureKey = 'groq_api_key';

  /// Main entry: always returns *some* AiBackend (never throws).
  static Future<AiBackend> get() async {
    if (_cached != null) return _cached!;

    final prefs = AiPrefs();

    final preferLocal = await prefs.readPreferLocal();
    final groqKeyFromPrefs = (await prefs.readGroqApiKey())?.trim();
    final groqKeyFromSecure = (await _secure.read(key: _kGroqSecureKey))?.trim();

    // Decide which key to use (prefs wins, else secure storage).
    final effectiveGroqKey = (groqKeyFromPrefs != null && groqKeyFromPrefs.isNotEmpty)
        ? groqKeyFromPrefs
        : (groqKeyFromSecure != null && groqKeyFromSecure.isNotEmpty)
            ? groqKeyFromSecure
            : null;

    // If prefs has a key but secure storage doesn't (or differs), mirror it.
    if (effectiveGroqKey != null &&
        groqKeyFromPrefs != null &&
        groqKeyFromPrefs.isNotEmpty &&
        groqKeyFromPrefs != groqKeyFromSecure) {
      try {
        await _secure.write(key: _kGroqSecureKey, value: groqKeyFromPrefs);
      } catch (e) {
        debugPrint('[AiBackendProvider] Failed to write Groq key to secure storage: $e');
        // Do not fail the app.
      }
    }

    // Local backend: only meaningful on iOS/Android if your LocalAiBackend enforces that.
    // Still safe to construct it; it will throw only if actually used on unsupported platforms.
    final LocalAiBackend? local = (Platform.isIOS || Platform.isAndroid)
        ? LocalAiBackend()
        : null;

    // Cloud backend exists only if we have a key (GroqAiBackend reads it internally).
    final GroqAiBackend? cloud = effectiveGroqKey != null ? GroqAiBackend() : null;

    late final AiBackend backend;

    if (local != null && cloud != null) {
      backend = HybridAiBackend(
        local: local,
        cloud: cloud,
        preferLocal: preferLocal,
      );
    } else if (local != null && preferLocal) {
      backend = local;
    } else if (cloud != null) {
      backend = cloud;
    } else if (local != null) {
      // PreferLocal=false but no cloud; still allow local if possible.
      backend = local;
    } else {
      backend = _DisabledAiBackend(
        message:
            'No AI backend available.\n'
            '- Install a GGUF model for Offline AI, or\n'
            '- Set a Groq API key for cloud fallback.',
      );
    }

    _cached = backend;
    return backend;
  }

  /// If you want a nullable variant (rare), use this.
  static Future<AiBackend?> getOrNull() async {
    final b = await get();
    return b is _DisabledAiBackend ? null : b;
  }

  /// Call when AI settings change (preferLocal / api key / model install).
  static void invalidate() {
    _cached = null;
  }
}

/// A safe backend used when nothing is configured.
/// Prevents app crashes and provides user-facing messages.
class _DisabledAiBackend implements AiBackend {
  _DisabledAiBackend({required this.message});
  final String message;

  @override
  Future<String> generate(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
  }) async {
    return message;
  }

  @override
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  }) async* {
    yield message;
  }

  @override
  Future<Map<String, dynamic>> extractIntakeJson({required String rawText}) async {
    throw Exception(message);
  }
}