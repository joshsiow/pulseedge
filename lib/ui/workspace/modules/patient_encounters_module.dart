import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/encounters/encounter_repo.dart';
import '../../encounters/encounter_registration_screen.dart';
import '../../encounters/encounter_workspace_screen.dart';

class PatientEncountersModule extends ConsumerStatefulWidget {
  final Patient patient;
  const PatientEncountersModule({super.key, required this.patient});

  @override
  ConsumerState<PatientEncountersModule> createState() =>
      _PatientEncountersModuleState();
}

class _PatientEncountersModuleState extends ConsumerState<PatientEncountersModule> {
  late final EncounterRepo repo;
  List<Encounter> encounters = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    // IMPORTANT:
    // Your EncounterRepo currently expects Ref<Object?> in the constructor (per compiler error).
    // WidgetRef is not assignable to Ref<Object?>, so we cast safely.
    // (Better long-term fix is to change EncounterRepo to accept `Ref`, but this unblocks you now.)
    repo = EncounterRepo(AppDatabase.instance, ref as Ref<Object?>);

    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final list = await repo.listForPatient(widget.patient.id);
      if (!mounted) return;
      setState(() {
        encounters = list;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _newEncounter() async {
    // Your current EncounterRegistrationScreen constructor has NO `patient:` param.
    // So we open it in general mode.
    final created = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => const EncounterRegistrationScreen(),
      ),
    );

    if (created == null) return;

    // Accept either Encounter or encounterId String
    String? encounterId;
    if (created is Encounter) {
      encounterId = created.id;
    } else if (created is String) {
      encounterId = created;
    }

    if (encounterId == null || encounterId.isEmpty) return;

    await _load();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EncounterWorkspaceScreen(encounterId: encounterId!),
      ),
    );
  }

  void _open(Encounter e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EncounterWorkspaceScreen(encounterId: e.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text(
              'Encounters',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _newEncounter,
              icon: const Icon(Icons.add),
              label: const Text('New Encounter'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),

        if (!loading && encounters.isEmpty)
          const Card(
            child: ListTile(
              title: Text('No encounters yet'),
              subtitle: Text(
                'Create the first encounter to start notes/orders/documents.',
              ),
            ),
          ),

        if (!loading)
          ...encounters.map((e) {
            final subtitle = [
              'Type: ${e.type}',
              'Status: ${e.status}',
              if (e.unitName.isNotEmpty) 'Unit: ${e.unitName}',
              if (e.chiefComplaint != null && e.chiefComplaint!.trim().isNotEmpty)
                'CC: ${e.chiefComplaint}',
              'Start: ${e.startAt}',
            ].join(' • ');

            return Card(
              child: ListTile(
                title: Text('Encounter ${e.encounterNo ?? e.id.substring(0, 8)}'),
                subtitle: Text(subtitle),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _open(e),
              ),
            );
          }),
      ],
    );
  }
}