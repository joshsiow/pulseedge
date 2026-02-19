// lib/core/ai/ai_service.dart

import 'ai_query.dart';
import 'ai_tool_response.dart';
import 'ai_tools.dart';
import 'backends/ai_backend.dart';
import 'ai_backend_provider.dart';

/// AiService
///
/// Central AI orchestration layer for PulseEdge.
///
/// Responsibilities:
/// - Accept free-text input
/// - Run deterministic, offline-first tools
/// - Optionally delegate to AI backend (local / cloud / hybrid)
/// - Keep UI and storage layers decoupled
///
/// Design rules:
/// - Deterministic tools FIRST
/// - AI backend is assistive-only
/// - Offline-safe by default
class AiService {
  final AiTools tools;

  /// Optional: inject a backend directly (e.g. tests, custom wiring).
  final AiBackend? backend;

  /// Optional: provide a lazy async backend resolver (preferred for hybrid/local/cloud).
  ///
  /// If null, we fall back to [backend]. If both null, AI assistive features are disabled.
  final Future<AiBackend?> Function()? backendProvider;

  /// Optional formatter for UI / chat rendering.
  final AiResponseFormatter? formatter;

  /// Optional auth/session references (future use).
  final Object? auth;
  final Object? sessionStore;

  AiService({
    required this.tools,
    this.backend,
    this.backendProvider,
    this.formatter,
    this.auth,
    this.sessionStore,
  });

  /// A convenience constructor for the “normal app path”:
  /// uses AiBackendProvider.get() (cached) under the hood.
  factory AiService.withProvider({
    required AiTools tools,
    AiResponseFormatter? formatter,
    Object? auth,
    Object? sessionStore,
  }) {
    return AiService(
      tools: tools,
      formatter: formatter,
      auth: auth,
      sessionStore: sessionStore,
      backendProvider: () async {
        // AiBackendProvider.get() returns AiBackend (non-null)
        // but we keep AiService flexible with nullable.
        return AiBackendProvider.get();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Deterministic pipeline
  // ---------------------------------------------------------------------------

  /// Run AI pipeline from raw user input.
  ///
  /// This ALWAYS tries deterministic tools first.
  Future<AiToolResponse> runRawPrompt(
    String input, {
    String? unitId,
    String? encounterId,
  }) async {
    final query = AiQuery.fromFreeText(
      input,
      unitId: unitId,
      encounterId: encounterId,
    );

    return run(query);
  }

  /// Run AI pipeline from a prepared query.
  Future<AiToolResponse> run(AiQuery query) async {
    final AiToolResponse response = await tools.run(query);

    // Apply optional formatting (UI polish only)
    if (formatter != null && response.handled) {
      return formatter!.format(response);
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Assistive AI drafting (optional)
  // ---------------------------------------------------------------------------

  Future<AiBackend?> _resolveBackend() async {
    if (backend != null) return backend;
    final p = backendProvider;
    if (p == null) return null;
    return await p();
  }

  /// Stream an assistive clinical note draft.
  ///
  /// This is NEVER used for analytics or decisions.
  /// If backend is unavailable, emits a single error message.
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  }) async* {
    final b = await _resolveBackend();

    if (b == null) {
      yield 'AI backend not configured. (Check local model + Groq key in settings)';
      return;
    }

    // Delegate to backend stream
    yield* b.draftNote(
      transcript: transcript,
      patientContext: patientContext,
    );
  }

  /// Intake extraction via backend (optional helper).
  /// Keep tools deterministic-first; use this only for "copilot" style extraction.
  /*Future<Map<String, dynamic>> extractIntake({
    required String freeText,
    List<String> missingFields = const [],
  }) async {
    final b = await _resolveBackend();
    if (b == null) {
      throw Exception('AI backend not configured.');
    }
    return b.extractIntake(
      freeText: freeText,
      missingFields: missingFields,
    );
  }*/
}

/// Optional response formatter interface.
///
/// Keeps [AiService] UI-agnostic.
abstract class AiResponseFormatter {
  AiToolResponse format(AiToolResponse response);
}