import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class PatientOverviewModule extends StatelessWidget {
  final Patient patient;
  const PatientOverviewModule({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),

        Card(
          child: ListTile(
            title: const Text('Patient Snapshot'),
            subtitle: Text(
              'Name: ${patient.fullName}\n'
              'Consent: ${patient.consentStatus}\n'
              'Allergies: ${(patient.allergies ?? "None")}',
            ),
          ),
        ),

        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text('Next: AI Patient Brief (coming)'),
            subtitle: Text(
              'We will generate a safe summary from existing records:\n'
              '• Key problems • Recent encounters • Meds • Allergies • Alerts',
            ),
          ),
        ),
      ],
    );
  }
}