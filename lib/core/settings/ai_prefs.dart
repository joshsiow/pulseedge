import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Low-level persistence for AI preferences.
/// - preferLocal: SharedPreferences (non-sensitive)
/// - groqApiKey: FlutterSecureStorage (sensitive)
class AiPrefs {
  static const _kPreferLocal = 'ai_prefer_local';

  // Must match GroqAiBackend:
  static const _kGroqApiKeySecure = 'groq_api_key';

  final FlutterSecureStorage _secure;

  AiPrefs({FlutterSecureStorage? secure})
      : _secure = secure ?? const FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Prefer local
  // ---------------------------------------------------------------------------

  Future<bool> readPreferLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPreferLocal) ?? true;
  }

  Future<bool> getPreferLocal() => readPreferLocal();

  Future<void> setPreferLocal(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPreferLocal, value);
  }

  // ---------------------------------------------------------------------------
  // Groq API key (SECURE)
  // ---------------------------------------------------------------------------

  Future<String?> readGroqApiKey() async {
    final v = await _secure.read(key: _kGroqApiKeySecure);
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  Future<String?> getGroqApiKey() => readGroqApiKey();

  Future<void> setGroqApiKey(String? key) async {
    final t = key?.trim();
    if (t == null || t.isEmpty) {
      await _secure.delete(key: _kGroqApiKeySecure);
    } else {
      await _secure.write(key: _kGroqApiKeySecure, value: t);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPreferLocal);
    await _secure.delete(key: _kGroqApiKeySecure);
  }
}