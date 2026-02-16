// lib/core/ai/intake_parser.dart

import '../ai/pulse_ai_client.dart';

/// NOTE: Keep this model aligned with your EncounterWorkspaceScreen._IntakeDraft.
/// If you later move _IntakeDraft into a shared file, update imports accordingly.
class IntakeDraftModel {
  IntakeDraftModel({
    this.fullName,
    this.nric,
    this.address,
    this.phone,
    this.allergies,
  });

  final String? fullName;
  final String? nric;
  final String? address;
  final String? phone;
  final String? allergies;

  static IntakeDraftModel fromJson(Map<String, dynamic> j) {
    String? s(String k) {
      final v = j[k];
      if (v == null) return null;
      if (v is String && v.trim().isNotEmpty) return v.trim();
      return null;
    }

    String? digits12(String? x) {
      if (x == null) return null;
      final d = x.replaceAll(RegExp(r'[^0-9]'), '');
      if (d.length == 12) return d;
      // If model gives partial, keep as-is digits (still useful)
      return d.isEmpty ? null : d;
    }

    String? phoneNorm(String? x) {
      if (x == null) return null;
      final p = x.replaceAll(RegExp(r'[^0-9\+]'), '');
      return p.isEmpty ? null : p;
    }

    return IntakeDraftModel(
      fullName: s("fullName"),
      nric: digits12(s("nric")),
      address: s("address"),
      phone: phoneNorm(s("phone")),
      allergies: s("allergies"),
    );
  }
}

/// Parser facade: deterministic fallback + AI enhancement.
class IntakeParser {
  const IntakeParser({
    required PulseAiClient ai,
    required IntakeDraftModel Function(String text) deterministicParse,
  })  : _ai = ai,
        _deterministicParse = deterministicParse;

  final PulseAiClient _ai;
  final IntakeDraftModel Function(String text) _deterministicParse;

  Future<IntakeDraftModel> parse(
    String text, {
    List<String> missingFields = const [],
  }) async {
    final t = text.trim();
    if (t.isEmpty) return IntakeDraftModel();

    try {
      final j = await _ai.extractIntake(
        freeText: t,
        missingFields: missingFields,
      );
      return IntakeDraftModel.fromJson(j);
    } catch (_) {
      // Offline-first: always fallback.
      return _deterministicParse(t);
    }
  }
}