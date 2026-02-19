// lib/ui/encounters/encounter_registration_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import 'package:pulseedge/core/database/app_database.dart';
import 'package:pulseedge/core/session/session_context_store.dart';
import 'package:pulseedge/ui/encounters/encounter_workspace_screen.dart';

class EncounterRegistrationScreen extends StatefulWidget {
  const EncounterRegistrationScreen({super.key});

  @override
  State<EncounterRegistrationScreen> createState() =>
      _EncounterRegistrationScreenState();
}

class _EncounterRegistrationScreenState extends State<EncounterRegistrationScreen> {
  final _db = AppDatabase.instance;
  final _sessionStore = SessionContextStore();

  SessionContext? _ctx;

  // Search / create
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _searchText = '';
  bool _searching = false;
  List<_PatientHit> _patientHits = [];

  // “Fast create” fields
  final _fullNameCtrl = TextEditingController();
  final _nricCtrl = TextEditingController();

  // Encounters list
  bool _loadingEncounters = true;
  List<_EncounterRow> _encounters = [];
  String? _encountersError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _fullNameCtrl.dispose();
    _nricCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final ctx = await _sessionStore.getActive();
    if (!mounted) return;

    setState(() => _ctx = ctx);

    // If no active session context, we still allow the screen to render,
    // but encounter creation will fall back to "Default Unit".
    await _autoCloseOvernightOpd();
    await _loadEncounters();
  }

  DateTime _todayStartLocal() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Rule: OPD is same-day. If encounter is still open after midnight, close it.
  Future<void> _autoCloseOvernightOpd() async {
    final ctx = _ctx;
    if (ctx == null) return;

    final todayStart = _todayStartLocal();

    final q = _db.update(_db.encounters)
      ..where((e) =>
          e.unitId.equals(ctx.unitId) &
          e.type.equals('OPD') &
          e.endAt.isNull() &
          e.startAt.isSmallerThanValue(todayStart));

    await q.write(
      EncountersCompanion(
        status: const drift.Value('closed'),
        endAt: drift.Value(todayStart),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> _loadEncounters() async {
    setState(() {
      _loadingEncounters = true;
      _encountersError = null;
    });

    try {
      final ctx = _ctx;
      final todayStart = _todayStartLocal();

      final encounters = _db.encounters;
      final patients = _db.patients;

      final join = _db.select(encounters).join([
        drift.innerJoin(patients, patients.id.equalsExp(encounters.patientId)),
      ]);

      if (ctx != null) {
        join.where(
          encounters.unitId.equals(ctx.unitId) &
              (
                // open encounters any day
                encounters.endAt.isNull() |
                // today's encounters
                encounters.startAt.isBiggerOrEqualValue(todayStart)
              ),
        );
      } else {
        // Fallback (no session): just show today's encounters across all units
        join.where(encounters.startAt.isBiggerOrEqualValue(todayStart));
      }

      join.orderBy([
        drift.OrderingTerm.desc(encounters.startAt),
        drift.OrderingTerm.desc(encounters.createdAt),
      ]);

      final rows = await join.get();

      // Optional debug:
      // debugPrint('Encounter join rows=${rows.length}, ctx.unitId=${ctx?.unitId}, ctx.unitName=${ctx?.unitName}');

      final list = rows.map((r) {
        final e = r.readTable(encounters);
        final p = r.readTable(patients);
        return _EncounterRow(encounter: e, patient: p);
      }).toList();

      if (!mounted) return;
      setState(() {
        _encounters = list;
        _loadingEncounters = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _encountersError = e.toString();
        _loadingEncounters = false;
        _encounters = [];
      });
    }
  }

  void _onSearchChanged(String v) {
    _searchText = v;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      await _runPatientSearch(_searchText);
    });
  }

  String _norm(String s) => s.trim().toLowerCase();

  Future<void> _runPatientSearch(String raw) async {
    final q = _norm(raw);
    if (q.isEmpty) {
      if (!mounted) return;
      setState(() {
        _patientHits = [];
        _searching = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _searching = true);

    final patients = _db.patients;

    final query = _db.select(patients)
      ..where((p) {
        final like = '%$q%';
        return p.fullNameNorm.like(like) |
            p.nric.like(like) |
            p.phone.like(like);
      })
      ..orderBy([
        (p) => drift.OrderingTerm.asc(p.fullNameNorm),
        (p) => drift.OrderingTerm.desc(p.updatedAt),
      ])
      ..limit(30);

    final hits = await query.get();

    if (!mounted) return;
    setState(() {
      _patientHits = hits.map((p) => _PatientHit.fromPatient(p)).toList();
      _searching = false;
    });
  }

  String _unitLabel() => _ctx?.unitName ?? 'Default Unit';

  Future<void> _openEncounter(String encounterId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EncounterWorkspaceScreen(encounterId: encounterId),
      ),
    );

    // After returning, refresh list (status might change)
    if (!mounted) return;
    await _loadEncounters();
  }

  Future<String?> _findActiveEncounterForPatientInUnit(String patientId) async {
    final ctx = _ctx;
    if (ctx == null) return null;

    final q = _db.select(_db.encounters)
      ..where((e) =>
          e.patientId.equals(patientId) &
          e.unitId.equals(ctx.unitId) &
          e.endAt.isNull() &
          e.status.equals('open'))
      ..orderBy([(e) => drift.OrderingTerm.desc(e.startAt)])
      ..limit(1);

    final existing = await q.getSingleOrNull();
    return existing?.id;
  }

  Future<void> _startEncounterForExistingPatient(String patientId) async {
    final ctx = _ctx;

    // Enforce: only one active encounter per patient per unit.
    final existingId = await _findActiveEncounterForPatientInUnit(patientId);
    if (existingId != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Active encounter found. Resuming…')),
      );
      await _openEncounter(existingId);
      return;
    }

    // Create new encounter.
    final now = DateTime.now();
    final encounterId = const Uuid().v4();

    final unitId = ctx?.unitId;
    final unitName = ctx?.unitName ?? 'Default Unit';

    await _db.into(_db.encounters).insert(
      EncountersCompanion(
        id: drift.Value(encounterId),
        patientId: drift.Value(patientId),
        encounterNo: const drift.Value.absent(),
        status: const drift.Value('open'),
        type: const drift.Value('OPD'),
        unitId: drift.Value(unitId),
        unitName: drift.Value(unitName),
        providerUserId: const drift.Value.absent(),
        providerName: const drift.Value.absent(),
        chiefComplaint: const drift.Value.absent(),
        triageCategory: const drift.Value.absent(),
        startAt: drift.Value(now),
        endAt: const drift.Value.absent(),
        synced: const drift.Value(0),
        syncState: const drift.Value('pending'),
        aiMetadata: const drift.Value.absent(),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    if (!mounted) return;
    await _openEncounter(encounterId);
  }

  Future<void> _startEncounterFastCreate() async {
    final name = _fullNameCtrl.text.trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    final patientId = const Uuid().v4();

    final nric = _nricCtrl.text.trim();

    await _db.into(_db.patients).insert(
      PatientsCompanion(
        id: drift.Value(patientId),
        mrn: const drift.Value.absent(),
        fullName: drift.Value(name),
        fullNameNorm: drift.Value(_norm(name)),
        nric: drift.Value(nric.isEmpty ? '-' : nric),
        nricHash: const drift.Value(''), // keep non-null if required in schema
        gender: const drift.Value.absent(),
        dob: const drift.Value.absent(),
        phone: const drift.Value.absent(),
        address: const drift.Value.absent(),
        allergies: const drift.Value.absent(),
        consentStatus: const drift.Value('unknown'),
        source: const drift.Value('local'),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    _fullNameCtrl.clear();
    _nricCtrl.clear();

    if (!mounted) return;
    await _startEncounterForExistingPatient(patientId);
  }

  String _maskId(String? nric) {
    if (nric == null) return '';
    final s = nric.trim();
    if (s.isEmpty || s == '-') return '';
    if (s.length <= 4) return '****$s';
    return '****${s.substring(s.length - 4)}';
  }

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctx = _ctx;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Encounter'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadEncounters,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Header hint
            if (ctx == null)
              _infoBanner(
                'No active session context found. '
                'Select a unit on the home screen to enable per-unit encounter rules.',
              )
            else
              _infoBanner('Unit: ${ctx.unitName}'),

            _sectionTitle('Encounters (tap to continue)'),

            if (_encountersError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Failed to load encounters: $_encountersError',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            _loadingEncounters
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _encounters.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No encounters found for ${_unitLabel()}.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : Column(
                        children: _encounters.map(_encounterTile).toList(),
                      ),

            const SizedBox(height: 16),

            _sectionTitle('Find existing patient'),
            _searchBox(),

            if (_searching)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_patientHits.isNotEmpty)
              Column(
                children: _patientHits.map(_patientHitTile).toList(),
              ),

            const SizedBox(height: 16),

            _sectionTitle('Create new patient (fast)'),
            _fastCreateCard(),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Text(text),
    );
  }

  Widget _encounterTile(_EncounterRow row) {
    final e = row.encounter;
    final p = row.patient;

    final open = e.endAt == null && e.status == 'open';
    final subtitleParts = <String>[];
    final masked = _maskId(p.nric);
    if (masked.isNotEmpty) subtitleParts.add(masked);

    subtitleParts.add('${e.type} • ${_formatTime(e.startAt)}');

    if (!open && e.endAt != null) {
      subtitleParts.add('Closed ${_formatTime(e.endAt!)}');
    } else {
      subtitleParts.add('OPEN');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          p.fullName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitleParts.join(' • ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openEncounter(e.id),
      ),
    );
  }

  Widget _searchBox() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search patient (NRIC / phone / name)',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchCtrl.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  _searchCtrl.clear();
                  _onSearchChanged('');
                },
                icon: const Icon(Icons.close),
              ),
          ],
        ),
      ),
    );
  }

  Widget _patientHitTile(_PatientHit hit) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: ListTile(
        title: Text(
          hit.fullName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(hit.subtitle),
        trailing: const Icon(Icons.play_arrow),
        onTap: () => _startEncounterForExistingPatient(hit.id),
      ),
    );
  }

  Widget _fastCreateCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start the encounter now. You can complete registration later.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full name',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nricCtrl,
              decoration: const InputDecoration(
                labelText: 'NRIC / Old ID (optional)',
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start encounter'),
                onPressed: _startEncounterFastCreate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EncounterRow {
  final Encounter encounter;
  final Patient patient;

  _EncounterRow({required this.encounter, required this.patient});
}

class _PatientHit {
  final String id;
  final String fullName;
  final String subtitle;

  _PatientHit({
    required this.id,
    required this.fullName,
    required this.subtitle,
  });

  factory _PatientHit.fromPatient(Patient p) {
    final parts = <String>[];

    // These fields exist in your new schema (gender/dob/phone); if null, it’s fine.
    if (p.gender != null && p.gender!.trim().isNotEmpty) parts.add(p.gender!);
    if (p.dob != null) {
      final d = p.dob!.toIso8601String().split('T').first;
      parts.add('DOB: $d');
    }
    if (p.phone != null && p.phone!.trim().isNotEmpty) {
      parts.add('Phone: ${p.phone}');
    }
    if (p.nric.trim().isNotEmpty && p.nric != '-') {
      final s = p.nric.trim();
      parts.add(s.length <= 4 ? '****$s' : '****${s.substring(s.length - 4)}');
    }

    return _PatientHit(
      id: p.id,
      fullName: p.fullName,
      subtitle: parts.isEmpty ? '—' : parts.join(' • '),
    );
  }
}