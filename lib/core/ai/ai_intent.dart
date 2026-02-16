// lib/core/ai/ai_intent.dart

import 'time_range.dart';

/// ---------------------------------------------------------------------------
/// Intent classification layer
/// ---------------------------------------------------------------------------
///
/// AiIntent (ENUM)
///
/// Represents the high-level intent classified from user input.
/// Used for:
/// - routing
/// - telemetry
/// - analytics gating
/// - GGUF / prompt classification
///
/// This answers: "What does the user want?"
enum AiIntent {
  encountersThisMorning,
  encountersToday,
  topChiefComplaintsToday,
  topTriageToday,
  trends7d,
  intakeCopilot,
  unknown,
}

extension AiIntentX on AiIntent {
  /// Stable identifier (safe for telemetry & persistence).
  String get name {
    switch (this) {
      case AiIntent.encountersThisMorning:
        return 'encountersThisMorning';
      case AiIntent.encountersToday:
        return 'encountersToday';
      case AiIntent.topChiefComplaintsToday:
        return 'topChiefComplaintsToday';
      case AiIntent.topTriageToday:
        return 'topTriageToday';
      case AiIntent.trends7d:
        return 'trends7d';
      case AiIntent.intakeCopilot:
        return 'intakeCopilot';
      case AiIntent.unknown:
        return 'unknown';
    }
  }

  static AiIntent fromName(String? value) {
    switch (value) {
      case 'encountersThisMorning':
        return AiIntent.encountersThisMorning;
      case 'encountersToday':
        return AiIntent.encountersToday;
      case 'topChiefComplaintsToday':
        return AiIntent.topChiefComplaintsToday;
      case 'topTriageToday':
        return AiIntent.topTriageToday;
      case 'trends7d':
        return AiIntent.trends7d;
      case 'intakeCopilot':
        return AiIntent.intakeCopilot;
      default:
        return AiIntent.unknown;
    }
  }

  bool get requiresAnalytics {
    switch (this) {
      case AiIntent.encountersThisMorning:
      case AiIntent.encountersToday:
      case AiIntent.topChiefComplaintsToday:
      case AiIntent.topTriageToday:
      case AiIntent.trends7d:
        return true;
      case AiIntent.intakeCopilot:
      case AiIntent.unknown:
        return false;
    }
  }
}

/// ---------------------------------------------------------------------------
/// Intent execution layer
/// ---------------------------------------------------------------------------
///
/// These enums + class define the *executable* form of an intent.
/// Used AFTER classification to perform deterministic computation.
///
/// This answers: "Exactly how do we compute it?"

/// Deterministic metrics we support offline.
enum AiMetric {
  count,
  top,
  trend,
  intake,
}

/// Domain entities.
enum AiEntity {
  encounters,
  patients,
  diagnoses,
  triage,
  chiefComplaints,
}

/// Fully-resolved, executable intent.
///
/// This object is passed to analytics engines and tools.
/// It is deterministic, explicit, and offline-safe.
class AiResolvedIntent {
  final AiMetric metric;
  final AiEntity entity;

  final TimeRange? timeRange;
  final int? windowDays;
  final int? limit;

  /// Analytics scoping
  final String? unitId;

  /// Encounter scoping (required for encounter-intake tools)
  final String? encounterId;

  const AiResolvedIntent({
    required this.metric,
    required this.entity,
    this.timeRange,
    this.windowDays,
    this.limit,
    this.unitId,
    this.encounterId,
  });

  // ---------------------------------------------------------------------------
  // Convenience builders
  // ---------------------------------------------------------------------------

  /// Count encounters in an explicit range (today / this morning / custom).
  const AiResolvedIntent.countEncounters({
    required TimeRange range,
    String? unitId,
  }) : this(
          metric: AiMetric.count,
          entity: AiEntity.encounters,
          timeRange: range,
          unitId: unitId,
        );

  /// Top N chief complaints in an explicit range.
  const AiResolvedIntent.topChiefComplaints({
    required TimeRange range,
    int limit = 5,
    String? unitId,
  }) : this(
          metric: AiMetric.top,
          entity: AiEntity.chiefComplaints,
          timeRange: range,
          limit: limit,
          unitId: unitId,
        );

  /// Top N triage categories in an explicit range.
  const AiResolvedIntent.topTriage({
    required TimeRange range,
    int limit = 5,
    String? unitId,
  }) : this(
          metric: AiMetric.top,
          entity: AiEntity.triage,
          timeRange: range,
          limit: limit,
          unitId: unitId,
        );

  /// Trends over the last 7 days for encounters.
  const AiResolvedIntent.trends7dEncounters({
    required String unitId,
  }) : this(
          metric: AiMetric.trend,
          entity: AiEntity.encounters,
          windowDays: 7,
          unitId: unitId,
        );

  /// Trends over the last N days for encounters.
  const AiResolvedIntent.trendEncountersLastNDays({
    required int days,
    required String unitId,
  }) : this(
          metric: AiMetric.trend,
          entity: AiEntity.encounters,
          windowDays: days,
          unitId: unitId,
        );

  /// Encounter intake / registration assistance.
  const AiResolvedIntent.encounterIntake({
    required String encounterId,
  }) : this(
          metric: AiMetric.intake,
          entity: AiEntity.patients,
          encounterId: encounterId,
        );
}