// lib/core/ai/backends/hybrid_ai_backend.dart
import 'dart:async';

import 'ai_backend.dart';
import 'local_ai_backend.dart';
import 'groq_ai_backend.dart';

/// Hybrid backend:
/// - preferLocal=true: try local first; fallback to cloud
/// - preferLocal=false: try cloud first; fallback to local
///
/// Key rule: DO NOT depend on local readiness getters.
/// Just attempt and fallback on exceptions.
class HybridAiBackend implements AiBackend {
  HybridAiBackend({
    required this.local,
    required this.cloud,
    this.preferLocal = true,
  });

  final LocalAiBackend? local;
  final GroqAiBackend? cloud;
  final bool preferLocal;

  //bool get _hasLocal => local != null;
  //bool get _hasCloud => cloud != null;

  Never _noBackend() => throw StateError('No AI backend available.');

  // Pick ordering only (not readiness)
  (AiBackend?, AiBackend?) _ordered() {
    if (preferLocal) {
      return (local, cloud);
    } else {
      return (cloud, local);
    }
  }

  // ---------------------------------------------------------------------------
  // generate (one-shot)
  // ---------------------------------------------------------------------------
  @override
  Future<String> generate(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
  }) async {
    final (primary, fallback) = _ordered();

    if (primary == null && fallback == null) _noBackend();

    // Try primary
    if (primary != null) {
      try {
        return await primary.generate(
          prompt,
          maxTokens: maxTokens,
          temperature: temperature,
        );
      } catch (_) {
        // fall through
      }
    }

    // Try fallback
    if (fallback != null) {
      return await fallback.generate(
        prompt,
        maxTokens: maxTokens,
        temperature: temperature,
      );
    }

    _noBackend();
  }

  // ---------------------------------------------------------------------------
  // draftNote (streaming)
  // ---------------------------------------------------------------------------
  @override
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  }) async* {
    final (primary, fallback) = _ordered();

    if (primary == null && fallback == null) {
      yield 'No AI backend available.';
      return;
    }

    // Streaming fallback is tricky: once you yield tokens, you can't “undo”.
    // Strategy: probe the stream by trying to read the FIRST event.
    // If it fails before first token, fallback to other backend.
    if (primary != null) {
      final primaryStream = _probeStream(
        () => primary.draftNote(
          transcript: transcript,
          patientContext: patientContext,
        ),
      );

      try {
        yield* primaryStream;
        return;
      } catch (_) {
        // fall through to fallback
      }
    }

    if (fallback != null) {
      yield* fallback.draftNote(
        transcript: transcript,
        patientContext: patientContext,
      );
      return;
    }

    yield 'No AI backend available.';
  }

  /// Probe: subscribe and pull the first token/event.
  /// If it throws before first event, treat as “failed fast” and allow fallback.
  Stream<String> _probeStream(Stream<String> Function() make) async* {
    late final StreamSubscription<String> sub;
    final controller = StreamController<String>();

    final first = Completer<void>();
    Object? firstError;

    sub = make().listen(
      (chunk) {
        if (!first.isCompleted) first.complete();
        controller.add(chunk);
      },
      onError: (e, st) {
        if (!first.isCompleted) {
          firstError = e;
          first.complete();
        } else {
          controller.addError(e, st);
        }
      },
      onDone: () {
        if (!first.isCompleted) first.complete();
        controller.close();
      },
      cancelOnError: false,
    );

    // Wait until we either get first token, or error, or done.
    await first.future;

    if (firstError != null) {
      await sub.cancel();
      await controller.close();
      throw firstError!;
    }

    yield* controller.stream;

    await sub.cancel();
  }

  // ---------------------------------------------------------------------------
  // extractIntakeJson (one-shot)
  // ---------------------------------------------------------------------------
  @override
  Future<Map<String, dynamic>> extractIntakeJson({
    required String rawText,
  }) async {
    final (primary, fallback) = _ordered();

    if (primary == null && fallback == null) _noBackend();

    if (primary != null) {
      try {
        return await primary.extractIntakeJson(rawText: rawText);
      } catch (_) {
        // fall through
      }
    }

    if (fallback != null) {
      return await fallback.extractIntakeJson(rawText: rawText);
    }

    _noBackend();
  }

  void dispose() {
    // Only dispose if you own these instances (your provider should decide ownership).
    local?.dispose();
    cloud?.dispose();
  }
}