import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ai_backend.dart';

/// Groq (cloud) AI backend.
///
/// - OpenAI-compatible Chat Completions API
/// - Assistive-only (no analytics, no decisions)
/// - Used as fallback when local GGUF is unavailable
class GroqAiBackend implements AiBackend {
  GroqAiBackend({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _storage;

  static const _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<String?> _getApiKey() {
    return _storage.read(key: 'groq_api_key');
  }

  // ---------------------------------------------------------------------------
  // AiBackend interface
  // ---------------------------------------------------------------------------

  @override
  Stream<String> draftNote({
    required String transcript,
    required String patientContext,
  }) async* {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      yield 'Groq API key missing. Configure it in Settings.';
      return;
    }

    final prompt = '''
You are a strictly ASSISTIVE clinical documentation aide.
You MUST NOT diagnose or make decisions.

Draft a concise SOAP-style clinical note.
Highlight medications and allergies clearly.

Patient context:
$patientContext

Clinician dictation:
$transcript
''';

    final request = http.Request('POST', Uri.parse(_endpoint))
      ..headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({
        'model': 'llama-3.1-70b-versatile',
        'messages': [
          {'role': 'system', 'content': prompt},
        ],
        'temperature': 0.2,
        'stream': true,
      });

    try {
      final response = await _client.send(request);

      if (response.statusCode != 200) {
        yield 'Groq error: HTTP ${response.statusCode}';
        return;
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          if (!line.startsWith('data: ')) continue;
          if (line.contains('[DONE]')) continue;

          try {
            final json = jsonDecode(line.substring(6));
            final token =
                json['choices']?[0]?['delta']?['content'];
            if (token is String && token.isNotEmpty) {
              yield token;
            }
          } catch (_) {
            // Ignore malformed streaming chunks
          }
        }
      }

      yield '\n\n---\nAI-assisted draft (Groq Llama-3) — clinician reviewed.';
    } catch (e) {
      yield 'Groq network error: $e';
    }
  }

  @override
  Future<Map<String, dynamic>> extractIntakeJson({
    required String rawText,
  }) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('Groq API key missing.');
    }

    final prompt = '''
Extract patient intake information into STRICT JSON.
Return JSON only. No explanation.

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

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.1-70b-versatile',
        'messages': [
          {'role': 'system', 'content': prompt},
        ],
        'temperature': 0.0,
        'stream': false,
      }),
    );

    if (response.statusCode != 200) {
      throw StateError(
        'Groq error ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final content =
        decoded['choices']?[0]?['message']?['content'];

    if (content is! String || content.isEmpty) {
      throw StateError('Invalid Groq response.');
    }

    return jsonDecode(content) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  void dispose() {
    _client.close();
  }
}