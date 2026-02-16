// lib/core/ai/analytics_engine.dart
import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import '../database/app_database.dart';

/// Simple (label,count) row for "top N" analytics.
class TopCountRow {
  final String label;
  final int count;

  const TopCountRow({
    required this.label,
    required this.count,
  });

  Map<String, Object?> toJson() => {'label': label, 'count': count};
}

/// Chart-ready 7-day trend output.
///
/// - days: ["2026-02-01", ...]
/// - totalCounts: [12, 9, ...]
/// - byTriage: { "P1": [1,0, ...], "P2": [...] }
class Trends7dResult {
  final List<String> days;
  final List<int> totalCounts;
  final Map<String, List<int>> byTriage;

  const Trends7dResult({
    required this.days,
    required this.totalCounts,
    required this.byTriage,
  });

  Map<String, Object?> toJson() => {
        'days': days,
        'totalCounts': totalCounts,
        'byTriage': byTriage,
      };

  @override
  String toString() => jsonEncode(toJson());
}

/// DB-backed analytics queries (offline-first).
///
/// IMPORTANT:
/// - Uses raw SQL via drift.customSelect for portability.
/// - SQL assumes drift default table/column naming:
///   encounters.patient_id, encounters.unit_id, encounters.triage_category, etc.
///
/// If your generated SQL names differ, adjust the SQL strings only
/// (the Dart API can remain stable).
class AnalyticsEngine {
  final AppDatabase db;

  AnalyticsEngine(this.db);

  // ---------------------------------------------------------------------------
  // Encounters
  // ---------------------------------------------------------------------------

  Future<int> countEncounters({
    required DateTime start,
    required DateTime end,
    String? unitId,
  }) async {
    final rows = await db.customSelect(
      '''
      SELECT COUNT(*) AS c
      FROM encounters
      WHERE start_at >= ?1 AND start_at < ?2
        AND (?3 IS NULL OR ?3 = '' OR unit_id = ?3)
      ''',
      variables: [
        drift.Variable.withDateTime(start),
        drift.Variable.withDateTime(end),
        drift.Variable.withString(unitId ?? ''),
      ],
      readsFrom: {db.encounters},
    ).getSingle();

    final v = rows.data['c'];
    return (v is int) ? v : int.tryParse('$v') ?? 0;
  }

  Future<List<TopCountRow>> topChiefComplaints({
    required DateTime start,
    required DateTime end,
    String? unitId,
    int limit = 5,
  }) async {
    final rows = await db.customSelect(
      '''
      SELECT
        COALESCE(NULLIF(TRIM(chief_complaint), ''), '(empty)') AS label,
        COUNT(*) AS c
      FROM encounters
      WHERE start_at >= ?1 AND start_at < ?2
        AND (?3 IS NULL OR ?3 = '' OR unit_id = ?3)
      GROUP BY COALESCE(NULLIF(TRIM(chief_complaint), ''), '(empty)')
      ORDER BY c DESC
      LIMIT ?4
      ''',
      variables: [
        drift.Variable.withDateTime(start),
        drift.Variable.withDateTime(end),
        drift.Variable.withString(unitId ?? ''),
        drift.Variable.withInt(limit),
      ],
      readsFrom: {db.encounters},
    ).get();

    return rows.map((r) {
      final d = r.data;
      final label = (d['label'] as String?) ?? '(empty)';
      final cRaw = d['c'];
      final c = (cRaw is int) ? cRaw : int.tryParse('$cRaw') ?? 0;
      return TopCountRow(label: label, count: c);
    }).toList();
  }

  Future<List<TopCountRow>> topTriageCategories({
    required DateTime start,
    required DateTime end,
    String? unitId,
    int limit = 5,
  }) async {
    final rows = await db.customSelect(
      '''
      SELECT
        COALESCE(NULLIF(TRIM(triage_category), ''), '(empty)') AS label,
        COUNT(*) AS c
      FROM encounters
      WHERE start_at >= ?1 AND start_at < ?2
        AND (?3 IS NULL OR ?3 = '' OR unit_id = ?3)
      GROUP BY COALESCE(NULLIF(TRIM(triage_category), ''), '(empty)')
      ORDER BY c DESC
      LIMIT ?4
      ''',
      variables: [
        drift.Variable.withDateTime(start),
        drift.Variable.withDateTime(end),
        drift.Variable.withString(unitId ?? ''),
        drift.Variable.withInt(limit),
      ],
      readsFrom: {db.encounters},
    ).get();

    return rows.map((r) {
      final d = r.data;
      final label = (d['label'] as String?) ?? '(empty)';
      final cRaw = d['c'];
      final c = (cRaw is int) ? cRaw : int.tryParse('$cRaw') ?? 0;
      return TopCountRow(label: label, count: c);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Trends (7d)
  // ---------------------------------------------------------------------------

  /// Returns 7-day trend series (inclusive of today), grouped by day + triage.
  ///
  /// The output is chart-ready:
  /// - `days` is the canonical x-axis ordering
  /// - `totalCounts[i]` aligns with `days[i]`
  /// - `byTriage[k][i]` aligns with `days[i]`
  Future<Trends7dResult> trends7dByTriage({required String unitId}) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final start = todayStart.subtract(const Duration(days: 6));
    final end = todayStart.add(const Duration(days: 1));

    // Build canonical day keys for the x-axis
    final days = List<String>.generate(7, (i) {
      final d = start.add(Duration(days: i));
      return _dayKey(d);
    });

    // Initialize series
    final totalCounts = List<int>.filled(7, 0);
    final byTriage = <String, List<int>>{};

    // SQLite day grouping: date(start_at) returns "YYYY-MM-DD"
    final rows = await db.customSelect(
      '''
      SELECT
        date(start_at) AS day,
        COALESCE(NULLIF(TRIM(triage_category), ''), '(empty)') AS triage,
        COUNT(*) AS c
      FROM encounters
      WHERE start_at >= ?1 AND start_at < ?2
        AND unit_id = ?3
      GROUP BY day, triage
      ORDER BY day ASC
      ''',
      variables: [
        drift.Variable.withDateTime(start),
        drift.Variable.withDateTime(end),
        drift.Variable.withString(unitId),
      ],
      readsFrom: {db.encounters},
    ).get();

    for (final r in rows) {
      final d = r.data;
      final day = (d['day'] as String?) ?? '';
      final triage = (d['triage'] as String?) ?? '(empty)';
      final cRaw = d['c'];
      final c = (cRaw is int) ? cRaw : int.tryParse('$cRaw') ?? 0;

      final idx = days.indexOf(day);
      if (idx < 0) continue;

      totalCounts[idx] += c;

      final series = byTriage.putIfAbsent(triage, () => List<int>.filled(7, 0));
      series[idx] += c;
    }

    return Trends7dResult(
      days: days,
      totalCounts: totalCounts,
      byTriage: byTriage,
    );
  }

  // ---------------------------------------------------------------------------
  // Session / Units
  // ---------------------------------------------------------------------------

  /// Returns units assigned to a user (for SessionContext selection).
  ///
  /// Assumes tables:
  /// - user_units(user_id, unit_id)
  /// - units(id, name, ...)
  Future<List<Unit>> unitsForUser(String userId) async {
    // Prefer typed drift query if you already have relations set up,
    // but raw SQL keeps it robust across schema changes.
    final rows = await db.customSelect(
      '''
      SELECT u.*
      FROM units u
      JOIN user_units uu ON uu.unit_id = u.id
      WHERE uu.user_id = ?1
      ORDER BY u.name ASC
      ''',
      variables: [drift.Variable.withString(userId)],
      readsFrom: {db.units, db.userUnits},
    ).get();

    // Convert QueryRow → Unit data class via generated mapping.
    // We re-select by IDs to keep it type-safe without relying on internal mappers.
    final ids = rows
        .map((r) => r.data['id'] as String?)
        .whereType<String>()
        .toList();

    if (ids.isEmpty) return [];

    return (db.select(db.units)..where((t) => t.id.isIn(ids))).get();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _dayKey(DateTime d) {
    // "YYYY-MM-DD"
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }
}