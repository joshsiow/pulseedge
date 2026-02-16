import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fllama/fllama.dart';

import 'ai_backend.dart';

/// Local (on-device) AI backend using fllama / llama.cpp.
///
/// Notes:
/// - Intended for REAL devices (iOS / Android)
/// - Simulator support is best-effort only
/// - Uses dynamic compatibility shim to survive fllama API changes
class LocalAiBackend implements AiBackend {
  LocalAiBackend();

  dynamic _client; // fllama API varies across versions
  bool _loaded = false;

  dynamic get _llama => _client ??= Fllama.instance()!;

  // ---------------------------------------------------------------------------
  // Model lifecycle
  // ---------------------------------------------------------------------------

  Future<void> loadModel({
    required String modelPath,
    int contextSize = 2048,
    int threads = 4,
  }) async {
    if (_loaded) return;

    if (!File(modelPath).existsSync()) {
      throw Exception('GGUF model not found at $modelPath');
    }

    final ok = await _tryLoad(
      modelPath,
      contextSize: contextSize,
      threads: threads,
    );

    if (!ok) {
      throw UnsupportedError(
        'Installed fllama version does not expose a compatible load API.',
      );
    }

    _loaded = true;
  }

  // ---------------------------------------------------------------------------
  // AiBackend interface
  // ---------------------------------------------------------------------------

  @override
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  }) {
    final prompt = '''
You are a strictly ASSISTIVE clinical documentation aide.
Draft a concise SOAP note.
Do NOT diagnose or decide.
Highlight medications and allergies clearly.

Patient context:
$patientContext

Clinician dictation:
$transcript
''';

    return generateStream(
      prompt: prompt,
      maxTokens: 1024,
      temperature: 0.2,
    );
  }

  @override
  Future<Map<String, dynamic>> extractIntakeJson({
    required String rawText,
  }) async {
    final prompt = '''
Extract intake fields into STRICT JSON.
Return JSON only. No commentary.

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

    final text = await generate(
      prompt: prompt,
      maxTokens: 512,
      temperature: 0.0,
    );

    return jsonDecode(text) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Generation helpers
  // ---------------------------------------------------------------------------

  Future<String> generate({
    required String prompt,
    int maxTokens = 512,
    double temperature = 0.0,
  }) async {
    if (!_loaded) {
      throw StateError('Local AI model not loaded');
    }

    final result = await _tryCompletion(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
    );

    if (result == null) {
      throw UnsupportedError(
        'Installed fllama version does not expose a compatible completion API.',
      );
    }

    return _coerceToText(result);
  }

  Stream<String> generateStream({
    required String prompt,
    int maxTokens = 1024,
    double temperature = 0.7,
  }) async* {
    if (!_loaded) {
      throw StateError('Local AI model not loaded');
    }

    final stream = _tryCompletionStream(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
    );

    if (stream == null) {
      // Fallback to one-shot generation
      yield await generate(
        prompt: prompt,
        maxTokens: maxTokens,
        temperature: temperature,
      );
      return;
    }

    await for (final chunk in stream) {
      final text = _coerceToText(chunk);
      if (text.isNotEmpty) yield text;
    }
  }

  Future<void> dispose() async {
    try {
      final c = _llama;
      await _callIfExists(c, 'dispose');
      await _callIfExists(c, 'unload');
      await _callIfExists(c, 'close');
    } catch (_) {
      // ignore
    } finally {
      _client = null;
      _loaded = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Compatibility shim (fllama API variations)
  // ---------------------------------------------------------------------------

  Future<bool> _tryLoad(
    String modelPath, {
    required int contextSize,
    required int threads,
  }) async {
    final c = _llama;

    final candidates = <Future<void> Function()>[
      () => (c as dynamic).loadModel(
            path: modelPath,
            contextSize: contextSize,
            threads: threads,
          ),
      () => (c as dynamic).loadModel(
            modelPath: modelPath,
            contextSize: contextSize,
            threads: threads,
          ),
      () => (c as dynamic).load(
            path: modelPath,
            contextSize: contextSize,
            threads: threads,
          ),
      () => (c as dynamic).load(
            modelPath: modelPath,
            contextSize: contextSize,
            threads: threads,
          ),
      () => (c as dynamic).init(
            modelPath: modelPath,
            contextSize: contextSize,
            threads: threads,
          ),
    ];

    for (final fn in candidates) {
      try {
        await fn();
        return true;
      } on NoSuchMethodError {
        // try next
      }
    }
    return false;
  }

  Future<dynamic> _tryCompletion(
    String prompt, {
    required int maxTokens,
    required double temperature,
  }) async {
    final c = _llama;

    final candidates = <Future<dynamic> Function()>[
      () => (c as dynamic).completion(
            prompt,
            maxTokens: maxTokens,
            temperature: temperature,
          ),
      () => (c as dynamic).completion(
            prompt,
            nPredict: maxTokens,
            temperature: temperature,
          ),
      () => (c as dynamic).completion(prompt),
      () => (c as dynamic).generate(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature,
          ),
      () => (c as dynamic).generate(prompt),
    ];

    for (final fn in candidates) {
      try {
        return await fn();
      } on NoSuchMethodError {
        // try next
      }
    }
    return null;
  }

  Stream<dynamic>? _tryCompletionStream(
    String prompt, {
    required int maxTokens,
    required double temperature,
  }) {
    final c = _llama;

    final candidates = <Stream<dynamic> Function()>[
      () => (c as dynamic).completionStream(
            prompt,
            maxTokens: maxTokens,
            temperature: temperature,
          ),
      () => (c as dynamic).completionStream(prompt),
      () => (c as dynamic).generateStream(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature,
          ),
      () => (c as dynamic).generateStream(prompt),
      () => (c as dynamic).stream(prompt),
    ];

    for (final fn in candidates) {
      try {
        return fn();
      } on NoSuchMethodError {
        // try next
      }
    }
    return null;
  }

  static Future<void> _callIfExists(dynamic obj, String methodName) async {
    try {
      final fn = (obj as dynamic)[methodName];
      if (fn is Function) {
        final r = fn();
        if (r is Future) await r;
      }
    } catch (_) {
      // ignore
    }
  }

  static String _coerceToText(dynamic result) {
    if (result == null) return '';
    if (result is String) return result;

    try {
      final t = (result as dynamic).text;
      if (t is String) return t;
    } catch (_) {}

    return result.toString();
  }
}