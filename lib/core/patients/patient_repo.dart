import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class PatientRepo {
  PatientRepo(this.db);
  final AppDatabase db;

  static String normalizeName(String s) {
    return s.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
  }

  static String normalizeNric(String s) {
    return s.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase();
  }

  static bool looksLikeMrn(String s) {
    // Simple heuristic: mostly digits or alphanum, length 5-16
    final t = s.trim();
    if (t.length < 5 || t.length > 16) return false;
    return RegExp(r'^[0-9A-Za-z\-]+$').hasMatch(t);
  }

  static bool looksLikeNric(String s) {
    // MY NRIC often 12 digits; allow 10-14 alphanum after normalization
    final n = normalizeNric(s);
    return (n.length >= 10 && n.length <= 14) && RegExp(r'^[0-9A-Za-z]+$').hasMatch(n);
  }

  Future<String> sha256Hex(String input) async {
    final h = await Sha256().hash(utf8.encode(input));
    return h.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<List<Patient>> searchPatients(String query, {int limit = 50}) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final nricNorm = normalizeNric(q);
    final nameNorm = normalizeName(q);

    // Pull candidates by:
    // - NRIC hash exact
    // - MRN exact
    // - Name LIKE
    final candidates = <Patient>{};

    if (looksLikeNric(q)) {
      final hash = await sha256Hex(nricNorm);
      final byHash = await (db.select(db.patients)
            ..where((p) => p.nricHash.equals(hash))
            ..limit(limit))
          .get();
      candidates.addAll(byHash);
    }

    if (looksLikeMrn(q)) {
      final byMrn = await (db.select(db.patients)
            ..where((p) => p.mrn.equals(q))
            ..limit(limit))
          .get();
      candidates.addAll(byMrn);
    }

    final byName = await (db.select(db.patients)
          ..where((p) => p.fullNameNorm.like('%$nameNorm%'))
          ..limit(limit))
        .get();
    candidates.addAll(byName);

    // Sort: exact NRIC hash matches first, then MRN exact, then name contains
    final hash = looksLikeNric(q) ? await sha256Hex(nricNorm) : null;

    final list = candidates.toList();
    list.sort((a, b) {
      int score(Patient p) {
        var s = 0;
        if (hash != null && p.nricHash == hash) s += 1000;
        if (p.mrn != null && p.mrn == q) s += 500;
        if (p.fullNameNorm.contains(nameNorm)) s += 100;
        return -s; // descending
      }

      return score(a).compareTo(score(b));
    });

    return list;
  }

  Future<Patient> createPatient({
    String? mrn,
    required String fullName,
    required String nricRaw,
    String? address,
    String? allergies,
    String consentStatus = 'unknown',
    String source = 'local',
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    final nameNorm = normalizeName(fullName);
    final nricNorm = normalizeNric(nricRaw);
    final hash = await sha256Hex(nricNorm);

    await db.into(db.patients).insert(PatientsCompanion.insert(
          id: id,
          mrn: mrn == null ? const Value.absent() : Value(mrn),
          fullName: fullName.trim(),
          fullNameNorm: nameNorm,
          nric: nricNorm,
          nricHash: hash,
          address: address == null ? const Value.absent() : Value(address.trim()),
          allergies: allergies == null ? const Value.absent() : Value(allergies.trim()),
          consentStatus: Value(consentStatus),
          source: Value(source),
          createdAt: now,
          updatedAt: now,
        ));

    final created = await (db.select(db.patients)..where((p) => p.id.equals(id))).getSingle();
    return created;
  }
}