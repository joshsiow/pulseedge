// lib/core/ai/time_range.dart

/// TimeRange
///
/// Represents a concrete, inclusive time window used for analytics queries
/// (encounters, triage counts, trends, etc.).
///
/// This is deliberately simple and deterministic:
/// - All times are local
/// - Start is inclusive
/// - End is exclusive
class TimeRange {
  final DateTime start;
  final DateTime end;

  const TimeRange({
    required this.start,
    required this.end,
  });

  /* ---------------- Factory helpers ---------------- */

  /// Today (from 00:00 to now).
  factory TimeRange.today() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return TimeRange(start: startOfDay, end: now);
  }

  /// This morning (06:00 to 12:00 today).
  factory TimeRange.thisMorning() {
    final now = DateTime.now();
    final morningStart =
        DateTime(now.year, now.month, now.day, 6);
    final noon =
        DateTime(now.year, now.month, now.day, 12);

    return TimeRange(
      start: morningStart,
      end: now.isBefore(noon) ? now : noon,
    );
  }

  /// Yesterday (00:00 to 23:59:59).
  factory TimeRange.yesterday() {
    final now = DateTime.now();
    final yesterday =
        DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));

    final start =
        DateTime(yesterday.year, yesterday.month, yesterday.day);
    final end = start.add(const Duration(days: 1));

    return TimeRange(start: start, end: end);
  }

  /// Last N full days (rolling window ending now).
  factory TimeRange.lastDays(int days) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    return TimeRange(start: start, end: now);
  }

  /// Last 7 days (rolling).
  factory TimeRange.last7Days() {
    return TimeRange.lastDays(7);
  }

  /// Last 30 days (rolling).
  factory TimeRange.last30Days() {
    return TimeRange.lastDays(30);
  }

  /* ---------------- Utilities ---------------- */

  Duration get duration => end.difference(start);

  bool contains(DateTime t) =>
      !t.isBefore(start) && t.isBefore(end);

  @override
  String toString() =>
      'TimeRange(start: $start, end: $end)';

  Map<String, Object?> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }
}