import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class PatientDocumentsModule extends StatelessWidget {
  final Patient patient;
  const PatientDocumentsModule({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Documents', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text('Scans/PDFs placeholder'),
            subtitle: Text('Later: attach photo/PDF, OCR, AI summarise, sync queue.'),
          ),
        ),
      ],
    );
  }
}