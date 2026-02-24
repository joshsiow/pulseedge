// lib/core/ai/backends/local_ai_backend.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fllama/fllama.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'ai_backend.dart';

class LocalAiBackend implements AiBackend {
  Fllama? _llama;
  double? _contextId;

  bool _loading = false;

  /// For HybridAiBackend convenience
  bool get isReady => _contextId != null;
  bool get isLoaded => _contextId != null;
/*
  bool get _isSimulator {
    // These env vars exist for simulator-hosted processes most of the time.
    // If they’re missing, we *still* behave normally.
    final env = Platform.environment;
    return Platform.isIOS &&
        (env.containsKey('SIMULATOR_DEVICE_NAME') ||
            env.containsKey('SIMULATOR_MODEL_IDENTIFIER') ||
            env.containsKey('SIMULATOR_RUNTIME_VERSION'));
  }*/
  bool _isSimulator() {
    // Reliable: set on iOS Simulator
    return Platform.isIOS && Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
  }
  // ---------------------------------------------------------------------------
  // AiBackend API
  // ---------------------------------------------------------------------------

  @override
  Future<String> generate(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
  }) async {
    await _ensureLoaded();

    final buffer = StringBuffer();

    StreamSubscription? sub;
    try {
      sub = _llama!.onTokenStream?.listen((event) {
        // event is already Map<Object?, dynamic>
        final fn = event['function']?.toString();
        final result = event['result'];

        if (fn == 'completion' && result is Map) {
          final token = result['token']?.toString() ?? '';
          if (token.isNotEmpty) buffer.write(token);
        }
      });

      await _llama!.completion(
        _contextId!,
        prompt: prompt,
        emitRealtimeCompletion: true,
      );
    } finally {
      await sub?.cancel();
    }

    return buffer.toString().trim();
  }

  @override
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  }) async* {
    await _ensureLoaded();

    final prompt = _buildPrompt(transcript, patientContext);

    final controller = StreamController<String>();

    StreamSubscription? sub;
    try {
      sub = _llama!.onTokenStream?.listen((event) {
        final fn = event['function']?.toString();
        final result = event['result'];

        if (fn == 'completion' && result is Map) {
          final token = result['token']?.toString() ?? '';
          if (token.isNotEmpty && !controller.isClosed) {
            controller.add(token);
          }
        }
      });

      // Run completion, while UI listens to controller.stream
      final completionFuture = _llama!.completion(
        _contextId!,
        prompt: prompt,
        emitRealtimeCompletion: true,
      );

      // Yield tokens as they come
      yield* controller.stream;

      // Ensure completion finishes (in practice yield* will end after close)
      await completionFuture;
    } finally {
      await sub?.cancel();
      if (!controller.isClosed) {
        await controller.close();
      }
    }
  }

  @override
  Future<Map<String, dynamic>> extractIntakeJson({
    required String rawText,
  }) async {
    await _ensureLoaded();

    final prompt = '''
Return ONLY valid JSON.

Extract:
{
  "fullName": string|null,
  "nric": string|null,
  "address": string|null,
  "phone": string|null,
  "allergies": string|null
}

Text:
$rawText
''';

    final buffer = StringBuffer();

    StreamSubscription? sub;
    try {
      sub = _llama!.onTokenStream?.listen((event) {
        final fn = event['function']?.toString();
        final result = event['result'];

        if (fn == 'completion' && result is Map) {
          final token = result['token']?.toString() ?? '';
          if (token.isNotEmpty) buffer.write(token);
        }
      });

      await _llama!.completion(
        _contextId!,
        prompt: prompt,
        emitRealtimeCompletion: true,
      );
    } finally {
      await sub?.cancel();
    }

    return _safeParseJson(buffer.toString());
  }

  // ---------------------------------------------------------------------------
  // Load Model
  // ---------------------------------------------------------------------------

  Future<void> _ensureLoaded() async {
    if (_contextId != null) return;

    // If another caller is loading, wait for it to finish
    if (_loading) {
      while (_loading) {
        await Future.delayed(const Duration(milliseconds: 80));
      }
      if (_contextId != null) return;
      throw Exception('Local model load failed (concurrent load ended with null context).');
    }

    // IMPORTANT: prevent simulator crash
    if (_isSimulator()) {
      throw Exception(
        'Local GGUF loading is disabled on iOS Simulator (fllama/llama.cpp may crash). '
        'Run on a physical iPhone/iPad, or switch to Groq in settings.',
      );
    }

    if (!Platform.isIOS && !Platform.isAndroid) {
      throw Exception('Local llama only supported on iOS/Android.');
    }

    _loading = true;

    try {
      _llama = Fllama.instance();
      if (_llama == null) {
        throw Exception('Fllama.instance() returned null');
      }

      final modelPath = await _findGgufPath();

      final result = await _llama!.initContext(
        modelPath,
        emitLoadProgress: true,
      );

      // fllama result typically contains contextId as num/string.
      final rawId = result?['contextId'];
      final id = _coerceDouble(rawId);
      

      if (id == null) {
        throw Exception('Invalid contextId from fllama: $rawId');
      }

      _contextId = id;
    } finally {
      _loading = false;
    }
  }

  double? _coerceDouble(Object? v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    return double.tryParse(s);
  }

  Future<String> _findGgufPath() async {
    final dir = await getApplicationSupportDirectory();
    final modelsDir = Directory(p.join(dir.path, 'models'));

    if (!await modelsDir.exists()) {
      throw Exception('Models directory not found: ${modelsDir.path}');
    }

    final files = modelsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.gguf'))
        .toList();

    if (files.isEmpty) {
      throw Exception('No GGUF file found in ${modelsDir.path}');
    }

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files.first.path;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _buildPrompt(String transcript, String patientContext) {
    return '''
You are a clinical documentation assistant.

Patient Context:
$patientContext

Transcript:
$transcript

Write a concise outpatient note with sections:
- Chief Complaint
- HPI
- PMH
- Medications
- Allergies
- Exam
- Assessment
- Plan

Do not invent information.
''';
  }

  Map<String, dynamic> _safeParseJson(String text) {
    final trimmed = text.trim();

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
    } catch (_) {}

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start >= 0 && end > start) {
      final block = trimmed.substring(start, end + 1);
      try {
        final decoded = jsonDecode(block);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return decoded.cast<String, dynamic>();
      } catch (_) {}
    }

    throw FormatException('Invalid JSON from local model:\n$trimmed');
  }

  void dispose() {
    final id = _contextId;
    if (id != null) {
      _llama?.releaseContext(id);
    }
    _contextId = null;
  }
}