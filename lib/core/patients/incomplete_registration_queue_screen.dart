import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/patients/patient_encounter_service.dart';
import 'patient_edit_screen.dart';

class IncompleteRegistrationQueueScreen
    extends ConsumerStatefulWidget {
  const IncompleteRegistrationQueueScreen({super.key});

  @override
  ConsumerState<IncompleteRegistrationQueueScreen> createState() =>
      _IncompleteRegistrationQueueScreenState();
}

class _IncompleteRegistrationQueueScreenState
    extends ConsumerState<IncompleteRegistrationQueueScreen> {
  bool _loading = true;
  String? _error;
  List<PatientSearchHit> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final svc = ref.read(patientEncounterServiceProvider);
      final list = await svc.listIncompletePatients();
      setState(() => _items = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incomplete Registrations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? const Center(
                      child: Text('No incomplete registrations 🎉'),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final p = _items[i];
                        return ListTile(
                          leading: const Icon(Icons.warning_amber,
                              color: Colors.orange),
                          title: Text(p.fullName),
                          subtitle: Text(
                            '${p.nricMasked}'
                            '${p.lastSeenAt != null ? ' • Last seen ${_fmt(p.lastSeenAt!)}' : ''}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PatientEditScreen(patientId: p.patientId),
                              ),
                            ).then((_) => _load());
                          },
                        );
                      },
                    ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}