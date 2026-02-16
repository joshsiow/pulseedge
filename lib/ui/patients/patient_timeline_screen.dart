// lib/ui/patients/patient_timeline_screen.dart
import 'dart:convert';

import 'package:drift/drift.dart' show QueryRow, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';

class PatientTimelineScreen extends ConsumerStatefulWidget {
  const PatientTimelineScreen({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  ConsumerState<PatientTimelineScreen> createState() =>
      _PatientTimelineScreenState();
}

class _PatientTimelineScreenState extends ConsumerState<PatientTimelineScreen> {
  bool _loading = true;
  String? _error;

  Patient? _patient;
  List<_TimelineRow> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _rows = const [];
    });

    try {
      final db = AppDatabase.instance;

      final patient = await (db.select(db.patients)
            ..where((p) => p.id.equals(widget.patientId))
            ..limit(1))
          .getSingleOrNull();

      if (patient == null) {
        throw Exception('Patient not found');
      }

      // Events are encounter-scoped → join encounters to filter by patient.
      //
      // IMPORTANT:
      // These SQL column names assume drift default snake_case mapping:
      // encounters.patient_id, events.encounter_id, etc.
      // If yours differ, change the SQL aliases only; the UI stays the same.
      final result = await db.customSelect(
        '''
        SELECT
          ev.id AS eventId,
          ev.encounter_id AS encounterId,
          ev.kind AS kind,
          ev.title AS title,
          ev.status AS status,
          ev.body_text AS bodyText,
          ev.payload_json AS payloadJson,
          ev.created_by AS createdBy,
          ev.created_at AS createdAt,
          ev.signed_by AS signedBy,
          ev.signed_at AS signedAt,

          en.start_at AS encounterStartAt,
          en.end_at AS encounterEndAt,
          en.unit_name AS unitName,
          en.provider_name AS providerName
        FROM events ev
        JOIN encounters en ON en.id = ev.encounter_id
        WHERE en.patient_id = ?1
        ORDER BY ev.created_at DESC
        LIMIT 500
        ''',
        variables: [Variable.withString(widget.patientId)],
        readsFrom: {db.events, db.encounters},
      ).get();

      final rows = result.map(_TimelineRow.fromRow).toList();

      if (!mounted) return;
      setState(() {
        _patient = patient;
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Timeline')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final patient = _patient!;
    final grouped = _groupByDate(_rows);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          _PatientHeader(patient: patient),
          const SizedBox(height: 12),
          if (_rows.isEmpty)
            const _EmptyState()
          else
            ...grouped.entries.map((entry) {
              final dateLabel = entry.key;
              final items = entry.value;

              return _DateSection(
                dateLabel: dateLabel,
                children: items
                    .map((row) => _TimelineEventCard(row: row))
                    .toList(),
              );
            }),
        ],
      ),
    );
  }

  Map<String, List<_TimelineRow>> _groupByDate(List<_TimelineRow> rows) {
    final map = <String, List<_TimelineRow>>{};
    for (final r in rows) {
      final d = r.createdAt;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => <_TimelineRow>[]).add(r);
    }
    return map;
  }
}

// -----------------------------------------------------------------------------
// Model
// -----------------------------------------------------------------------------
class _TimelineRow {
  _TimelineRow({
    required this.eventId,
    required this.encounterId,
    required this.kind,
    required this.title,
    required this.status,
    required this.bodyText,
    required this.payloadJson,
    required this.createdBy,
    required this.createdAt,
    required this.signedBy,
    required this.signedAt,
    required this.encounterStartAt,
    required this.encounterEndAt,
    required this.unitName,
    required this.providerName,
  });

  final String eventId;
  final String encounterId;
  final String kind;
  final String title;
  final String status;
  final String? bodyText;
  final String? payloadJson;
  final String? createdBy;
  final DateTime createdAt;
  final String? signedBy;
  final DateTime? signedAt;

  final DateTime encounterStartAt;
  final DateTime? encounterEndAt;
  final String? unitName;
  final String? providerName;

  Map<String, Object?> payloadAsMap() {
    final s = payloadJson;
    if (s == null || s.trim().isEmpty) return const {};
    try {
      final obj = jsonDecode(s);
      if (obj is Map<String, dynamic>) return obj;
      return {'_': obj};
    } catch (_) {
      return const {};
    }
  }

  static _TimelineRow fromRow(QueryRow r) {
    final data = r.data;

    DateTime _requireDate(String k) {
      final v = data[k];
      if (v is DateTime) return v;
      return DateTime.tryParse('$v') ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? _optDate(String k) {
      final v = data[k];
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse('$v');
    }

    String _reqStr(String k) => (data[k] as String?) ?? '';

    return _TimelineRow(
      eventId: _reqStr('eventId'),
      encounterId: _reqStr('encounterId'),
      kind: _reqStr('kind'),
      title: _reqStr('title'),
      status: _reqStr('status'),
      bodyText: data['bodyText'] as String?,
      payloadJson: data['payloadJson'] as String?,
      createdBy: data['createdBy'] as String?,
      createdAt: _requireDate('createdAt'),
      signedBy: data['signedBy'] as String?,
      signedAt: _optDate('signedAt'),
      encounterStartAt: _requireDate('encounterStartAt'),
      encounterEndAt: _optDate('encounterEndAt'),
      unitName: data['unitName'] as String?,
      providerName: data['providerName'] as String?,
    );
  }
}

// -----------------------------------------------------------------------------
// UI
// -----------------------------------------------------------------------------
class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final name = patient.fullName.trim().isEmpty
        ? '(Unnamed patient)'
        : patient.fullName.trim();

    final nricMasked = patient.nric.trim().isEmpty ? '—' : _maskId(patient.nric);

    final addr = patient.address?.trim() ?? '';
    final address = addr.isEmpty ? null : addr;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text('NRIC: $nricMasked'),
            if (address != null) ...[
              const SizedBox(height: 2),
              Text('Address: $address'),
            ],
          ],
        ),
      ),
    );
  }

  String _maskId(String id) {
    final s = id.trim();
    if (s.length <= 4) return s;
    return '****${s.substring(s.length - 4)}';
  }
}

class _DateSection extends StatelessWidget {
  const _DateSection({
    required this.dateLabel,
    required this.children,
  });

  final String dateLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              dateLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  const _TimelineEventCard({required this.row});

  final _TimelineRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final icon = _iconForKind(row.kind);
    final time = _hhmm(row.createdAt);
    final subtitle = _subtitleLine();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          row.title.trim().isEmpty ? row.kind : row.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: theme.textTheme.labelMedium,
        ),
        onTap: () => _openDetails(context),
      ),
    );
  }

  String _subtitleLine() {
    final unit = (row.unitName?.trim().isNotEmpty ?? false)
        ? row.unitName!.trim()
        : 'Unknown unit';

    final provider = (row.providerName?.trim().isNotEmpty ?? false)
        ? row.providerName!.trim()
        : 'Unknown provider';

    final kind = row.kind.trim().isEmpty ? '—' : row.kind.trim();
    final status = row.status.trim().isEmpty ? '—' : row.status.trim();

    return '$unit • $provider • $kind • $status';
  }

  void _openDetails(BuildContext context) {
    final payload = row.payloadAsMap();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  row.title.trim().isEmpty ? row.kind : row.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Kind: ${row.kind}'),
                Text('Status: ${row.status}'),
                Text('Created: ${row.createdAt}'),
                if (row.bodyText != null && row.bodyText!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Body',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(row.bodyText!),
                ],
                if (payload.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Payload (JSON)',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(const JsonEncoder.withIndent('  ').convert(payload)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconForKind(String kind) {
    switch (kind.toUpperCase()) {
      case 'NOTE':
        return Icons.note_alt;
      case 'ORDER':
        return Icons.medication;
      case 'VITALS':
        return Icons.monitor_heart;
      case 'DOC':
        return Icons.description;
      default:
        return Icons.event_note;
    }
  }

  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'No timeline events yet.\nOnce you create notes, vitals, orders, or intake updates, they will appear here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}