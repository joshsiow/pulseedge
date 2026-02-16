// lib/core/ai/ai_tools.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../auth/auth_service.dart';
import '../database/app_database.dart';

import 'analytics_engine.dart';
import 'ai_query.dart';
import 'intake_draft.dart';
//import 'intake_tools.dart';
import 'ai_intent.dart';
import 'ai_tool_response.dart';

class AiTools {
  //AiTools(this.engine, {Ref? ref}) : ref = ref;
  AiTools(this.engine, {this.ref});
  
  final AnalyticsEngine engine;
  final Ref? ref;

  Future<AiToolResponse> run(AiQuery query) async {
    switch (query.intent) {
      case AiIntent.encountersThisMorning:
        return _encountersThisMorning(query);
      case AiIntent.encountersToday:
        return _encountersToday(query);

      case AiIntent.topChiefComplaintsToday:
        return _topChiefComplaintsToday(query);

      case AiIntent.topTriageToday:
        return _topTriageToday(query);

      case AiIntent.trends7d:
        return _trends7d(query);

      case AiIntent.intakeCopilot:
        return _intakeAssist(query);

      case AiIntent.unknown:
        return AiToolResponse(
          handled: false,
          toolName: 'help',
          answer: _helpText(),
        );
    }
  }

  /* ------------------------------------------------------------------
   * ANALYTICS TOOLS
   * ------------------------------------------------------------------ */

  Future<AiToolResponse> _encountersThisMorning(AiQuery q) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0);
    final end = DateTime(now.year, now.month, now.day, 12, 0);

    final count = await engine.countEncounters(
      start: start,
      end: end,
      unitId: q.unitId,
    );

    final label = DateFormat('d MMM, HH:mm').format(end);
    return AiToolResponse(
      handled: true,
      toolName: 'encounters_this_morning',
      answer: 'Encounters this morning (until $label): **$count**',
      debug: {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'unitId': q.unitId,
      },
    );
  }

  Future<AiToolResponse> _encountersToday(AiQuery q) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0);
    final end = start.add(const Duration(days: 1));

    final count = await engine.countEncounters(
      start: start,
      end: end,
      unitId: q.unitId,
    );

    return AiToolResponse(
      handled: true,
      toolName: 'encounters_today',
      answer: 'Encounters today: **$count**',
    );
  }

  Future<AiToolResponse> _topChiefComplaintsToday(AiQuery q) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0);
    final end = start.add(const Duration(days: 1));

    final top = await engine.topChiefComplaints(
      start: start,
      end: end,
      unitId: q.unitId,
      limit: 5,
    );

    if (top.isEmpty) {
      return const AiToolResponse(
        handled: true,
        toolName: 'top_chief_complaints_today',
        answer: 'No chief-complaint data found for today yet.',
      );
    }

    final lines = top.map((x) => '• ${x.label} — **${x.count}**').join('\n');
    return AiToolResponse(
      handled: true,
      toolName: 'top_chief_complaints_today',
      answer: 'Top chief complaints today:\n$lines',
    );
  }

  Future<AiToolResponse> _topTriageToday(AiQuery q) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0);
    final end = start.add(const Duration(days: 1));

    final top = await engine.topTriageCategories(
      start: start,
      end: end,
      unitId: q.unitId,
      limit: 5,
    );

    if (top.isEmpty) {
      return const AiToolResponse(
        handled: true,
        toolName: 'top_triage_today',
        answer: 'No triage-category data found for today yet.',
      );
    }

    final lines = top.map((x) => '• ${x.label} — **${x.count}**').join('\n');
    return AiToolResponse(
      handled: true,
      toolName: 'top_triage_today',
      answer: 'Top triage categories today:\n$lines',
    );
  }

  Future<AiToolResponse> _trends7d(AiQuery q) async {
    final unitId = q.unitId;
    if (unitId == null || unitId.isEmpty) {
      return const AiToolResponse(
        handled: true,
        toolName: 'session_required',
        answer: 'Start a Session (select a medical unit) before running trends.',
      );
    }

    final res = await engine.trends7dByTriage(unitId: unitId);
    final total = res.totalCounts.fold<int>(0, (a, b) => a + b);

    if (total == 0) {
      return const AiToolResponse(
        handled: true,
        toolName: 'trends_7d',
        answer: 'No encounter data for the last 7 days.',
      );
    }

    final topNames = res.byTriage.entries
        .map((e) => MapEntry(e.key, e.value.fold<int>(0, (a, b) => a + b)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AiToolResponse(
      handled: true,
      toolName: 'trends_7d',
      answer:
          'Trends (7d): Top triage — ${topNames.take(3).map((e) => e.key).join(', ')}',
      debug: res.toJson(),
    );
  }

  /* ------------------------------------------------------------------
   * INTAKE TOOLS
   * ------------------------------------------------------------------ */

  Future<AiToolResponse> _intakeAssist(AiQuery q) async {
    return const AiToolResponse(
      handled: true,
      toolName: 'intake_assist',
      answer:
          'I can help with intake. You can tell me the chief complaint, '
          'allergies, medications, or medical history.',
    );
  }

  Future<AiToolResponse> saveIntakeDraft(SaveIntakeDraftRequest req) async {
    if (ref == null) {
      return const AiToolResponse(
        handled: false,
        toolName: 'save_intake_draft',
        answer: 'Internal error: AI tools not initialised with session context.',
        debug: {'error': 'missing_ref'},
      );
    }

    final currentUser = ref!.read(authServiceProvider).currentUser;
    if (currentUser == null) {
      return const AiToolResponse(
        handled: false,
        toolName: 'save_intake_draft',
        answer: 'Not signed in. Please log in again.',
        debug: {'error': 'no_current_user'},
      );
    }

    final db = AppDatabase.instance;
    final now = DateTime.now();
    final eventId = const Uuid().v4();

    await db.into(db.events).insert(
      EventsCompanion.insert(
        id: eventId,
        encounterId: req.encounterId,
        kind: 'DOC',
        title: 'Intake Draft',
        createdAt: now,
        status: const drift.Value('draft'),
        bodyText: drift.Value(req.draft.toNoteText()),
        payloadJson: drift.Value(jsonEncode(req.draft.toJson())),
        createdBy: drift.Value(currentUser.id),
        synced: const drift.Value(0),
        syncState: const drift.Value('pending'),
      ),
    );

    return AiToolResponse(
      handled: true,
      toolName: 'save_intake_draft',
      answer: 'Saved intake draft to timeline.',
      debug: {
        'eventId': eventId,
        'encounterId': req.encounterId,
      },
    );
  }

  String _helpText() {
    return 'I can answer offline analytics queries like:\n'
        '• How many encounters today?\n'
        '• Encounters this morning\n'
        '• Top triage today\n'
        '• Trends 7d';
  }
}