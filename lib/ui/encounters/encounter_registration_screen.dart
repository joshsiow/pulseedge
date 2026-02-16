import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';
import '../../core/patients/patient_encounter_service.dart';
import '../../core/session/session_context_store.dart';
import 'encounter_workspace_screen.dart';

class EncounterRegistrationScreen extends ConsumerStatefulWidget {
  const EncounterRegistrationScreen({super.key});

  @override
  ConsumerState<EncounterRegistrationScreen> createState() =>
      _EncounterRegistrationScreenState();
}

class _EncounterRegistrationScreenState
    extends ConsumerState<EncounterRegistrationScreen> {
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();

  List<PatientSearchHit> _results = const [];
  bool _searching = false;
  bool _creating = false;
  String? _error;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Search patients (offline-first)
  // ---------------------------------------------------------------------------
  Future<void> _searchPatients(String q) async {
    final query = q.trim();
    if (query.length < 2) {
      setState(() => _results = const []);
      return;
    }

    setState(() {
      _searching = true;
      _error = null;
    });

    try {
      final svc = ref.read(patientEncounterServiceProvider);
      final hits = await svc.searchPatients(query: query);
      setState(() => _results = hits);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _searching = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Start encounter for existing patient
  // ---------------------------------------------------------------------------
  Future<void> _startEncounterForPatient(String patientId) async {
    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final session =
          await ref.read(sessionContextStoreProvider).getActive();
      if (session == null) {
        throw Exception('Session required');
      }

      final auth = ref.read(authServiceProvider);
      final user = auth.currentUser!;
      final svc = ref.read(patientEncounterServiceProvider);

      final encounterId = await svc.createEncounter(
        CreateEncounterInput(
          patientId: patientId,
          unitId: session.unitId,
          unitName: session.unitName,
          providerUserId: user.id,
          providerName: _providerNameFromUser(user),
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EncounterWorkspaceScreen(encounterId: encounterId),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _creating = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Create patient stub + start encounter (with duplicate-risk confirmation)
  // ---------------------------------------------------------------------------
  Future<void> _createStubAndStart() async {
    final fullName = _nameCtrl.text.trim();
    if (fullName.isEmpty) {
      setState(() => _error = 'Patient name is required');
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final svc = ref.read(patientEncounterServiceProvider);

      // 1️⃣ Duplicate-risk check
      final possibles = await svc.findPossibleDuplicates(
        fullName: fullName,
        nricOrOldId: _idCtrl.text.trim(),
      );

      if (possibles.isNotEmpty) {
        final decision = await _showDuplicateDialog(possibles);
        if (!mounted) return;

        if (decision == _DuplicateDecision.useExisting) {
          await _startEncounterForPatient(possibles.first.patientId);
          return;
        }

        if (decision == _DuplicateDecision.cancel) {
          setState(() => _creating = false);
          return;
        }
        // else: Create anyway
      }

      // 2️⃣ Create stub + encounter
      final session =
          await ref.read(sessionContextStoreProvider).getActive();
      if (session == null) {
        throw Exception('Session required');
      }

      final auth = ref.read(authServiceProvider);
      final user = auth.currentUser!;

      final encounterId = await svc.createStubAndStartEncounter(
        patient: CreatePatientStubInput(
          fullName: fullName,
          nricOrOldId:
              _idCtrl.text.trim().isEmpty ? null : _idCtrl.text.trim(),
        ),
        unitId: session.unitId,
        unitName: session.unitName,
        providerUserId: user.id,
        providerName: _providerNameFromUser(user),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EncounterWorkspaceScreen(encounterId: encounterId),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _creating = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Encounter')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search patient (NRIC / phone / name)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchPatients,
            ),
            const SizedBox(height: 12),
            if (_searching)
              const LinearProgressIndicator(minHeight: 2),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty
                  ? _buildCreateStubCard()
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, i) {
                        final p = _results[i];
                        return Card(
                          elevation: 0,
                          child: ListTile(
                            title: Text(
                              p.fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${p.nricMasked}'
                              '${p.lastSeenAt != null ? ' • Last seen ${_fmt(p.lastSeenAt!)}' : ''}',
                            ),
                            trailing: p.isIncomplete
                                ? const Icon(Icons.warning_amber,
                                    color: Colors.orange)
                                : null,
                            onTap: _creating
                                ? null
                                : () =>
                                    _startEncounterForPatient(p.patientId),
                          ),
                        );
                      },
                    ),
            ),
            if (_creating)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Create stub UI
  // ---------------------------------------------------------------------------
  Widget _buildCreateStubCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create new patient (fast)',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start the encounter now. You can complete registration later.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _idCtrl,
              decoration: const InputDecoration(
                labelText: 'NRIC / Old ID (optional)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _creating ? null : _createStubAndStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start encounter'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Duplicate confirmation dialog
  // ---------------------------------------------------------------------------
  Future<_DuplicateDecision> _showDuplicateDialog(
    List<PatientSearchHit> hits,
  ) async {
    return await showDialog<_DuplicateDecision>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Possible duplicate patient'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'We found patients with similar names. '
                    'Please confirm before creating a new record.',
                  ),
                  const SizedBox(height: 12),
                  ...hits.map(
                    (p) => ListTile(
                      title: Text(p.fullName),
                      subtitle: Text(
                        '${p.nricMasked}'
                        '${p.lastSeenAt != null ? ' • Last seen ${_fmt(p.lastSeenAt!)}' : ''}',
                      ),
                      onTap: () => Navigator.of(ctx)
                          .pop(_DuplicateDecision.useExisting),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx)
                      .pop(_DuplicateDecision.cancel),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx)
                      .pop(_DuplicateDecision.createAnyway),
                  child: const Text('Create anyway'),
                ),
              ],
            );
          },
        ) ??
        _DuplicateDecision.cancel;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _providerNameFromUser(dynamic user) {
    try {
      final u = user as dynamic;
      if (u.fullName != null && (u.fullName as String).isNotEmpty) {
        return u.fullName as String;
      }
      if (u.displayName != null &&
          (u.displayName as String).isNotEmpty) {
        return u.displayName as String;
      }
      if (u.username != null && (u.username as String).isNotEmpty) {
        return u.username as String;
      }
      if (u.email != null && (u.email as String).isNotEmpty) {
        return u.email as String;
      }
    } catch (_) {}
    return 'Provider ${user.id}';
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

// ---------------------------------------------------------------------------
// Internal enums
// ---------------------------------------------------------------------------
enum _DuplicateDecision {
  useExisting,
  createAnyway,
  cancel,
}