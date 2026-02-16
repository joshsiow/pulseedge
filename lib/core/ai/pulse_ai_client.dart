// lib/core/ai/pulse_ai_client.dart
//
// Lightweight client for PulseAI extraction.
// Phase 3A uses llama-server over HTTP.
//
// Later you can swap this implementation to embedded gguf runtime
// without changing your UI code.

import 'dart:convert';

import 'package:http/http.dart' as http;

class PulseAiClient {
  PulseAiClient({
    this.baseUrl = 'http://127.0.0.1:8080',
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  void dispose() => _http.close();

  /// Returns a JSON map with keys:
  /// fullName, nric, address, phone, allergies
  ///
  /// Throws on network/parse errors.
  Future<Map<String, dynamic>> extractIntake({
    required String freeText,
    List<String> missingFields = const [],
  }) async {
    // Prompt: force strict JSON only (so we can parse deterministically)
    final missingHint = missingFields.isEmpty
        ? ''
        : '\nNote: The following fields were missing in previous attempts - try harder to find them: ${missingFields.join(', ')}';

    final prompt = '''
You are Pulse AI. Extract patient registration fields from the text.
Return ONLY valid JSON with keys:
fullName, nric, address, phone, allergies.
If a field is missing, use null. No extra keys. No markdown. No explanations.

TEXT:
$freeText$missingHint
''';

    final uri = Uri.parse('$baseUrl/v1/chat/completions');
    final res = await _http.post(
      uri,
      headers: {'Content-Type': 'application/application/json'},
      body: jsonEncode({
        'model': 'local',
        'messages': [
          {'role': 'system', 'content': 'You output strict JSON only.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.0,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('llama-server HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    final content = decoded['choices']?[0]?['message']?['content'];

    if (content is! String || content.trim().isEmpty) {
      throw Exception('Empty model response');
    }

    // Some models may include accidental leading text; attempt to recover JSON.
    final jsonText = _extractFirstJsonObject(content);
    final obj = jsonDecode(jsonText);

    if (obj is Map<String, dynamic>) return obj;
    throw Exception('Model did not return a JSON object');
  }

  /// Extracts the first {...} JSON object from the model text.
  /// This guards against occasional "Sure, here's the JSON:".
  String _extractFirstJsonObject(String s) {
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception('No JSON object found in model output');
    }
    return s.substring(start, end + 1).trim();
  }
}