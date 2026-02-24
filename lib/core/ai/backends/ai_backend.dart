// lib/core/ai/backends/ai_backend.dart

abstract class AiBackend {
  /// One-shot text generation (used for testing + non-stream UI).
  Future<String> generate(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
  });

  /// Stream a draft note (preferred for long outputs).
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  });

  /// Intake extraction (returns JSON map).
  Future<Map<String, dynamic>> extractIntakeJson({
    required String rawText,
  });
}