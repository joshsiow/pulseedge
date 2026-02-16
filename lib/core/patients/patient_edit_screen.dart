import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';

class PatientEditScreen extends ConsumerStatefulWidget {
  const PatientEditScreen({super.key, required this.patientId});

  final String patientId;

  @override
  ConsumerState<PatientEditScreen> createState() =>
      _PatientEditScreenState();
}

class _PatientEditScreenState
    extends ConsumerState<PatientEditScreen> {
  final _nameCtrl = TextEditingController();
  final _nricCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = AppDatabase.instance;
      final p = await (db.select(db.patients)
            ..where((x) => x.id.equals(widget.patientId)))
          .getSingle();

      _nameCtrl.text = p.fullName;
      _nricCtrl.text = p.nric;
      _addressCtrl.text = p.address ?? '';

      setState(() => _loading = false);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _save() async {
    try {
      final db = AppDatabase.instance;
      await (db.update(db.patients)
            ..where((x) => x.id.equals(widget.patientId)))
          .write(
        PatientsCompanion(
          fullName: Value(_nameCtrl.text.trim()),
          nric: Value(_nricCtrl.text.trim()),
          address: Value(_addressCtrl.text.trim()),
          updatedAt: Value(DateTime.now()),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Registration')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Full name'),
                  ),
                  TextField(
                    controller: _nricCtrl,
                    decoration:
                        const InputDecoration(labelText: 'NRIC'),
                  ),
                  TextField(
                    controller: _addressCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Address'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}