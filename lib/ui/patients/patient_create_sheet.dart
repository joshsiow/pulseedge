import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/patients/patient_repo.dart';

class PatientCreateSheet extends StatefulWidget {
  final String initialQuery;
  final PatientRepo repo;

  const PatientCreateSheet({super.key, required this.initialQuery, required this.repo});

  @override
  State<PatientCreateSheet> createState() => _PatientCreateSheetState();
}

class _PatientCreateSheetState extends State<PatientCreateSheet> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _nric = TextEditingController();
  final _mrn = TextEditingController();
  final _address = TextEditingController();
  final _allergies = TextEditingController();

  String _consent = 'unknown';
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Prefill intelligently based on what user typed
    final q = widget.initialQuery.trim();
    if (PatientRepo.looksLikeNric(q)) {
      _nric.text = q;
    } else if (PatientRepo.looksLikeMrn(q)) {
      _mrn.text = q;
    } else if (q.isNotEmpty) {
      _name.text = q;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _nric.dispose();
    _mrn.dispose();
    _address.dispose();
    _allergies.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (!_formKey.currentState!.validate()) return;

      final created = await widget.repo.createPatient(
        mrn: _mrn.text.trim().isEmpty ? null : _mrn.text.trim(),
        fullName: _name.text,
        nricRaw: _nric.text,
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        allergies: _allergies.text.trim().isEmpty ? null : _allergies.text.trim(),
        consentStatus: _consent,
        source: 'local',
      );

      if (!mounted) return;
      Navigator.pop<Patient>(context, created);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottom + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create New Patient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _nric,
                decoration: const InputDecoration(labelText: 'NRIC * (no spaces/dashes ok)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'NRIC is required' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _mrn,
                decoration: const InputDecoration(labelText: 'MRN (if available)'),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _consent,
                items: const [
                  DropdownMenuItem(value: 'unknown', child: Text('Consent: Unknown')),
                  DropdownMenuItem(value: 'pending', child: Text('Consent: Pending')),
                  DropdownMenuItem(value: 'consented', child: Text('Consent: Consented')),
                  DropdownMenuItem(value: 'declined', child: Text('Consent: Declined')),
                ],
                onChanged: (v) => setState(() => _consent = v ?? 'unknown'),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _allergies,
                decoration: const InputDecoration(labelText: 'Allergies (free text)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _save,
                  child: Text(_busy ? 'Saving...' : 'Save Patient'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}