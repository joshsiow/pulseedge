// lib/core/encounters/encounter_repo.dart
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../auth/auth_service.dart';

class EncounterRepo {
  final AppDatabase db;
  final Ref ref;

  EncounterRepo(this.db, this.ref);

  Future<List<Encounter>> listForPatient(String patientId) async {
    return (db.select(db.encounters)
          ..where((e) => e.patientId.equals(patientId))
          ..orderBy([(e) => OrderingTerm.desc(e.startAt)]))
        .get();
  }

  Future<Encounter> createEncounter({
    required String patientId,
    required String type,
    required String unitName,
    String? unitId,
    String? chiefComplaint,
    String? triageCategory,
  }) async {
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final id = const UuidV4().generate();
    final now = DateTime.now();

    await db.into(db.encounters).insert(EncountersCompanion.insert(
      id: id,
      patientId: patientId,
      type: Value(type),  // Has default in schema → Value required
      status: const Value('open'),  // Default → Value
      unitId: unitId == null ? const Value.absent() : Value(unitId),
      unitName: Value(unitName),  // Default → Value
      providerUserId: Value(currentUser.id),
      providerName: Value(currentUser.displayName ?? currentUser.username),
      chiefComplaint: chiefComplaint == null || chiefComplaint.trim().isEmpty
          ? const Value.absent()
          : Value(chiefComplaint.trim()),
      triageCategory: triageCategory == null || triageCategory.trim().isEmpty
          ? const Value.absent()
          : Value(triageCategory.trim()),
      startAt: now,
      createdAt: now,
      updatedAt: now,
      synced: const Value(0),  // Default → Value
      syncState: const Value('pending'),  // Default → Value
    ));

    return (db.select(db.encounters)..where((e) => e.id.equals(id))).getSingle();
  }

  Future<void> closeEncounter(String encounterId) async {
    final now = DateTime.now();

    await (db.update(db.encounters)..where((e) => e.id.equals(encounterId))).write(
      EncountersCompanion(
        status: const Value('closed'),
        endAt: Value(now),
        updatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  Future<List<Event>> listEvents(String encounterId, {required String kind}) async {
    return (db.select(db.events)
          ..where((ev) => ev.encounterId.equals(encounterId) & ev.kind.equals(kind))
          ..orderBy([(ev) => OrderingTerm.desc(ev.createdAt)]))
        .get();
  }

  Future<Event> createNoteEvent({
    required String encounterId,
    required String title,
    required String body,
    String status = 'draft',
    String kind = 'NOTE',
  }) async {
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final id = const UuidV4().generate();
    final now = DateTime.now();

    await db.into(db.events).insert(EventsCompanion.insert(
      id: id,
      encounterId: encounterId,
      kind: kind,
      title: title,
      status: Value(status),
      bodyText: Value(body),
      payloadJson: Value(jsonEncode({'format': 'text'})),
      createdBy: Value(currentUser.id),
      createdAt: now,
      synced: const Value(0),
      syncState: const Value('pending'),
    ));

    return (db.select(db.events)..where((e) => e.id.equals(id))).getSingle();
  }

  Future<void> signNote({
    required String eventId,
    required String finalBody,
  }) async {
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final now = DateTime.now();

    await (db.update(db.events)..where((e) => e.id.equals(eventId))).write(
      EventsCompanion(
        status: const Value('signed'),
        bodyText: Value(finalBody),
        signedBy: Value(currentUser.id),
        signedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }
}