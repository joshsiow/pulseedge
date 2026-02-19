import 'package:shared_preferences/shared_preferences.dart';

/// Low-level persistence for AI preferences.
/// No business logic here.
class AiPrefs {
  static const _kPreferLocal = 'ai_prefer_local';
  static const _kGroqApiKey = 'ai_groq_api_key';

  // ---------------------------------------------------------------------------
  // Prefer local (llama.cpp)
  // ---------------------------------------------------------------------------

  /// Canonical read
  Future<bool> readPreferLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPreferLocal) ?? true;
  }

  /// Backward-compatible alias
  Future<bool> getPreferLocal() async {
    return readPreferLocal();
  }

  /// Write
  Future<void> setPreferLocal(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPreferLocal, value);
  }

  // ---------------------------------------------------------------------------
  // Groq API key
  // ---------------------------------------------------------------------------

  /// Canonical read
  Future<String?> readGroqApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kGroqApiKey);
    return (v == null || v.trim().isEmpty) ? null : v;
  }

  /// Backward-compatible alias
  Future<String?> getGroqApiKey() async {
    return readGroqApiKey();
  }

  /// Write
  Future<void> setGroqApiKey(String? key) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == null || key.trim().isEmpty) {
      await prefs.remove(_kGroqApiKey);
    } else {
      await prefs.setString(_kGroqApiKey, key.trim());
    }
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  /// Clear all AI-related preferences (debug / reset)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPreferLocal);
    await prefs.remove(_kGroqApiKey);
  }
}