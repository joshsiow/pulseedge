// lib/core/ai/ai_service.dart

import 'ai_query.dart';
import 'ai_tool_response.dart';
import 'ai_tools.dart';
//import 'ai_backend.dart';
//import 'package:pulseedge/core/ai/ai_tool_response.dart';
import 'backends/ai_backend.dart';


/// AiService
///
/// Central AI orchestration layer for PulseEdge.
///
/// Responsibilities:
/// - Accept free-text input
/// - Run deterministic, offline-first tools
/// - Optionally delegate to cloud AI backend (Groq)
/// - Keep UI and storage layers decoupled
///
/// Design rules:
/// - Deterministic tools FIRST
/// - Cloud AI is assistive-only
/// - Offline-safe by default
class AiService {
  final AiTools tools;
  final AiBackend? backend;

  /// Optional formatter for UI / chat rendering.
  final AiResponseFormatter? formatter;

  /// Optional auth/session references (future use).
  final Object? auth;
  final Object? sessionStore;

  AiService({
    required this.tools,
    this.backend,
    this.formatter,
    this.auth,
    this.sessionStore,
  });

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
    final response = await tools.run(query); // ✅ await

    if (formatter != null && response.handled) {
      return formatter!.format(response);
    }

    return response;
  }

  /*Future<AiToolResponse> run(AiQuery query) async {
    final AiToolResponse response = await tools.run(query);

    // Apply optional formatting (UI polish only)
    if (formatter != null && response.handled) {
      return formatter!.format(response);
    }

    return response;
  }*/
  // ---------------------------------------------------------------------------
  // Assistive cloud drafting (optional)
  // ---------------------------------------------------------------------------

  /// Stream an assistive clinical note draft.
  ///
  /// This is NEVER used for analytics or decisions.
  /// If backend is unavailable, emits a single error message.
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  }) {
    final b = backend;

    if (b == null) {
      return Stream.value(
        'Cloud AI backend not configured.',
      );
    }

    return b.draftNote(
      transcript: transcript,
      patientContext: patientContext,
    );
  }
}

/// Optional response formatter interface.
///
/// Keeps [AiService] UI-agnostic.
abstract class AiResponseFormatter {
  AiToolResponse format(AiToolResponse response);
}