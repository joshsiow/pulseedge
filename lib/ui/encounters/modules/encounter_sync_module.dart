import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class EncounterSyncModule extends StatelessWidget {
  final Encounter encounter;
  final Patient patient;

  const EncounterSyncModule({super.key, required this.encounter, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: ListTile(
            title: const Text('Sync status'),
            subtitle: Text('Encounter syncState: ${encounter.syncState} • synced: ${encounter.synced}'),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text('Audit trail next'),
            subtitle: Text('Everything becomes an Event row. Sync sends deltas + resolves conflicts at encounter scope.'),
          ),
        ),
      ],
    );
  }
}