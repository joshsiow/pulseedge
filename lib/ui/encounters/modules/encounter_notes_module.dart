// lib/ui/encounters/modules/encounter_notes_module.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/database/app_database.dart';
import '../../../core/encounters/encounter_repo.dart';
//import '../../../core/ai/ai_service.dart';
import '../../../theme/app_theme.dart';
import '../../../core/ai/pulse_ai_providers.dart';

class EncounterNotesModule extends ConsumerStatefulWidget {
  final Encounter encounter;
  final Patient patient;

  const EncounterNotesModule({
    super.key,
    required this.encounter,
    required this.patient,
  });

  @override
  ConsumerState<EncounterNotesModule> createState() => _EncounterNotesModuleState();
}

class _EncounterNotesModuleState extends ConsumerState<EncounterNotesModule> {
  late final EncounterRepo _repo;
  List<Event> _notes = [];
  bool _loading = true;

  // Voice dictation
  final SpeechToText _speech = SpeechToText();
  bool _speechEnabled = false;
  String _transcript = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _repo = EncounterRepo(AppDatabase.instance, ref as Ref<Object?>);
    _initSpeech();
    _loadNotes();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    _notes = await _repo.listEvents(widget.encounter.id, kind: 'NOTE');
    setState(() => _loading = false);
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speech.listen(
        onResult: (result) {
          setState(() => _transcript = result.recognizedWords);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
      );
      setState(() => _isListening = true);
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _newNote() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _NewNoteDialog(
        patient: widget.patient,
        initialTranscript: _transcript,
        onSave: (title, body, isAIDrafted) async {
          await _repo.createNoteEvent(
            encounterId: widget.encounter.id,
            title: title,
            body: body + (isAIDrafted ? "\n\n---\nAI-assisted draft (clinician reviewed)" : ""),
          );
          await _loadNotes();
        },
      ),
    );

    if (result != null) {
      setState(() => _transcript = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppTheme.surface,
            child: ListTile(
              leading: const Icon(Icons.person, color: AppTheme.primary, size: 40),
              title: Text(
                widget.patient.fullName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.darkPrimary),
              ),
              subtitle: Text(
                'Encounter: ${widget.encounter.type} • ${widget.encounter.status} • ${widget.encounter.unitName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Text('Clinical Notes', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.darkPrimary)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _newNote,
                icon: const Icon(Icons.note_add),
                label: const Text('New Note'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_speechEnabled)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(_isListening ? Icons.mic : Icons.mic_off, color: _isListening ? AppTheme.primary : Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isListening ? 'Listening... speak clearly' : 'Tap mic to dictate',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: _isListening ? _stopListening : _startListening,
                          icon: Icon(_isListening ? Icons.stop : Icons.mic, size: 32),
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                    if (_transcript.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _transcript,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_notes.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline, color: AppTheme.secondary),
                title:  Text('No notes yet'),
                subtitle: Text('Start with voice dictation or manual entry. AI can assist drafting SOAP notes.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  final hasAI = note.bodyText?.contains('AI-assisted') ?? false;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: hasAI ? const Icon(Icons.smart_toy, color: AppTheme.primary) : const Icon(Icons.note, color: AppTheme.secondary),
                      title: Text(note.title, style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(
                        note.bodyText ?? '(empty)',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        note.createdAt.toLocal().toString().substring(0, 16),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NewNoteDialog extends ConsumerStatefulWidget {
  final Patient patient;
  final String initialTranscript;
  final Future<void> Function(String title, String body, bool isAIDrafted) onSave;

  const _NewNoteDialog({
    required this.patient,
    required this.initialTranscript,
    required this.onSave,
  });

  @override
  ConsumerState<_NewNoteDialog> createState() => _NewNoteDialogState();
}

class _NewNoteDialogState extends ConsumerState<_NewNoteDialog> {
  final _titleController = TextEditingController(text: 'SOAP Note');
  final _bodyController = TextEditingController();
  bool _busy = false;
  bool _generatingAI = false;
  String _aiStatus = '';

  @override
  void initState() {
    super.initState();
    _bodyController.text = widget.initialTranscript;
  }

  Future<void> _generateAIDraft() async {
    final ai = ref.read(aiServiceProvider);
    setState(() {
      _generatingAI = true;
      _aiStatus = 'Generating draft...';
    });

    String draft = '';
    await for (var token in ai.draftNote(
      transcript: _bodyController.text,
      // FIXED: Use only known Patient fields (fullName exists from original code)
      // Extend Patient model later for age/DOB/allergies if needed
      patientContext: 'Patient: ${widget.patient.fullName}',
    )) {
      setState(() {
        draft += token;
        _bodyController.text = draft;
        _bodyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _bodyController.text.length),
        );
        _aiStatus = 'Streaming...';
      });
    }

    setState(() {
      _generatingAI = false;
      _aiStatus = 'AI draft complete — review & edit';
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final isAIDrafted = _bodyController.text.contains('AI-assisted');
    await widget.onSave(_titleController.text.trim(), _bodyController.text.trim(), isAIDrafted);
    if (mounted) Navigator.pop(context, 'saved');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Clinical Note', style: TextStyle(color: AppTheme.darkPrimary)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                maxLines: 12,
                decoration: InputDecoration(
                  labelText: 'Note Body (SOAP format recommended)',
                  hintText: 'Subjective...\nObjective...\nAssessment...\nPlan...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              if (_generatingAI || _aiStatus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(_aiStatus, style: const TextStyle(color: AppTheme.primary)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _generatingAI ? null : _generateAIDraft,
              icon: const Icon(Icons.smart_toy),
              label: Text(_generatingAI ? 'Generating...' : 'AI Draft'),
            ),
            const Spacer(),
            TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save Note'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}