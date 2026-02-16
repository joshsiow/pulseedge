import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';

class PatientDemographicsModule extends StatefulWidget {
  final Patient patient;
  final Future<void> Function() onUpdated;

  const PatientDemographicsModule({
    super.key,
    required this.patient,
    required this.onUpdated,
  });

  @override
  State<PatientDemographicsModule> createState() => _PatientDemographicsModuleState();
}

class _PatientDemographicsModuleState extends State<PatientDemographicsModule> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _mrn;
  late final TextEditingController _nric;
  late final TextEditingController _address;
  late final TextEditingController _allergies;

  String _consent = 'unknown';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _name = TextEditingController(text: p.fullName);
    _mrn = TextEditingController(text: p.mrn ?? '');
    _nric = TextEditingController(text: p.nric);
    _address = TextEditingController(text: p.address ?? '');
    _allergies = TextEditingController(text: p.allergies ?? '');
    _consent = p.consentStatus;
  }

  @override
  void dispose() {
    _name.dispose();
    _mrn.dispose();
    _nric.dispose();
    _address.dispose();
    _allergies.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);

    final db = AppDatabase.instance;

    // Keep normalization simple for now; full normalization/hashing stays in repo when creating.
    final fullName = _name.text.trim();
    final fullNameNorm = fullName.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    final nric = _nric.text.trim().replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase();

    await (db.update(db.patients)..where((t) => t.id.equals(widget.patient.id))).write(
      PatientsCompanion(
        fullName: drift.Value(fullName),
        fullNameNorm: drift.Value(fullNameNorm),
        mrn: _mrn.text.trim().isEmpty ? const drift.Value.absent() : drift.Value(_mrn.text.trim()),
        nric: drift.Value(nric),
        address: _address.text.trim().isEmpty ? const drift.Value.absent() : drift.Value(_address.text.trim()),
        allergies: _allergies.text.trim().isEmpty ? const drift.Value.absent() : drift.Value(_allergies.text.trim()),
        consentStatus: drift.Value(_consent),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    setState(() => _busy = false);

    await widget.onUpdated();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient updated')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Demographics', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Full Name *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _nric,
                    decoration: const InputDecoration(labelText: 'NRIC *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _mrn,
                    decoration: const InputDecoration(labelText: 'MRN (optional)'),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: _consent,
                    decoration: const InputDecoration(labelText: 'Consent'),
                    items: const [
                      DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'consented', child: Text('Consented')),
                      DropdownMenuItem(value: 'declined', child: Text('Declined')),
                    ],
                    onChanged: (v) => setState(() => _consent = v ?? 'unknown'),
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _address,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _allergies,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Allergies'),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _save,
                      child: Text(_busy ? 'Saving...' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}