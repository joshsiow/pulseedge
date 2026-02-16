// lib/ui/encounters/encounter_workspace_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/database/app_database.dart';
import '../../core/ai/intake_draft.dart';
import '../patients/patient_timeline_screen.dart';

class EncounterWorkspaceScreen extends ConsumerStatefulWidget {
  const EncounterWorkspaceScreen({
    super.key,
    required this.encounterId,
  });

  final String encounterId;

  @override
  ConsumerState<EncounterWorkspaceScreen> createState() =>
      _EncounterWorkspaceScreenState();
}

class _EncounterWorkspaceScreenState
    extends ConsumerState<EncounterWorkspaceScreen> {
  Encounter? _encounter;
  Patient? _patient;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final db = AppDatabase.instance;

      final encounter = await (db.select(db.encounters)
            ..where((e) => e.id.equals(widget.encounterId))
            ..limit(1))
          .getSingleOrNull();

      if (encounter == null) {
        throw Exception('Encounter not found');
      }

      final patient = await (db.select(db.patients)
            ..where((p) => p.id.equals(encounter.patientId))
            ..limit(1))
          .getSingleOrNull();

      if (!mounted) return;
      setState(() {
        _encounter = encounter;
        _patient = patient;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool get _patientIncomplete {
    final p = _patient;
    if (p == null) return true;

    final missingName = p.fullName.trim().isEmpty;
    final missingId = p.nric.trim().isEmpty;
    final missingAddress = (p.address == null || p.address!.trim().isEmpty);

    return missingName || missingId || missingAddress;
  }

  List<String> _missingFields() {
    final p = _patient;
    if (p == null) return const ['fullName', 'nric', 'address'];

    final missing = <String>[];
    if (p.fullName.trim().isEmpty) missing.add('fullName');
    if (p.nric.trim().isEmpty) missing.add('nric');
    if (p.address == null || p.address!.trim().isEmpty) missing.add('address');
    return missing;
  }

  Future<void> _openTimeline() async {
    final p = _patient;
    if (p == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientTimelineScreen(patientId: p.id),
      ),
    );
  }

  Future<void> _openIntakeCopilot() async {
    final p = _patient;
    if (p == null) return;

    final result = await showModalBottomSheet<IntakeDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _IntakeCopilotSheet(
        existingPatient: p,
        missingFields: _missingFields(),
      ),
    );

    if (result == null) return;

    await _applyIntakeDraftToPatient(result);
    await _load();
  }

  Future<void> _applyIntakeDraftToPatient(IntakeDraft draft) async {
    final p = _patient;
    final e = _encounter;
    if (p == null || e == null) return;

    final db = AppDatabase.instance;

    // Only write provided fields (don’t overwrite existing good data).
    final fullName = (draft.fullName ?? '').trim();
    final nric = (draft.nric ?? '').trim();
    final address = (draft.address ?? '').trim();
    final allergies = (draft.allergies ?? '').trim();

    final companion = PatientsCompanion(
      fullName: fullName.isNotEmpty ? drift.Value(fullName) : const drift.Value.absent(),
      fullNameNorm: fullName.isNotEmpty
          ? drift.Value(_normalizeName(fullName))
          : const drift.Value.absent(),
      nric: nric.isNotEmpty ? drift.Value(_digitsOnly(nric)) : const drift.Value.absent(),
      // If your schema has nricHash, keep this; if not, remove these two lines.
      nricHash: nric.isNotEmpty
          ? drift.Value(_pseudoHashHex(_digitsOnly(nric)))
          : const drift.Value.absent(),
      address: address.isNotEmpty ? drift.Value(address) : const drift.Value.absent(),
      allergies:
          allergies.isNotEmpty ? drift.Value(allergies) : const drift.Value.absent(),
      updatedAt: drift.Value(DateTime.now()),
    );

    await (db.update(db.patients)..where((x) => x.id.equals(p.id)))
        .write(companion);

    // Write a timeline/audit event (encounter-scoped)
    await _writeIntakeEvent(encounterId: e.id, draft: draft);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patient registration updated')),
    );
  }

  Future<void> _writeIntakeEvent({
    required String encounterId,
    required IntakeDraft draft,
  }) async {
    final db = AppDatabase.instance;
    final now = DateTime.now();

    // Prefer the uuid package (already in your deps).
    final eventId = const Uuid().v4();

    final payloadJson = jsonEncode(draft.toJson());
    final bodyText = _safeNoteText(draft);

    await db.into(db.events).insert(
          EventsCompanion.insert(
            id: eventId,
            encounterId: encounterId,
            kind: 'DOC',
            title: 'Intake Draft',
            createdAt: now,

            // Optional columns in your Events table
            status: const drift.Value('draft'),
            bodyText: bodyText == null
                ? const drift.Value.absent()
                : drift.Value(bodyText),
            payloadJson: drift.Value(payloadJson),
            createdBy: const drift.Value.absent(),

            signedBy: const drift.Value.absent(),
            signedAt: const drift.Value.absent(),

            synced: const drift.Value(0),
            syncState: const drift.Value('pending'),
          ),
        );
  }

  String? _safeNoteText(IntakeDraft d) {
    // If your IntakeDraft has toNoteText(), use it. Otherwise, fall back.
    try {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      // (This is just a runtime-safe attempt.)
      // If you DO have toNoteText(), delete this try/catch and call it directly.
      final dynamic dd = d;
      final String s = dd.toNoteText();
      return s.trim().isEmpty ? null : s;
    } catch (_) {
      // Fallback
      final parts = <String>[];
      if ((d.fullName ?? '').trim().isNotEmpty) parts.add('Name: ${d.fullName}');
      if ((d.nric ?? '').trim().isNotEmpty) parts.add('NRIC: ${d.nric}');
      if ((d.address ?? '').trim().isNotEmpty) parts.add('Address: ${d.address}');
      if ((d.phone ?? '').trim().isNotEmpty) parts.add('Phone: ${d.phone}');
      if ((d.allergies ?? '').trim().isNotEmpty) parts.add('Allergies: ${d.allergies}');
      if (parts.isEmpty) return null;
      return parts.join('\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.encounterId.isNotEmpty,
        'EncounterWorkspace requires encounterId');

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Encounter')),
        body: Center(
          child: Text(
            _error!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.red),
          ),
        ),
      );
    }

    final encounter = _encounter!;
    final patient = _patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encounter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderCard(
            patient: patient,
            encounter: encounter,
            showIncompleteWarning: _patientIncomplete,
            onOpenTimeline: _openTimeline,
          ),

          // Intake Copilot (shows only when incomplete)
          if (_patientIncomplete)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: const Text(
                    'Intake Copilot',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'Missing: ${_missingFields().join(', ')}\n'
                    'Tap to fill via quick chat.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openIntakeCopilot,
                ),
              ),
            ),

          const Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Notes'),
                      Tab(text: 'Vitals'),
                      Tab(text: 'Orders'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _PlaceholderPane(
                          icon: Icons.note_alt,
                          text:
                              'Doctor / Nurse notes go here\n(attached to this encounter)',
                        ),
                        _PlaceholderPane(
                          icon: Icons.monitor_heart,
                          text:
                              'Vitals & triage data\n(attached to this encounter)',
                        ),
                        _PlaceholderPane(
                          icon: Icons.medication,
                          text:
                              'Orders (CPOE)\n(attached to this encounter)',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Header
// -----------------------------------------------------------------------------
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.patient,
    required this.encounter,
    required this.showIncompleteWarning,
    required this.onOpenTimeline,
  });

  final Patient? patient;
  final Encounter encounter;
  final bool showIncompleteWarning;
  final VoidCallback onOpenTimeline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              (patient != null && patient!.fullName.trim().isNotEmpty)
                  ? patient!.fullName
                  : 'Unnamed patient',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onOpenTimeline,
                  icon: const Icon(Icons.timeline),
                  label: const Text('Timeline'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _patientSubtitle(patient),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _Chip(
                  icon: Icons.local_hospital,
                  label: encounter.unitName, // non-nullable in your schema
                ),
                _Chip(
                  icon: Icons.badge,
                  label: encounter.providerName ?? 'Unknown provider',
                ),
                _Chip(
                  icon: Icons.schedule,
                  label: _fmt(encounter.startAt),
                ),
              ],
            ),
            if (showIncompleteWarning) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚠ Patient registration incomplete. You can complete it now with Intake Copilot.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _patientSubtitle(Patient? p) {
    if (p == null) return '—';

    final parts = <String>[];

    if (p.nric.trim().isNotEmpty) {
      parts.add(_maskId(p.nric));
    }

    final addr = p.address?.trim() ?? '';
    if (addr.isNotEmpty) parts.add(addr);

    return parts.isEmpty ? '—' : parts.join(' • ');
  }

  String _maskId(String id) {
    if (id.length <= 4) return id;
    return '****${id.substring(id.length - 4)}';
  }

  String _fmt(DateTime d) {
    return '${d.day}/${d.month}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

// -----------------------------------------------------------------------------
// Intake Copilot Bottom Sheet (deterministic parsing now; PulseAI later)
// -----------------------------------------------------------------------------
class _IntakeCopilotSheet extends StatefulWidget {
  const _IntakeCopilotSheet({
    required this.existingPatient,
    required this.missingFields,
  });

  final Patient existingPatient;
  final List<String> missingFields;

  @override
  State<_IntakeCopilotSheet> createState() => _IntakeCopilotSheetState();
}

class _IntakeCopilotSheetState extends State<_IntakeCopilotSheet> {
  final _ctrl = TextEditingController();
  IntakeDraft _draft = const IntakeDraft();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _parse() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final parsed = IntakeDraft.fromFreeText(text);

    setState(() {
      _draft = parsed;
    });
  }

  bool get _hasAnyField =>
      (_draft.fullName?.trim().isNotEmpty ?? false) ||
      (_draft.nric?.trim().isNotEmpty ?? false) ||
      (_draft.address?.trim().isNotEmpty ?? false) ||
      (_draft.phone?.trim().isNotEmpty ?? false) ||
      (_draft.allergies?.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Intake Copilot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Missing: ${widget.missingFields.join(', ')}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Type details in one line',
                hintText:
                    'Example: NRIC 900101015432, address Jalan Ampang, allergy penicillin, phone 0123456789',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _parse,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Parse'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _hasAnyField ? () => Navigator.pop(context, _draft) : null,
                    icon: const Icon(Icons.save),
                    label: const Text('Save to patient'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_hasAnyField) _DraftPreview(draft: _draft),
            const SizedBox(height: 8),
            const Text(
              'Tip: You can paste WhatsApp text. This is offline parsing now; later we’ll swap it to PulseAI.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftPreview extends StatelessWidget {
  const _DraftPreview({required this.draft});

  final IntakeDraft draft;

  @override
  Widget build(BuildContext context) {
    final items = <String>[];
    if (draft.fullName?.trim().isNotEmpty ?? false) {
      items.add('Full name: ${draft.fullName}');
    }
    if (draft.nric?.trim().isNotEmpty ?? false) {
      items.add('NRIC: ${draft.nric}');
    }
    if (draft.address?.trim().isNotEmpty ?? false) {
      items.add('Address: ${draft.address}');
    }
    if (draft.phone?.trim().isNotEmpty ?? false) {
      items.add('Phone: ${draft.phone}');
    }
    if (draft.allergies?.trim().isNotEmpty ?? false) {
      items.add('Allergies: ${draft.allergies}');
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Preview',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $s'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// UI helpers
// -----------------------------------------------------------------------------
class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _PlaceholderPane extends StatelessWidget {
  const _PlaceholderPane({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.disabledColor),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Simple helpers (local)
// -----------------------------------------------------------------------------
String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

String _normalizeName(String s) {
  final lower = s.toLowerCase();
  final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Non-crypto placeholder hash for deterministic storage.
/// Replace later with package:crypto sha256 if you want.
String _pseudoHashHex(String input) {
  var h = 0;
  for (final c in input.codeUnits) {
    h = 0x1fffffff & (h + c);
    h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
    h ^= (h >> 6);
  }
  h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
  h ^= (h >> 11);
  h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
  return h.toRadixString(16).padLeft(8, '0');
}