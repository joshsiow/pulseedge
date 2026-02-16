import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class EncounterDocumentsModule extends StatelessWidget {
  final Encounter encounter;
  final Patient patient;

  const EncounterDocumentsModule({super.key, required this.encounter, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Card(
          child: ListTile(
            title: Text('Documents placeholder'),
            subtitle: Text('Next: attach photo/PDF, OCR, store as DOC events, sync later.'),
          ),
        ),
      ],
    );
  }
}