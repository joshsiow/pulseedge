// lib/core/ai/intake_tools.dart
import 'dart:convert';

import 'ai_tool_response.dart';
import 'time_range.dart';

/// IntakeTools
///
/// Deterministic extraction helpers for Intake Copilot.
/// These tools MUST return structured, non-hallucinatory output.
/// If data is missing, fields must be null or empty.
class IntakeTools {
  /// Extract structured intake information from free text.
  ///
  /// Expected use:
  /// - chief complaint intake
  /// - triage note parsing
  /// - walk-in registration assistance
  static AiToolResponse extractIntake(String rawText) {
    if (rawText.trim().isEmpty) {
        return AiToolResponse.fail(
        toolName: 'intakeCopilot',
        message: 'Empty intake text',
      );
    }

    final Map<String, dynamic> result = {
      'chiefComplaint': null,
      'onset': null,
      'duration': null,
      'severity': null,
      'associatedSymptoms': <String>[],
      'redFlags': <String>[],
      'notes': null,
    };

    // VERY conservative heuristics.
    // This keeps behavior deterministic and safe offline.
    final lower = rawText.toLowerCase();

    if (lower.contains('pain')) {
      result['chiefComplaint'] = 'Pain';
    }

    if (lower.contains('fever')) {
      (result['associatedSymptoms'] as List).add('Fever');
    }

    if (lower.contains('bleeding') || lower.contains('collapse')) {
      (result['redFlags'] as List).add('Potential emergency symptom');
    }

    result['notes'] = rawText.trim();

    return AiToolResponse.ok(
      toolName: 'intakeCopilot',
      answer: 'Intake information extracted.',
      debug: result,
    );
  }

  /// Normalize a time-related phrase into a TimeRange.
  ///
  /// Example:
  /// - "this morning"
  /// - "today"
  /// - "last 7 days"
  static TimeRange? parseTimeRange(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('this morning')) {
      return TimeRange.thisMorning();
    }

    if (lower.contains('today')) {
      return TimeRange.today();
    }

    if (lower.contains('7 days') || lower.contains('week')) {
      return TimeRange.lastDays(7);
    }

    return null;
  }

  /// Helper for strict JSON parsing from LLM output.
  ///
  /// This should be used when you later wire GGUF inference.
  static Map<String, dynamic>? safeParseJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}