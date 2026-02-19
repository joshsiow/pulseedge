// lib/ui/encounters/encounter_workspace_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/ai/intake_draft.dart';
import '../../core/database/app_database.dart';
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

  // --- Autosave / Draft state ---
  static const _draftKindNotes = 'notes';
  static const Duration _autosaveDebounce = Duration(milliseconds: 1200);

  Timer? _autosaveTimer;
  String? _draftId; // persisted draft row id (uuid)
  bool _restoredBannerVisible = false;
  DateTime? _lastAutosavedAt;
  bool _savingDraft = false;

  // Important: avoid autosave firing while we are restoring draft into controllers
  bool _restoringDraft = false;

  final _chiefComplaintCtrl = TextEditingController();
  final _hpiCtrl = TextEditingController();
  final _pmhCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _examCtrl = TextEditingController();
  final _assessmentCtrl = TextEditingController();
  final _planCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _attachAutosaveListeners();
    _load();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();

    _chiefComplaintCtrl.dispose();
    _hpiCtrl.dispose();
    _pmhCtrl.dispose();
    _medsCtrl.dispose();
    _allergiesCtrl.dispose();
    _examCtrl.dispose();
    _assessmentCtrl.dispose();
    _planCtrl.dispose();

    super.dispose();
  }

  void _attachAutosaveListeners() {
    void onAnyChange() {
      if (_restoringDraft) return;
      _scheduleAutosave();
    }

    _chiefComplaintCtrl.addListener(onAnyChange);
    _hpiCtrl.addListener(onAnyChange);
    _pmhCtrl.addListener(onAnyChange);
    _medsCtrl.addListener(onAnyChange);
    _allergiesCtrl.addListener(onAnyChange);
    _examCtrl.addListener(onAnyChange);
    _assessmentCtrl.addListener(onAnyChange);
    _planCtrl.addListener(onAnyChange);
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

      // Save these first so draft restore can autosave safely later
      if (!mounted) return;
      setState(() {
        _encounter = encounter;
        _patient = patient;
      });

      // Load draft AFTER encounter/patient exists
      await _loadDraftIfAny(encounterId: encounter.id);

      if (!mounted) return;
      setState(() {
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

    final fullName = (draft.fullName ?? '').trim();
    final nric = (draft.nric ?? '').trim();
    final address = (draft.address ?? '').trim();
    final allergies = (draft.allergies ?? '').trim();

    final companion = PatientsCompanion(
      fullName: fullName.isNotEmpty
          ? drift.Value(fullName)
          : const drift.Value.absent(),
      fullNameNorm: fullName.isNotEmpty
          ? drift.Value(_normalizeName(fullName))
          : const drift.Value.absent(),
      nric: nric.isNotEmpty
          ? drift.Value(_digitsOnly(nric))
          : const drift.Value.absent(),
      nricHash: nric.isNotEmpty
          ? drift.Value(_pseudoHashHex(_digitsOnly(nric)))
          : const drift.Value.absent(),
      address:
          address.isNotEmpty ? drift.Value(address) : const drift.Value.absent(),
      allergies: allergies.isNotEmpty
          ? drift.Value(allergies)
          : const drift.Value.absent(),
      updatedAt: drift.Value(DateTime.now()),
    );

    await (db.update(db.patients)..where((x) => x.id.equals(p.id)))
        .write(companion);

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
    try {
      final dynamic dd = d;
      final String s = dd.toNoteText();
      return s.trim().isEmpty ? null : s;
    } catch (_) {
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

  // -----------------------------
  // Draft Load / Autosave
  // -----------------------------
  Map<String, dynamic> _notesPayload() {
    return {
      'chiefComplaint': _chiefComplaintCtrl.text,
      'hpi': _hpiCtrl.text,
      'pmh': _pmhCtrl.text,
      'meds': _medsCtrl.text,
      'allergies': _allergiesCtrl.text,
      'exam': _examCtrl.text,
      'assessment': _assessmentCtrl.text,
      'plan': _planCtrl.text,
    };
  }

  bool _payloadHasAnyContent(Map<String, dynamic> p) {
    for (final v in p.values) {
      if (v is String && v.trim().isNotEmpty) return true;
    }
    return false;
  }

  Future<void> _loadDraftIfAny({required String encounterId}) async {
    final db = AppDatabase.instance;

    final draft = await (db.select(db.encounterDrafts)
          ..where((d) =>
              d.encounterId.equals(encounterId) & d.kind.equals(_draftKindNotes))
          ..orderBy([(d) => drift.OrderingTerm.desc(d.updatedAt)])
          ..limit(1))
        .getSingleOrNull();

    if (draft == null) return;

    try {
      final Map<String, dynamic> payload =
          (jsonDecode(draft.payloadJson) as Map).cast<String, dynamic>();

      if (!_payloadHasAnyContent(payload)) return;

      _restoringDraft = true;
      _draftId = draft.id;

      _chiefComplaintCtrl.text = (payload['chiefComplaint'] ?? '').toString();
      _hpiCtrl.text = (payload['hpi'] ?? '').toString();
      _pmhCtrl.text = (payload['pmh'] ?? '').toString();
      _medsCtrl.text = (payload['meds'] ?? '').toString();
      _allergiesCtrl.text = (payload['allergies'] ?? '').toString();
      _examCtrl.text = (payload['exam'] ?? '').toString();
      _assessmentCtrl.text = (payload['assessment'] ?? '').toString();
      _planCtrl.text = (payload['plan'] ?? '').toString();

      _restoredBannerVisible = true;
      _lastAutosavedAt = draft.updatedAt;
    } catch (_) {
      return;
    } finally {
      _restoringDraft = false;
    }
  }

  void _scheduleAutosave() {
    final e = _encounter;
    final p = _patient;
    if (e == null || p == null) return;

    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, () async {
      await _saveDraft(encounterId: e.id, patientId: p.id);
    });
  }

  Future<void> _saveDraft({
    required String encounterId,
    required String patientId,
  }) async {
    final db = AppDatabase.instance;
    final now = DateTime.now();

    final payload = _notesPayload();
    if (!_payloadHasAnyContent(payload)) {
      // Don’t spam DB with empty drafts
      return;
    }

    if (!mounted) return;
    setState(() => _savingDraft = true);

    final id = _draftId ?? const Uuid().v4();
    final isNew = _draftId == null;

    final row = EncounterDraftsCompanion(
      id: drift.Value(id),
      encounterId: drift.Value(encounterId),
      patientId: drift.Value(patientId),
      kind: const drift.Value(_draftKindNotes),
      payloadJson: drift.Value(jsonEncode(payload)),
      createdAt: drift.Value(isNew ? now : (_lastAutosavedAt ?? now)),
      updatedAt: drift.Value(now),
    );

    await db.into(db.encounterDrafts).insert(
          row,
          mode: drift.InsertMode.insertOrReplace,
        );

    if (!mounted) return;
    setState(() {
      _draftId = id;
      _lastAutosavedAt = now;
      _savingDraft = false;
    });
  }

  Future<void> _forceSaveNow() async {
    final messenger = ScaffoldMessenger.of(context);

    final e = _encounter;
    final p = _patient;
    if (e == null || p == null) return;

    _autosaveTimer?.cancel();
    await _saveDraft(encounterId: e.id, patientId: p.id);

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  }

  Future<void> _clearDraft() async {
    final messenger = ScaffoldMessenger.of(context);

    final db = AppDatabase.instance;
    final id = _draftId;
    if (id == null) return;

    await (db.delete(db.encounterDrafts)..where((d) => d.id.equals(id))).go();

    if (!mounted) return;
    setState(() {
      _draftId = null;
      _restoredBannerVisible = false;
      _lastAutosavedAt = null;
    });

    messenger.showSnackBar(
      const SnackBar(content: Text('Draft cleared')),
    );
  }

  // -----------------------------
  // WillPopScope (Back handling)
  // -----------------------------
  bool get _hasUnsavedWork {
    // If we have any content, treat it as something worth saving.
    final payload = _notesPayload();
    return _payloadHasAnyContent(payload);
  }

  Future<bool> _onWillPop() async {
  // Capture BEFORE any await
    final messenger = ScaffoldMessenger.of(context);

    _autosaveTimer?.cancel();

    if (_savingDraft) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Saving… please wait')),
      );
      return false;
    }

    final e = _encounter;
    final p = _patient;

    if (e != null && p != null && _hasUnsavedWork) {
      await _saveDraft(encounterId: e.id, patientId: p.id);
      if (!mounted) return false; // guard after await
    }

    // showDialog uses context -> safe now because we checked mounted
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave encounter?'),
        content: const Text('You will return to the encounter list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return res ?? false;
  }

  // -----------------------------
  // UI
  // -----------------------------
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Encounter'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // capture navigator BEFORE await
              final navigator = Navigator.of(context);

              final ok = await _onWillPop();
              if (!mounted) return;

              if (ok) navigator.pop();
            },
          ),
          actions: [
            if (_savingDraft)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_lastAutosavedAt != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    'Saved ${_relativeTime(_lastAutosavedAt!)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            IconButton(
              tooltip: 'Save now',
              icon: const Icon(Icons.save),
              onPressed: _savingDraft ? null : _forceSaveNow,
            ),
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

            // Draft recovery banner
            if (_restoredBannerVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: MaterialBanner(
                  content: const Text('Restored unsaved changes'),
                  leading: const Icon(Icons.history),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() => _restoredBannerVisible = false);
                      },
                      child: const Text('Dismiss'),
                    ),
                    TextButton(
                      onPressed: _clearDraft,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
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
                      'Missing: ${_missingFields().join(', ')}\nTap to fill via quick chat.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _openIntakeCopilot,
                  ),
                ),
              ),

            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Notes'),
                        Tab(text: 'Vitals'),
                        Tab(text: 'Orders'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _NotesPane(
                            chiefComplaintCtrl: _chiefComplaintCtrl,
                            hpiCtrl: _hpiCtrl,
                            pmhCtrl: _pmhCtrl,
                            medsCtrl: _medsCtrl,
                            allergiesCtrl: _allergiesCtrl,
                            examCtrl: _examCtrl,
                            assessmentCtrl: _assessmentCtrl,
                            planCtrl: _planCtrl,
                          ),
                          const _PlaceholderPane(
                            icon: Icons.monitor_heart,
                            text: 'Vitals & triage data\n(attached to this encounter)',
                          ),
                          const _PlaceholderPane(
                            icon: Icons.medication,
                            text: 'Orders (CPOE)\n(attached to this encounter)',
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
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 5) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

// -----------------------------------------------------------------------------
// Notes Pane (real-life-ish casenote structure)
// -----------------------------------------------------------------------------
class _NotesPane extends StatelessWidget {
  const _NotesPane({
    required this.chiefComplaintCtrl,
    required this.hpiCtrl,
    required this.pmhCtrl,
    required this.medsCtrl,
    required this.allergiesCtrl,
    required this.examCtrl,
    required this.assessmentCtrl,
    required this.planCtrl,
  });

  final TextEditingController chiefComplaintCtrl;
  final TextEditingController hpiCtrl;
  final TextEditingController pmhCtrl;
  final TextEditingController medsCtrl;
  final TextEditingController allergiesCtrl;
  final TextEditingController examCtrl;
  final TextEditingController assessmentCtrl;
  final TextEditingController planCtrl;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        _Section(
          title: 'Chief Complaint',
          child: TextField(
            controller: chiefComplaintCtrl,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'e.g., “Fever and cough for 3 days”',
            ),
          ),
        ),
        _Section(
          title: 'HPI',
          child: TextField(
            controller: hpiCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Timeline, severity, associated symptoms, red flags…',
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _Section(
                title: 'PMH',
                child: TextField(
                  controller: pmhCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Comorbidities, surgeries…',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Section(
                title: 'Meds',
                child: TextField(
                  controller: medsCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Current medications…',
                  ),
                ),
              ),
            ),
          ],
        ),
        _Section(
          title: 'Allergies',
          child: TextField(
            controller: allergiesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Drug / food allergies…',
            ),
          ),
        ),
        _Section(
          title: 'Examination',
          child: TextField(
            controller: examCtrl,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Vitals summary + focused exam findings…',
            ),
          ),
        ),
        _Section(
          title: 'Assessment',
          child: TextField(
            controller: assessmentCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Working diagnosis + differentials…',
            ),
          ),
        ),
        _Section(
          title: 'Plan',
          child: TextField(
            controller: planCtrl,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Investigations, treatment, safety net, follow-up…',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Autosaves after you stop typing.',
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
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
              style:
                  theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
                _Chip(icon: Icons.local_hospital, label: encounter.unitName),
                _Chip(
                    icon: Icons.badge,
                    label: encounter.providerName ?? 'Unknown provider'),
                _Chip(icon: Icons.schedule, label: _fmt(encounter.startAt)),
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
    if (p.nric.trim().isNotEmpty) parts.add(_maskId(p.nric));

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

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PlaceholderPane extends StatelessWidget {
  const _PlaceholderPane({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 10),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Intake Copilot Bottom Sheet
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
    setState(() => _draft = parsed);
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Type details like:\n“Name Ali, NRIC 901010-10-1010, address..., allergies penicillin”',
                helperText: 'Missing: ${widget.missingFields.join(', ')}',
              ),
              onChanged: (_) => _parse(),
            ),
            const SizedBox(height: 12),
            if (_hasAnyField)
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _kv('Name', _draft.fullName),
                      _kv('NRIC', _draft.nric),
                      _kv('Address', _draft.address),
                      _kv('Phone', _draft.phone),
                      _kv('Allergies', _draft.allergies),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        _hasAnyField ? () => Navigator.pop(context, _draft) : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String? v) {
    final vv = (v ?? '').trim();
    if (vv.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$k: $vv'),
    );
  }
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
String _normalizeName(String s) {
  return s.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
}

String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

String _pseudoHashHex(String s) {
  // Lightweight placeholder; replace with a real SHA-256 if needed.
  final bytes = utf8.encode('nric:$s');
  int h = 0;
  for (final b in bytes) {
    h = (h * 31 + b) & 0x7fffffff;
  }
  return h.toRadixString(16).padLeft(8, '0');
}