import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';
import '../../core/database/app_database.dart';
import '../../core/session/session_context_store.dart';

import 'modules/patient_overview_module.dart';
import 'modules/patient_demographics_module.dart';
import 'modules/patient_encounters_module.dart';
import 'modules/patient_documents_module.dart';
import 'modules/patient_sync_audit_module.dart';

class PatientWorkspaceScreen extends ConsumerStatefulWidget {
  final String patientId;
  const PatientWorkspaceScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientWorkspaceScreen> createState() =>
      _PatientWorkspaceScreenState();
}

class _PatientWorkspaceScreenState
    extends ConsumerState<PatientWorkspaceScreen> {
  int index = 0;
  Patient? patient;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final db = AppDatabase.instance;
    final p = await (db.select(db.patients)
          ..where((t) => t.id.equals(widget.patientId))
          ..limit(1))
        .getSingleOrNull();
    if (!mounted) return;
    setState(() => patient = p);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    final sessionStore = ref.watch(sessionContextStoreProvider);

    final username = auth.currentUser?.username ?? 'Unknown';

    final p = patient;
    final title = p == null ? 'Patient Workspace' : p.fullName;

    return FutureBuilder(
      future: sessionStore.getActive(),
      builder: (context, snap) {
        final unitName = snap.data?.unitName ?? 'No Unit';

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(78),
              child: patient == null
                  ? const SizedBox(
                      height: 78,
                      child: LinearProgressIndicator(),
                    )
                  : SizedBox(
                      height: 78,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: _PatientBanner(
                          patient: patient!, // safe: guarded above
                          user: username,
                          unit: unitName,
                        ),
                      ),
                    ),
            ),
          ),
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Overview'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.badge_outlined),
                    selectedIcon: Icon(Icons.badge),
                    label: Text('Demographics'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.event_note_outlined),
                    selectedIcon: Icon(Icons.event_note),
                    label: Text('Encounters'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder),
                    label: Text('Documents'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.sync_outlined),
                    selectedIcon: Icon(Icons.sync),
                    label: Text('Sync & Audit'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: p == null
                    ? const Center(child: CircularProgressIndicator())
                    : IndexedStack(
                        index: index,
                        children: [
                          PatientOverviewModule(patient: p),
                          PatientDemographicsModule(
                            patient: p,
                            onUpdated: _loadPatient,
                          ),
                          PatientEncountersModule(patient: p),
                          PatientDocumentsModule(patient: p),
                          PatientSyncAuditModule(patient: p),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PatientBanner extends StatelessWidget {
  final Patient patient;
  final String user;
  final String unit;

  const _PatientBanner({
    required this.patient,
    required this.user,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final mrn = (patient.mrn ?? '').trim().isEmpty ? '—' : patient.mrn!;
    final consent = patient.consentStatus;
    final allergies =
        (patient.allergies == null || patient.allergies!.trim().isEmpty)
            ? 'None'
            : patient.allergies!;
    final nricMasked = _maskNric(patient.nric);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      width: double.infinity,
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: [
          _pill('MRN', mrn),
          _pill('NRIC', nricMasked),
          _pill('Consent', consent),
          _pill('Allergies', allergies),
          _pill('Unit', unit),
          _pill('User', user),
        ],
      ),
    );
  }

  Widget _pill(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$k: $v',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  static String _maskNric(String nric) {
    if (nric.isEmpty) return '—';
    if (nric.length <= 4) return '****';
    return '****${nric.substring(nric.length - 4)}';
  }
}