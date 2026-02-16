import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class EncounterOrdersModule extends StatelessWidget {
  final Encounter encounter;
  final Patient patient;

  const EncounterOrdersModule({super.key, required this.encounter, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Card(
          child: ListTile(
            title: Text('Orders (CPOE) placeholder'),
            subtitle: Text('Next: create ORDER events (meds/labs/imaging/procedures) attached to encounter.'),
          ),
        ),
      ],
    );
  }
}