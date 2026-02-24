// lib/ui/setting/settings_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_service.dart';
import '../../core/session/session_context_store.dart';
import '../../core/database/app_database.dart';
import '../../core/ai/model_store.dart';
import 'package:pulseedge/core/ai/pulse_ai_providers.dart';

import '../../core/settings/ai_prefs.dart';
import 'package:pulseedge/core/ai/ai_backend_provider.dart';

/// Local provider for ModelStore
final modelStoreProvider = Provider<ModelStore>((ref) {
  final store = ModelStore(
    modelFileName: 'Llama-3.2-3B-Instruct-Q4_K_M.gguf',
  );
  ref.onDispose(store.dispose);
  return store;
});

/// Persisted URL key
const _kCustomModelUrlKey = 'custom_model_download_url';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _modelBusy = false;
  double? _modelProgress;
  String? _modelError;

  late Future<List<Object?>> _modelInfoFuture;
  bool _showGroqKey = true; // ✅ default: show while typing; you can hide later

  // URL editing
  late TextEditingController _urlController;
  final _urlFocus = FocusNode();
  bool _urlEditing = false;

  static const _defaultDevUrl =
      'http://127.0.0.1:8000/Llama-3.2-3B-Instruct-Q4_K_M.gguf';

  // Groq key
  final _groqKeyController = TextEditingController();
  bool _savingGroqKey = false;
  bool _groqKeyLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
    _loadGroqKey();
    _modelInfoFuture = _loadModelInfo();
  }

  Future<List<Object?>> _loadModelInfo() async {
    final store = ref.read(modelStoreProvider);
    return Future.wait([
      store.modelPath(),
      store.isModelReady(),
      store.modelSizeBytes(),
    ]);
  }

  @override
  void dispose() {
    _groqKeyController.dispose();
    _urlFocus.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kCustomModelUrlKey);
    if (!mounted) return;
    _urlController = TextEditingController(text: saved ?? _defaultDevUrl);
    setState(() {});
  }

  Future<void> _loadGroqKey() async {
    final key = await AiPrefs().readGroqApiKey();
    if (!mounted) return;
    _groqKeyController.text = key ?? '';
    setState(() => _groqKeyLoaded = true);
  }

  Future<void> _saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url == _defaultDevUrl) {
      await prefs.remove(_kCustomModelUrlKey);
    } else {
      await prefs.setString(_kCustomModelUrlKey, url);
    }
  }

  void _refreshModelStatus() {
    if (!mounted) return;
    setState(() {
      _modelInfoFuture = _loadModelInfo();
    });
  }

  Future<void> _downloadOrVerifyModel() async {
    final messenger = ScaffoldMessenger.of(context);
    final store = ref.read(modelStoreProvider);

    final url = _urlController.text.trim();
    if (url.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL')),
      );
      return;
    }

    setState(() {
      _modelBusy = true;
      _modelError = null;
      _modelProgress = null;
    });

    try {
      final path = await _downloadWithProgress(url, store.modelFileName);

      // Apply iOS do-not-backup (optional; your channel must exist)
      if (Platform.isIOS) {
        const channel = MethodChannel('com.yourapp/modelmanager');
        try {
          await channel.invokeMethod('setDoNotBackup', {'path': path});
        } catch (_) {
          // ignore on iOS if you haven't implemented the native side yet
        }
      }

      messenger.showSnackBar(
        SnackBar(content: Text('Offline AI model ready: $path')),
      );

      // local model became available, backend wiring might change
      AiBackendProvider.invalidate();
      ref.invalidate(aiBackendProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _modelError = e.toString());
      messenger.showSnackBar(
        SnackBar(content: Text('Model setup failed: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _modelBusy = false;
        _modelProgress = null;
      });
      _refreshModelStatus();
    }
  }

  /// Safe download - saves to 'models/' subfolder
  Future<String> _downloadWithProgress(String url, String fileName) async {
    final dir = await getApplicationSupportDirectory();
    final modelsDir = Directory(p.join(dir.path, 'models'));
    await modelsDir.create(recursive: true);

    final path = p.join(modelsDir.path, fileName);
    final file = File(path);

    // HEAD for total size (best effort)
    int totalBytes = 0;
    try {
      final headClient = HttpClient();
      final headRequest = await headClient.headUrl(Uri.parse(url));
      final headResponse = await headRequest.close();
      final totalStr = headResponse.headers.value('content-length');
      totalBytes = totalStr != null ? int.tryParse(totalStr) ?? 0 : 0;
      headClient.close();
    } catch (_) {
      totalBytes = 0;
    }

    // If existing and size matches, skip
    if (await file.exists()) {
      final currentSize = await file.length();
      if (totalBytes > 0 && currentSize == totalBytes) {
        return path;
      }
      await file.delete();
    }

    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok &&
        response.statusCode != HttpStatus.partialContent) {
      client.close();
      throw Exception('HTTP ${response.statusCode}');
    }

    final sink = await file.open(mode: FileMode.write);
    var received = 0;

    await for (final chunk in response) {
      await sink.writeFrom(chunk);
      received += chunk.length;

      final progress = totalBytes > 0 ? received / totalBytes : null;
      if (mounted) setState(() => _modelProgress = progress);
    }

    await sink.close();
    client.close();

    final finalSize = await file.length();
    if (totalBytes > 0 && finalSize != totalBytes) {
      throw Exception('Download incomplete: $finalSize / $totalBytes bytes');
    }

    return path;
  }

  Future<void> _deleteModel() async {
    final messenger = ScaffoldMessenger.of(context);
    final store = ref.read(modelStoreProvider);

    setState(() {
      _modelBusy = true;
      _modelError = null;
      _modelProgress = null;
    });

    try {
      await store.deleteModelIfExists();
      messenger.showSnackBar(
        const SnackBar(content: Text('Offline AI model deleted')),
      );

      AiBackendProvider.invalidate();
      ref.invalidate(aiBackendProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _modelError = e.toString());
      messenger.showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _modelBusy = false;
        _modelProgress = null;
      });
      _refreshModelStatus();
    }
  }

  Future<void> _saveGroqKey() async {
    final messenger = ScaffoldMessenger.of(context);
    final key = _groqKeyController.text.trim();

    if (key.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('API key cannot be empty')),
      );
      return;
    }

    setState(() => _savingGroqKey = true);
    try {
      await AiPrefs().setGroqApiKey(key);
      AiBackendProvider.invalidate();
      ref.invalidate(aiBackendProvider);

      messenger.showSnackBar(
        const SnackBar(content: Text('Groq API key saved')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingGroqKey = false);
    }
  }

  Future<void> _clearGroqKey() async {
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _savingGroqKey = true);
    try {
      await AiPrefs().setGroqApiKey(null);
      AiBackendProvider.invalidate();
      ref.invalidate(aiBackendProvider);

      _groqKeyController.clear();
      messenger.showSnackBar(
        const SnackBar(content: Text('Groq API key cleared')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Clear failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingGroqKey = false);
    }
  }

  Future<void> _testGroqOrBackend() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() => _savingGroqKey = true);
    try {
      // ensure new key is picked up
      AiBackendProvider.invalidate();
      ref.invalidate(aiBackendProvider);

      final backend = await ref.read(aiBackendProvider.future);

      final buf = StringBuffer();
      await for (final c in backend.draftNote(
        transcript: 'Patient with 2 days fever and mild cough.',
        patientContext: 'Adult male, no known allergies.',
      )) {
        buf.write(c);
      }

      if (!mounted) return;
      final out = buf.toString().trim();
      showDialog(
        context: nav.context,
        builder: (_) => AlertDialog(
          title: const Text('Groq / Backend Test Result'),
          content: SingleChildScrollView(
            child: Text(out.isEmpty ? '(No output)' : out),
          ),
          actions: [
            TextButton(
              onPressed: () => nav.pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Test failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingGroqKey = false);
    }
  }

  Future<void> _testLocalToolChat() async {
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _modelBusy = true);
    try {
      final ai = ref.read(aiServiceProvider);
      final resp = await ai.runRawPrompt(
        'Say "Hello from PulseEdge!" in Bahasa Malaysia.',
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('AI Response: ${resp.answer.trim()}'),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Test failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _modelBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    final sessionStore = ref.watch(sessionContextStoreProvider);
    final store = ref.watch(modelStoreProvider);

    //final hasGroqKey = _groqKeyController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User
          _Section(
            title: 'User',
            children: [
              _KeyValueTile(
                label: 'Username',
                value: auth.currentUser?.username ?? 'Unknown',
              ),
              _KeyValueTile(
                label: 'Role',
                value: auth.currentUser?.role ?? '—',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Active Session
          _Section(
            title: 'Active Session',
            children: [
              FutureBuilder(
                future: sessionStore.getActive(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: LinearProgressIndicator(),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        snap.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final session = snap.data;
                  if (session == null) {
                    return const ListTile(
                      leading: Icon(Icons.warning_amber),
                      title: Text('No active session'),
                      subtitle: Text('Start a session to begin work'),
                    );
                  }

                  return Column(
                    children: [
                      _KeyValueTile(label: 'Unit', value: session.unitName),
                      _KeyValueTile(
                        label: 'Started at',
                        value: _fmt(session.startedAt),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('Switch unit'),
                        onPressed: () async {
                          await sessionStore.clear();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Offline AI
          _Section(
            title: 'Offline AI',
            children: [
              FutureBuilder(
                future: Future.wait([
                  store.modelPath(),
                  store.isModelReady(),
                  store.modelSizeBytes(),
                ]),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting ||
                      !_groqKeyLoaded) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: LinearProgressIndicator(),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        snap.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final data = snap.data!;
                  final path = data[0] as String;
                  final ready = data[1] as bool;
                  final sizeBytes = data[2] as int?;
                  final sizeLabel =
                      sizeBytes == null ? '—' : _fmtBytes(sizeBytes);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Groq field
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                        child: TextField(
                          controller: _groqKeyController,
                          //obscureText: true,
                          obscureText: !_showGroqKey, // allow showing temporarily
                          keyboardType: TextInputType.visiblePassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          enabled: !_savingGroqKey,
                          onChanged: (_) {
                          // only rebuild icons; safe now because it's NOT inside FutureBuilder
                            if (mounted) setState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: 'Groq API Key (cloud fallback)',
                            hintText: 'gsk_...',
                            suffixIconConstraints: const BoxConstraints(minWidth: 160),
                            suffixIcon: _savingGroqKey
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: _showGroqKey ? 'Hide' : 'Show',
                                        icon: Icon(_showGroqKey ? Icons.visibility_off : Icons.visibility),
                                        onPressed: () => setState(() => _showGroqKey = !_showGroqKey),
                                      ),
                                      IconButton(
                                        tooltip: 'Save',
                                        icon: const Icon(Icons.save),
                                        onPressed: _saveGroqKey,
                                      ),
                                      if (_groqKeyController.text.trim().isNotEmpty)
                                        IconButton(
                                          tooltip: 'Test Groq',
                                          icon: const Icon(Icons.cloud_outlined),
                                          onPressed: () async {
                                            // ensure persisted first
                                            await _saveGroqKey();

                                            final nav = Navigator.of(context);
                                            final messenger = ScaffoldMessenger.of(context);

                                            setState(() => _savingGroqKey = true);
                                            try {
                                              final groq = ref.read(groqBackendProvider); // groq-only
                                              final buf = StringBuffer();

                                              await for (final chunk in groq.draftNote(
                                                transcript: '''
                                                Patient reports 2 days fever and mild cough.
                                                No chest pain, no shortness of breath.
                                                No known medical problems. No medications.
                                                No known drug allergies.
                                                ''',
                                                patientContext: 'Adult male.',
                                              )) {
                                                buf.write(chunk);
                                              }

                                              if (!mounted) return;
                                              final out = buf.toString().trim();
                                              showDialog(
                                                context: nav.context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text('Groq Test Result'),
                                                  content: SingleChildScrollView(
                                                    child: Text(out.isEmpty ? '(No output)' : out),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => nav.pop(),
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              messenger.showSnackBar(
                                                SnackBar(
                                                  content: Text('Groq test failed: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } finally {
                                              if (mounted) setState(() => _savingGroqKey = false);
                                            }
                                          },
                                        ),
                                      if (_groqKeyController.text.trim().isNotEmpty)
                                        IconButton(
                                          tooltip: 'Clear',
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: _clearGroqKey,
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      ListTile(
                        leading: Icon(
                          ready ? Icons.check_circle : Icons.cloud_download,
                          color: ready ? Colors.green : Colors.orange,
                        ),
                        title: Text(ready ? 'Model installed' : 'Model not installed'),
                        subtitle: Text(
                          'File: ${store.modelFileName}\n'
                          'Size: $sizeLabel\n'
                          'Path: $path',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                      ),

                      // URL field
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: TextField(
                          controller: _urlController,
                          focusNode: _urlFocus,
                          enabled: !_modelBusy,
                          decoration: InputDecoration(
                            labelText: 'Download URL',
                            hintText: _defaultDevUrl,
                            suffixIcon: _urlEditing
                                ? IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () {
                                      _saveUrl(_urlController.text.trim());
                                      _urlFocus.unfocus();
                                      setState(() => _urlEditing = false);
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => setState(() => _urlEditing = true),
                                  ),
                          ),
                          onSubmitted: (v) {
                            _saveUrl(v.trim());
                            setState(() => _urlEditing = false);
                          },
                        ),
                      ),

                      if (_modelError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                          child: Text(
                            _modelError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      if (_modelBusy && _modelProgress != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              LinearProgressIndicator(value: _modelProgress),
                              const SizedBox(height: 6),
                              Text(
                                'Downloading… ${(_modelProgress! * 100).toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  _modelBusy ? null : _downloadOrVerifyModel,
                              icon: Icon(ready ? Icons.verified : Icons.download),
                              label: Text(
                                ready ? 'Re-download / Repair' : 'Install from URL',
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _modelBusy ? null : _deleteModel,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _modelBusy ? null : _refreshModelStatus,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ),

                      // One simple test button (tool path)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: ElevatedButton.icon(
                          onPressed: _modelBusy ? null : _testLocalToolChat,
                          icon: _modelBusy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.smart_toy),
                          label: Text(_modelBusy ? 'Testing...' : 'Test AI (Hello World)'),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Text(
                          'Dev note: Default URL points to local server (127.0.0.1:8000). '
                          'Change and save for production CDN. Model stored in app-private '
                          'Application Support directory.',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data & Sync
          _Section(
            title: 'Data & Sync',
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Local database'),
                subtitle: const Text('Offline-first. Data stored on this device.'),
                trailing: OutlinedButton(
                  child: const Text('Stats'),
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final db = AppDatabase.instance;
                    final counts = await _dbStats(db);
                    if (!nav.context.mounted) return;

                    showDialog(
                      context: nav.context,
                      builder: (_) => AlertDialog(
                        title: const Text('Local data stats'),
                        content: Text(counts),
                        actions: [
                          TextButton(
                            onPressed: () => nav.pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync status'),
                subtitle: const Text('Background sync pending'),
                trailing: Chip(
                  label: const Text('Offline'),
                  backgroundColor: Colors.orangeAccent.withOpacity(0.15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const _Section(
            title: 'Security',
            children: [
              ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Access control'),
                subtitle: Text('Patient data is scoped by unit and encounter.'),
              ),
              ListTile(
                leading: Icon(Icons.visibility_off),
                title: Text('Privacy'),
                subtitle: Text('No browsing of patient records without an encounter.'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const _Section(
            title: 'About',
            children: [
              _KeyValueTile(label: 'App', value: 'PulseEdge'),
              _KeyValueTile(label: 'Mode', value: 'Offline-first'),
              _KeyValueTile(label: 'Build', value: 'Internal'),
            ],
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            onPressed: () {
              ref.read(authServiceProvider).logout();
              if (context.mounted) {
                Navigator.popUntil(context, (r) => r.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }

  static Future<String> _dbStats(AppDatabase db) async {
    final patients =
        await db.customSelect('SELECT COUNT(*) AS c FROM patients').getSingle();
    final encounters = await db
        .customSelect('SELECT COUNT(*) AS c FROM encounters')
        .getSingle();
    final events =
        await db.customSelect('SELECT COUNT(*) AS c FROM events').getSingle();

    return '''
Patients: ${patients.data['c']}
Encounters: ${encounters.data['c']}
Events: ${events.data['c']}
''';
  }

  static String _fmt(DateTime d) {
    return '${d.day}/${d.month}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static String _fmtBytes(int bytes) {
    const kb = 1024;
    const mb = 1024 * kb;
    const gb = 1024 * mb;

    if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(2)} GB';
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}

// -----------------------------------------------------------------------------
// Small UI helpers
// -----------------------------------------------------------------------------
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _KeyValueTile extends StatelessWidget {
  const _KeyValueTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}