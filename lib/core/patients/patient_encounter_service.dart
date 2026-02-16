// lib/core/patients/patient_encounter_service.dart
//
// Offline-first patient search + one-click stub patient + start encounter.
// Works with your Drift schema in AppDatabase (patients, encounters, user_units, units).

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

final patientEncounterServiceProvider = Provider<PatientEncounterService>((ref) {
  return PatientEncounterService(AppDatabase.instance);
});

class PatientSearchHit {
  const PatientSearchHit({
    required this.patientId,
    required this.fullName,
    required this.nricMasked,
    required this.lastSeenAt,
    required this.isIncomplete,
  });

  final String patientId;
  final String fullName;
  final String nricMasked;
  final DateTime? lastSeenAt;
  final bool isIncomplete;
}

class CreatePatientStubInput {
  const CreatePatientStubInput({
    required this.fullName,
    this.nricOrOldId,
    this.address,
    this.allergies,
  });

  final String fullName;
  final String? nricOrOldId;
  final String? address;
  final String? allergies;
}

class CreateEncounterInput {
  const CreateEncounterInput({
    required this.patientId,
    required this.unitId,
    required this.unitName,
    required this.providerUserId,
    required this.providerName,
    this.type = 'OPD',
  });

  final String patientId;
  final String unitId;
  final String unitName;
  final String providerUserId;
  final String providerName;
  final String type;
}

class PatientEncounterService {
  PatientEncounterService(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // -----------------------------
  // SEARCH
  // -----------------------------

  /// Search patients by name and/or ID digits.
  /// - If input looks like an ID, we also try a hash match (nric_hash).
  /// - Returns lastSeenAt (max encounter start_at) and "incomplete" heuristic.
  Future<List<PatientSearchHit>> searchPatients({
    required String query,
    int limit = 10,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final nameNorm = _normalizeName(q);
    final idDigits = _normalizeIdDigits(q);
    final isLikelyId = idDigits.length >= 6;
    final idHash = isLikelyId ? _sha256Hex(idDigits) : '';

    // We do a single query using LEFT JOIN to get lastSeen.
    // Match rules:
    // - name LIKE
    // - OR nric_hash match (if looks like ID)
    // - OR nric digits contains (fallback)
    const sql = '''
    SELECT
      p.id AS patientId,
      p.full_name AS fullName,
      p.nric AS nric,
      p.address AS address,
      MAX(e.start_at) AS lastSeen
    FROM patients p
    LEFT JOIN encounters e ON e.patient_id = p.id
    WHERE
      (p.full_name_norm LIKE ?1)
      OR (?2 = 1 AND p.nric_hash = ?3)
      OR (?2 = 1 AND p.nric LIKE ?4)
    GROUP BY p.id, p.full_name, p.nric, p.address
    ORDER BY lastSeen DESC NULLS LAST, p.full_name ASC
    LIMIT ?5
    ''';

    final likeName = '%$nameNorm%';
    final likeId = '%$idDigits%';

    final rows = await _db.customSelect(
      sql,
      variables: [
        Variable.withString(likeName),
        Variable.withInt(isLikelyId ? 1 : 0),
        Variable.withString(idHash),
        Variable.withString(likeId),
        Variable.withInt(limit),
      ],
      readsFrom: {_db.patients, _db.encounters},
    ).get();

    return rows
        .map((r) {
          final data = r.data;
          final patientId = (data['patientId'] as String?) ?? '';
          final fullName = (data['fullName'] as String?) ?? '';
          final nric = (data['nric'] as String?) ?? '';
          final address = data['address'] as String?;
          final lastSeenRaw = data['lastSeen'];
          final lastSeen = lastSeenRaw is DateTime ? lastSeenRaw : null;

          final isIncomplete =
              (address == null || address.trim().isEmpty) || nric.trim().isEmpty;

          return PatientSearchHit(
            patientId: patientId,
            fullName: fullName,
            nricMasked: _maskId(nric),
            lastSeenAt: lastSeen,
            isIncomplete: isIncomplete,
          );
        })
        .where((x) => x.patientId.isNotEmpty)
        .toList();
  }

  /// Simple helper to list incomplete patients (missing address or missing nric).
  Future<List<PatientSearchHit>> listIncompletePatients({int limit = 20}) async {
    final rows = await _db.customSelect(
      '''
      SELECT
        p.id AS patientId,
        p.full_name AS fullName,
        p.nric AS nric,
        p.address AS address,
        MAX(e.start_at) AS lastSeen
      FROM patients p
      LEFT JOIN encounters e ON e.patient_id = p.id
      WHERE
        (p.address IS NULL OR TRIM(p.address) = '')
        OR (TRIM(p.nric) = '')
      GROUP BY p.id, p.full_name, p.nric, p.address
      ORDER BY lastSeen DESC NULLS LAST, p.full_name ASC
      LIMIT ?1
      ''',
      variables: [Variable.withInt(limit)],
      readsFrom: {_db.patients, _db.encounters},
    ).get();

    return rows
        .map((r) {
          final data = r.data;
          final patientId = (data['patientId'] as String?) ?? '';
          final fullName = (data['fullName'] as String?) ?? '';
          final nric = (data['nric'] as String?) ?? '';
          final address = data['address'] as String?;
          final lastSeenRaw = data['lastSeen'];
          final lastSeen = lastSeenRaw is DateTime ? lastSeenRaw : null;

          final isIncomplete =
              (address == null || address.trim().isEmpty) || nric.trim().isEmpty;

          return PatientSearchHit(
            patientId: patientId,
            fullName: fullName,
            nricMasked: _maskId(nric),
            lastSeenAt: lastSeen,
            isIncomplete: isIncomplete,
          );
        })
        .where((x) => x.patientId.isNotEmpty)
        .toList();
  }

  // -----------------------------
  // CREATE PATIENT STUB
  // -----------------------------

  Future<String> createPatientStub(CreatePatientStubInput input) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final fullName = input.fullName.trim();
    if (fullName.isEmpty) {
      throw ArgumentError('fullName is required');
    }

    // NRIC column is non-null in your schema, so we store '' for "no ID".
    final nricNorm = _normalizeIdDigits(input.nricOrOldId ?? '');
    final nameNorm = _normalizeName(fullName);
    final nricHash = _sha256Hex(nricNorm); // safe even if empty

    // Optional: prevent duplicates when NRIC is provided
    if (nricNorm.isNotEmpty) {
      final dup = await _db.customSelect(
        'SELECT id FROM patients WHERE nric_hash = ?1 LIMIT 1',
        variables: [Variable.withString(nricHash)],
        readsFrom: {_db.patients},
      ).get();

      if (dup.isNotEmpty) {
        return dup.first.read<String>('id');
      }
    }

    await _db.into(_db.patients).insert(
          PatientsCompanion.insert(
            id: id,
            mrn: const Value.absent(),
            fullName: fullName,
            fullNameNorm: nameNorm,
            nric: nricNorm, // '' allowed
            nricHash: nricHash,
            address: Value(input.address?.trim()),
            allergies: Value(input.allergies?.trim()),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return id;
  }

  // -----------------------------
  // CREATE ENCOUNTER (encounter-first)
  // -----------------------------

  Future<String> createEncounter(CreateEncounterInput input) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _db.into(_db.encounters).insert(
          EncountersCompanion.insert(
            id: id,
            patientId: input.patientId,
            encounterNo: const Value.absent(),
            status: const Value('open'),
            type: Value(input.type),
            unitId: Value(input.unitId),
            unitName: Value(input.unitName),
            providerUserId: Value(input.providerUserId),
            providerName: Value(input.providerName),
            chiefComplaint: const Value.absent(),
            triageCategory: const Value.absent(),
            startAt: now,
            endAt: const Value.absent(),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return id;
  }

  // -----------------------------
  // ONE-CLICK: Create stub + start encounter (fast intake)
  // -----------------------------

  Future<String> createStubAndStartEncounter({
    required CreatePatientStubInput patient,
    required String unitId,
    required String unitName,
    required String providerUserId,
    required String providerName,
    String type = 'OPD',
  }) async {
    return _db.transaction(() async {
      final patientId = await createPatientStub(patient);
      final encounterId = await createEncounter(
        CreateEncounterInput(
          patientId: patientId,
          unitId: unitId,
          unitName: unitName,
          providerUserId: providerUserId,
          providerName: providerName,
          type: type,
        ),
      );
      return encounterId;
    });
  }

  // -----------------------------
  // Duplicate risk check (soft match)
  // -----------------------------

  Future<List<PatientSearchHit>> findPossibleDuplicates({
    required String fullName,
    String? nricOrOldId,
    int limit = 5,
  }) async {
    final nameNorm = _normalizeName(fullName);
    final idDigits = _normalizeIdDigits(nricOrOldId ?? '');

    // Simple strategy:
    // - If ID digits exist: prefer hash match and also name match.
    // - Else: just name match.
    final sql = '''
    SELECT
      p.id AS patientId,
      p.full_name AS fullName,
      p.nric AS nric,
      p.address AS address,
      MAX(e.start_at) AS lastSeen
    FROM patients p
    LEFT JOIN encounters e ON e.patient_id = p.id
    WHERE
      p.full_name_norm LIKE ?1
      ${idDigits.isEmpty ? '' : 'OR p.nric_hash = ?2'}
    GROUP BY p.id, p.full_name, p.nric, p.address
    ORDER BY lastSeen DESC NULLS LAST
    LIMIT ?${idDigits.isEmpty ? 2 : 3}
    ''';

    final variables = <Variable<Object>>[
      Variable.withString('%$nameNorm%'),
      if (idDigits.isNotEmpty) Variable.withString(_sha256Hex(idDigits)),
      Variable.withInt(limit),
    ];

    final rows = await _db.customSelect(
      sql,
      variables: variables,
      readsFrom: {_db.patients, _db.encounters},
    ).get();

    return rows
        .map((r) {
          final data = r.data;
          final patientId = (data['patientId'] as String?) ?? '';
          final fullName = (data['fullName'] as String?) ?? '';
          final nric = (data['nric'] as String?) ?? '';
          final address = data['address'] as String?;
          final lastSeenRaw = data['lastSeen'];
          final lastSeen = lastSeenRaw is DateTime ? lastSeenRaw : null;

          final isIncomplete =
              (address == null || address.trim().isEmpty) || nric.trim().isEmpty;

          return PatientSearchHit(
            patientId: patientId,
            fullName: fullName,
            nricMasked: _maskId(nric),
            lastSeenAt: lastSeen,
            isIncomplete: isIncomplete,
          );
        })
        .where((x) => x.patientId.isNotEmpty)
        .toList();
  }

  // -----------------------------
  // Helpers
  // -----------------------------

  String _normalizeName(String s) {
    final x = s.trim().toLowerCase();
    // collapse multiple spaces
    return x.replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeIdDigits(String s) {
    // keep digits only
    return s.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _sha256Hex(String s) {
    final bytes = utf8.encode(s);
    return sha256.convert(bytes).toString(); // hex
  }

  String _maskId(String raw) {
    final id = raw.trim();
    if (id.isEmpty) return '';
    if (id.length <= 4) return '****';
    final tail = id.substring(id.length - 4);
    return '****$tail';
  }
}