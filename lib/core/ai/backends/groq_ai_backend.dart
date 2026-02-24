// lib/core/ai/backends/groq_ai_backend.dart
// NOTE: You must have saved the key in FlutterSecureStorage under 'groq_api_key'.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ai_backend.dart';

class GroqAiBackend implements AiBackend {
  GroqAiBackend({
    http.Client? client,
    FlutterSecureStorage? storage,
    String model = 'llama-3.3-70b-versatile',
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage(),
        _model = model;

  final http.Client _client;
  final FlutterSecureStorage _storage;
  final String _model;

  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _storageKey = 'groq_api_key';

  Future<String?> _getApiKey() => _storage.read(key: _storageKey);

  Map<String, String> _headers(String apiKey) => <String, String>{
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      };

  // ---------------------------------------------------------------------------
  // AiBackend
  // ---------------------------------------------------------------------------

  @override
  Future<String> generate(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
  }) async {
    final apiKey = (await _getApiKey())?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('Groq API key missing');
    }

    final body = <String, dynamic>{
      'model': _model,
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant.'},
        {'role': 'user', 'content': prompt},
      ],
      'max_tokens': maxTokens,
      'temperature': temperature,
      'stream': false,
    };

    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse(_endpoint),
            headers: _headers(apiKey),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw StateError('Groq network error: $e');
    }

    if (res.statusCode != 200) {
      throw StateError('Groq error ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    final content = decoded['choices']?[0]?['message']?['content'];

    if (content is! String || content.trim().isEmpty) {
      throw StateError('Invalid Groq response: ${res.body}');
    }

    return content.trim();
  }

  @override
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  }) async* {
    final apiKey = (await _getApiKey())?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      yield 'Groq API key missing. Configure it in Settings.';
      return;
    }

    const systemRules = '''
You are a clinical documentation assistant. You MUST be assistive only.

Write a concise outpatient note in this EXACT format:

- Chief Complaint:
- HPI:
- PMH:
- Medications:
- Allergies:
- Exam:
- Assessment:
- Plan:

Rules:
- Do NOT invent vitals, labs, imaging, or diagnoses.
- If missing, write "Not documented".
- Use the transcript + context only.
''';

    final userPrompt = '''
Patient context:
$patientContext

Clinician dictation / transcript:
$transcript
''';

    final req = http.Request('POST', Uri.parse(_endpoint))
      ..headers.addAll(_headers(apiKey))
      ..body = jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': systemRules},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.2,
        'max_tokens': 700, // ✅ important for some 400s
        'stream': true,
      });

    http.StreamedResponse resp;
    try {
      resp = await _client.send(req).timeout(const Duration(seconds: 60));
    } catch (e) {
      yield 'Groq network error: $e';
      return;
    }

    if (resp.statusCode != 200) {
      // ✅ show actual Groq error payload (critical to debug)
      final errText = await resp.stream.bytesToString();
      yield 'Groq error: HTTP ${resp.statusCode}\n$errText';
      return;
    }

    // Robust SSE parsing: chunks may split lines and JSON payloads.
    final partialLine = StringBuffer();

    await for (final chunk in resp.stream.transform(utf8.decoder)) {
      partialLine.write(chunk);

      final text = partialLine.toString();
      final lines = text.split('\n');

      // Keep the last line if it's partial (no trailing newline yet)
      partialLine
        ..clear()
        ..write(lines.isNotEmpty ? lines.removeLast() : '');

      for (final rawLine in lines) {
        final line = rawLine.trimRight();
        if (!line.startsWith('data:')) continue;

        final payload = line.substring(5).trim(); // after "data:"
        if (payload.isEmpty) continue;
        if (payload == '[DONE]') continue;

        try {
          final j = jsonDecode(payload);
          final token = j['choices']?[0]?['delta']?['content'];
          if (token is String && token.isNotEmpty) {
            yield token;
          }
        } catch (_) {
          // ignore malformed streaming chunks
        }
      }
    }

    yield '\n\n---\nAI-assisted draft (Groq) — clinician reviewed.';
  }

  @override
  Future<Map<String, dynamic>> extractIntakeJson({
    required String rawText,
  }) async {
    final apiKey = (await _getApiKey())?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('Groq API key missing.');
    }

    const systemPrompt = '''
Return ONLY valid JSON (no markdown, no commentary).
Schema:
{
  "fullName": string|null,
  "nric": string|null,
  "address": string|null,
  "phone": string|null,
  "allergies": string|null
}
''';

    final body = <String, dynamic>{
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': rawText},
      ],
      'temperature': 0.0,
      'max_tokens': 400,
      'stream': false,
    };

    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse(_endpoint),
            headers: _headers(apiKey),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw StateError('Groq network error: $e');
    }

    if (res.statusCode != 200) {
      throw StateError('Groq error ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    final content = decoded['choices']?[0]?['message']?['content'];

    if (content is! String || content.trim().isEmpty) {
      throw StateError('Invalid Groq response: ${res.body}');
    }

    // Safe extraction: if model wraps JSON with text, carve the first {...} block.
    final text = content.trim();
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    final jsonText = (start >= 0 && end > start) ? text.substring(start, end + 1) : text;

    final obj = jsonDecode(jsonText);
    if (obj is Map<String, dynamic>) return obj;
    if (obj is Map) return obj.cast<String, dynamic>();

    throw FormatException('Groq returned non-object JSON: $jsonText');
  }

  void dispose() => _client.close();
}