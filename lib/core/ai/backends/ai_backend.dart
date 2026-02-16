// lib/core/ai/ai_backend.dart
abstract class AiBackend {
  /// Assistive drafting (cloud or local)
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  });

  /// Intake extraction (returns JSON map)
  Future<Map<String, dynamic>> extractIntakeJson({
    required String rawText,
  });
}