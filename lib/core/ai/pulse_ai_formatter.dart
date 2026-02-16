// lib/core/ai/pulse_ai_formatter.dart
//
// Small formatting helpers for turning AiToolResponse (and tool debug payloads)
// into clean, clinician-friendly chat text.
//
// Keep this file PURE (no Flutter imports) so it can be used from services,
// background jobs, and tests.

import 'dart:convert';

import 'ai_service.dart'; // For AiResponseFormatter interface
import 'ai_tool_response.dart';

class PulseAiFormatter implements AiResponseFormatter {
  /// Main entry: format a tool response for chat UI.
  ///
  /// - If tool already returns markdown-ish bullets, we keep it.
  /// - If debug payload contains a structured series (e.g., trends7d),
  ///   we can optionally append a compact summary.
  @override
  AiToolResponse format(
    AiToolResponse r, {
    bool includeDebugSummary = false,
  }) {
    String base = (r.answer).trim().isEmpty ? _fallbackText(r) : r.answer.trim();

    if (includeDebugSummary) {
      final dbg = r.debug;
      if (dbg != null && dbg.isNotEmpty) {
        final summary = _debugSummary(dbg);
        if (summary != null && summary.trim().isNotEmpty) {
          base = '$base\n\n$summary'.trim();
        }
      }
    }

    // Return new response with formatted answer (preserve handled/toolName/debug)
    return r.copyWith(answer: base);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  String _fallbackText(AiToolResponse r) {
    if (!r.handled) return 'I\'m not sure how to help with that. Try asking about encounters, triage, or trends.';
    return 'Done. (${r.toolName})';
  }

  /// Turn common debug payload shapes into a short, readable summary.
  String? _debugSummary(Map<String, Object?> dbg) {
    // Trends payload
    final series = dbg['series'];
    if (series is Map) {
      final s = series.cast<String, Object?>();
      final days = _asStringList(s['days']);
      final totals = _asIntList(s['totalCounts']);
      final byTriage = s['byTriage'];

      if (days != null && totals != null && days.length == totals.length) {
        final totalSum = totals.fold<int>(0, (a, b) => a + b);
        final start = days.isNotEmpty ? days.first : '—';
        final end = days.isNotEmpty ? days.last : '—';

        final triageTop = (byTriage is Map)
            ? _topKeysBySeriesSum(byTriage.cast<String, Object?>(), take: 3)
            : const <String>[];

        final sb = StringBuffer()
          ..writeln('—')
          ..writeln('**Debug summary**')
          ..writeln('Range: $start → $end')
          ..writeln('Total (7d): $totalSum')
          ..writeln(
            'Top triage: ${triageTop.isEmpty ? '—' : triageTop.join(', ')}',
          );

        return sb.toString().trim();
      }
    }

    // Generic start/end/unitId
    final start = dbg['start']?.toString();
    final end = dbg['end']?.toString();
    final unitId = dbg['unitId']?.toString();

    if (start != null || end != null || unitId != null) {
      final parts = <String>[];
      if (unitId != null && unitId.trim().isNotEmpty) parts.add('unitId=$unitId');
      if (start != null && start.trim().isNotEmpty) parts.add('start=$start');
      if (end != null && end.trim().isNotEmpty) parts.add('end=$end');

      if (parts.isEmpty) return null;

      return '—\n**Debug**\n${parts.join('\n')}';
    }

    return null;
  }

  List<String>? _asStringList(Object? x) {
    if (x is List) {
      return x.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return null;
  }

  List<int>? _asIntList(Object? x) {
    if (x is List) {
      return x.map((e) {
        if (e is int) return e;
        return int.tryParse(e.toString()) ?? 0;
      }).toList();
    }
    return null;
  }

  List<String> _topKeysBySeriesSum(
    Map<String, Object?> byTriage, {
    int take = 3,
  }) {
    final totals = <String, int>{};

    byTriage.forEach((k, v) {
      final series = _asIntList(v);
      if (series == null) return;
      totals[k] = series.fold<int>(0, (a, b) => a + b);
    });

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(take).map((e) => e.key).toList();
  }

  /// Optional helper: pretty-print debug JSON safely for logs/UI.
  String prettyJson(Object? obj) {
    try {
      return const JsonEncoder.withIndent('  ').convert(obj);
    } catch (_) {
      return obj?.toString() ?? '';
    }
  }
}