// lib/core/ai/ai_tool_response.dart

/// Standard response contract returned by deterministic AI tools (AiTools).
///
/// This object serves TWO audiences:
///
/// 1. UI / Chat layer
///    - `handled`: whether a tool handled the query (vs fallback)
///    - `toolName`: stable identifier for telemetry/debugging
///    - `answer`: human-readable response text
///    - `debug`: optional structured payload for UI rendering
///
/// 2. Tool execution semantics
///    - success/error are inferred from `handled` + `error`
///
/// Design goals:
/// - Deterministic
/// - JSON-safe
/// - Offline-first
/// - Telemetry-friendly
class AiToolResponse {
  const AiToolResponse({
    required this.handled,
    required this.toolName,
    required this.answer,
    this.debug,
    this.error,
  });

  /// Whether a deterministic tool handled the request.
  /// If false, caller may fallback to LLM / cloud / help text.
  final bool handled;

  /// Stable tool identifier (e.g. `encountersToday`, `intakeCopilot`).
  final String toolName;

  /// Human-readable text returned to UI / chat.
  final String answer;

  /// Optional structured payload for UI rendering, charts, ids, etc.
  final Map<String, Object?>? debug;

  /// Optional error message when tool execution failed.
  /// If non-null, `handled` SHOULD be false.
  final String? error;

  /* ---------------- Factory helpers ---------------- */

  /// Successful tool execution.
  factory AiToolResponse.ok({
    required String toolName,
    required String answer,
    Map<String, Object?>? debug,
  }) {
    return AiToolResponse(
      handled: true,
      toolName: toolName,
      answer: answer,
      debug: debug,
      error: null,
    );
  }

  /// Tool recognized the intent but failed during execution.
  factory AiToolResponse.fail({
    required String toolName,
    required String message,
    Map<String, Object?>? debug,
  }) {
    return AiToolResponse(
      handled: false,
      toolName: toolName,
      answer: message,
      debug: debug,
      error: message,
    );
  }

  /// Tool did not handle the request at all (unknown intent).
  factory AiToolResponse.unhandled({
    String toolName = 'unknown',
    String answer = '',
  }) {
    return AiToolResponse(
      handled: false,
      toolName: toolName,
      answer: answer,
      debug: null,
      error: null,
    );
  }

  /* ---------------- Serialization ---------------- */

  Map<String, Object?> toJson() => {
        'handled': handled,
        'toolName': toolName,
        'answer': answer,
        if (debug != null) 'debug': debug,
        if (error != null) 'error': error,
      };

  factory AiToolResponse.fromJson(Map<String, dynamic> json) {
    return AiToolResponse(
      handled: json['handled'] as bool? ?? false,
      toolName: json['toolName'] as String? ?? 'unknown',
      answer: json['answer'] as String? ?? '',
      debug: (json['debug'] is Map)
          ? (json['debug'] as Map).cast<String, Object?>()
          : null,
      error: json['error'] as String?,
    );
  }

  /* ---------------- Utilities ---------------- */

  bool get isSuccess => handled && error == null;

  AiToolResponse copyWith({
    bool? handled,
    String? toolName,
    String? answer,
    Map<String, Object?>? debug,
    String? error,
  }) {
    return AiToolResponse(
      handled: handled ?? this.handled,
      toolName: toolName ?? this.toolName,
      answer: answer ?? this.answer,
      debug: debug ?? this.debug,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'AiToolResponse(handled: $handled, toolName: $toolName, answer: $answer, error: $error)';
  }
}