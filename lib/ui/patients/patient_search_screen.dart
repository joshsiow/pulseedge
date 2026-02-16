import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/patients/patient_repo.dart';
import '../../core/auth/session_store.dart';
import 'patient_create_sheet.dart';
import '../workspace/patient_workspace_screen.dart';

class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final _q = TextEditingController();
  Timer? _debounce;
  bool _busy = false;
  List<Patient> _results = [];

  late final PatientRepo repo;

  @override
  void initState() {
    super.initState();
    repo = PatientRepo(AppDatabase.instance);
    _q.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final text = _q.text.trim();
      if (text.isEmpty) {
        setState(() => _results = []);
        return;
      }
      setState(() => _busy = true);
      final r = await repo.searchPatients(text);
      if (!mounted) return;
      setState(() {
        _results = r;
        _busy = false;
      });
    });
  }

  Future<void> _createNew() async {
    final initial = _q.text.trim();

    final created = await showModalBottomSheet<Patient>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PatientCreateSheet(
        initialQuery: initial,
        repo: repo,
      ),
    );

    if (created != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created patient: ${created.fullName}')),
      );
      setState(() {
        _q.text = created.fullName;
        _results = [created];
      });
    }
  }

  void _selectPatient(Patient p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientWorkspaceScreen(patientId: p.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.username ?? 'Unknown';
    final unit = SessionStore.unitName ?? 'No Unit';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('User: $user • Unit: $unit',
                  style: const TextStyle(color: Colors.white70)),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _q,
              decoration: InputDecoration(
                labelText: 'Search by MRN / Name / NRIC',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _q.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _q.clear();
                          setState(() => _results = []);
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: _results.isEmpty
                  ? _EmptyState(onCreate: _createNew)
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final p = _results[i];
                        return Card(
                          child: ListTile(
                            title: Text(p.fullName),
                            subtitle: Text([
                              if (p.mrn != null) 'MRN: ${p.mrn}',
                              'NRIC: ${_maskNric(p.nric)}',
                              'Consent: ${p.consentStatus}',
                              'Source: ${p.source}',
                            ].join(' • ')),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _selectPatient(p),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNew,
        icon: const Icon(Icons.person_add),
        label: const Text('Create New'),
      ),
    );
  }

  String _maskNric(String nric) {
    // Mask display for safety: show last 4
    if (nric.length <= 4) return '****';
    final last = nric.substring(nric.length - 4);
    return '****$last';
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search, size: 64, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'No matching patients found.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a new patient from here (standard clinical workflow).',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.person_add),
              label: const Text('Create New Patient'),
            )
          ],
        ),
      ),
    );
  }
}