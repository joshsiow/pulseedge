import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class PatientSyncAuditModule extends StatelessWidget {
  final Patient patient;
  const PatientSyncAuditModule({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Sync & Audit', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Sync queue (next)'),
            subtitle: Text(
              'Patient source: ${patient.source}\n'
              'We will log: created/edited events + sync status + conflicts.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text('Audit trail (next)'),
            subtitle: Text('Every action becomes an Event row for governance + sync.'),
          ),
        ),
      ],
    );
  }
}