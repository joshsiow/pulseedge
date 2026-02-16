import 'dart:io';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart'; // Add this
import 'package:pulseedge_base/database/app_database.dart'; // Your DB file
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

final db = AppDatabase.instance; // Singleton access

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await db.init(); // Seeds demo data if empty
  await initLlm(); // Your existing LLM init
  runApp(PulseEdgeApp());
}

// Your existing initLlm() here (unchanged)

class PulseEdgeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulseEdge Base (Drift DB)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EncounterListScreen(),
    );
  }
}

class EncounterListScreen extends StatefulWidget {
  @override
  _EncounterListScreenState createState() => _EncounterListScreenState();
}

class _EncounterListScreenState extends State<EncounterListScreen> {
  List<Encounter> encounters = [];

  @override
  void initState() {
    super.initState();
    loadEncounters();
  }

  Future<void> loadEncounters() async {
    final results = await db.select(db.encounters).get();
    setState(() => encounters = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PulseEdge Encounters (Offline - Drift)')),
      body: encounters.isEmpty
          ? Center(child: Text('No encounters. Tap + to start. (Demo unit/user seeded)'))
          : ListView.builder(
              itemCount: encounters.length,
              itemBuilder: (context, index) {
                final enc = encounters[index];
                return ListTile(
                  title: Text('Patient ID: ${enc.patientId} - ${enc.createdAt}'),
                  subtitle: Text(enc.aiMetadata ?? 'Manual'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EncounterScreen(onSave: loadEncounters)),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}

class EncounterScreen extends StatefulWidget {
  final VoidCallback onSave;
  EncounterScreen({required this.onSave});

  @override
  _EncounterScreenState createState() => _EncounterScreenState();
}

class _EncounterScreenState extends State<EncounterScreen> {
  String patientId = 'demo-patient-1'; // In real: Search/create Patient first
  String history = '', exam = '', treatment = '';
  String aiMetadata = '';
  bool isListening = false;
  final stt.SpeechToText speech = stt.SpeechToText();

  // Your existing _startVoiceAndDraft / _generateDraft (LLM) here

  Future<void> saveEncounter() async {
    final now = DateTime.now();
    final encounterCompanion = EncountersCompanion.insert(
      patientId: patientId,
      status: 'open',
      startAt: now,
      createdAt: now,
      updatedAt: now,
      aiMetadata: Value(aiMetadata.isEmpty ? null : aiMetadata),
    );
    await db.into(db.encounters).insert(encounterCompanion);

    // Future: Insert Events for notes (history/exam/treatment as separate Events)
    widget.onSave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Offline Encounter')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Patient ID: $patientId (Future: Patient search/create)'),
            // Your TextFormFields + voice buttons + AI draft
            // ...
            ElevatedButton(onPressed: saveEncounter, child: Text('Save Offline (Drift)')),
          ],
        ),
      ),
    );
  }
}