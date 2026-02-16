// lib/core/ai/ai_query.dart

import 'ai_intent.dart';
import 'time_range.dart';

/// AiQuery
///
/// Deterministic bridge between:
///   Free text → Classified intent → Resolved executable intent → AiTools
///
/// This parser is intentionally:
/// - rule-based
/// - offline-first
/// - auditable
class AiQuery {
  /// High-level classified intent (routing / telemetry).
  final AiIntent intent;

  /// Fully resolved, executable intent (analytics / tools).
  final AiResolvedIntent? resolved;

  /// Raw original user input.
  final String rawText;

  /// Optional unit scoping (from SessionContext).
  final String? unitId;

  /// Optional encounter scoping (for intake).
  final String? encounterId;

  const AiQuery({
    required this.intent,
    required this.rawText,
    this.resolved,
    this.unitId,
    this.encounterId,
  });

  // ---------------------------------------------------------------------------
  // Factory: parse free text into structured intent
  // ---------------------------------------------------------------------------

  factory AiQuery.fromFreeText(
    String input, {
    String? unitId,
    String? encounterId,
  }) {
    final text = input.trim().toLowerCase();

    // -----------------------------------------------------------------------
    // 1️⃣ Intake / Registration assist (encounter-scoped)
    // -----------------------------------------------------------------------
    if (encounterId != null &&
        (text.contains('intake') ||
            text.contains('register') ||
            text.contains('registration') ||
            text.contains('daftar') ||
            text.contains('alamat') ||
            text.contains('nric'))) {
      return AiQuery(
        rawText: input,
        unitId: unitId,
        encounterId: encounterId,
        intent: AiIntent.intakeCopilot,
        resolved: AiResolvedIntent.encounterIntake(
          encounterId: encounterId,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // 2️⃣ Encounters this morning
    // -----------------------------------------------------------------------
    if (text.contains('this morning') ||
        text.contains('pagi ini') ||
        text.contains('morning encounter')) {
      final range = TimeRange.thisMorning();
      return AiQuery(
        rawText: input,
        unitId: unitId,
        intent: AiIntent.encountersThisMorning,
        resolved: AiResolvedIntent.countEncounters(
          range: range,
          unitId: unitId,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // 3️⃣ Encounters today
    // -----------------------------------------------------------------------
    if (text.contains('encounters today') ||
        text.contains('how many encounters today') ||
        text.contains('today encounter') ||
        text.contains('hari ini')) {
      final range = TimeRange.today();
      return AiQuery(
        rawText: input,
        unitId: unitId,
        intent: AiIntent.encountersToday,
        resolved: AiResolvedIntent.countEncounters(
          range: range,
          unitId: unitId,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // 4️⃣ Top chief complaints today
    // -----------------------------------------------------------------------
    if (text.contains('top diagnosis') ||
        text.contains('top complaint') ||
        text.contains('chief complaint')) {
      final range = TimeRange.today();
      return AiQuery(
        rawText: input,
        unitId: unitId,
        intent: AiIntent.topChiefComplaintsToday,
        resolved: AiResolvedIntent.topChiefComplaints(
          range: range,
          unitId: unitId,
          limit: 5,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // 5️⃣ Top triage today
    // -----------------------------------------------------------------------
    if (text.contains('top triage') ||
        text.contains('triage today') ||
        text.contains('kategori triage')) {
      final range = TimeRange.today();
      return AiQuery(
        rawText: input,
        unitId: unitId,
        intent: AiIntent.topTriageToday,
        resolved: AiResolvedIntent.topTriage(
          range: range,
          unitId: unitId,
          limit: 5,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // 6️⃣ Trends (last 7 days)
    // -----------------------------------------------------------------------
    if ((text.contains('trend') ||
            text.contains('trends') ||
            text.contains('7d') ||
            text.contains('7 days') ||
            text.contains('minggu')) &&
        unitId != null) {
      return AiQuery(
        rawText: input,
        unitId: unitId,
        intent: AiIntent.trends7d,
        resolved: AiResolvedIntent.trends7dEncounters(
          unitId: unitId,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // 7️⃣ Fallback → Unknown
    // -----------------------------------------------------------------------
    return AiQuery(
      rawText: input,
      unitId: unitId,
      intent: AiIntent.unknown,
      resolved: null,
    );
  }

  /// Immutable update helper.
  AiQuery copyWith({
    AiIntent? intent,
    AiResolvedIntent? resolved,
    String? rawText,
    String? unitId,
    String? encounterId,
  }) {
    return AiQuery(
      intent: intent ?? this.intent,
      resolved: resolved ?? this.resolved,
      rawText: rawText ?? this.rawText,
      unitId: unitId ?? this.unitId,
      encounterId: encounterId ?? this.encounterId,
    );
  }

  @override
  String toString() {
    return 'AiQuery(intent: ${intent.name}, rawText: "$rawText")';
  }
}