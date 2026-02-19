// lib/core/settings/ai_settings_store.dart
import 'dart:async';

import 'ai_prefs.dart';

/// Immutable snapshot of AI settings.
class AiSettings {
  final bool preferLocal;
  final String? groqApiKey;

  const AiSettings({
    required this.preferLocal,
    required this.groqApiKey,
  });

  AiSettings copyWith({
    bool? preferLocal,
    String? groqApiKey,
  }) {
    return AiSettings(
      preferLocal: preferLocal ?? this.preferLocal,
      groqApiKey: groqApiKey ?? this.groqApiKey,
    );
  }

  @override
  String toString() => 'AiSettings(preferLocal: $preferLocal, groqApiKey: '
      '${groqApiKey == null ? "null" : "***"})';

  @override
  bool operator ==(Object other) =>
      other is AiSettings &&
      other.preferLocal == preferLocal &&
      other.groqApiKey == groqApiKey;

  @override
  int get hashCode => Object.hash(preferLocal, groqApiKey);
}

/// Small settings store for AI wiring.
/// - preferLocal lives in SharedPreferences (via AiPrefs)
/// - groqApiKey lives in FlutterSecureStorage (via AiPrefs)
///
/// This store adds:
/// - caching
/// - a broadcast stream for UI/providers
/// - safe updates that always refresh cache + notify listeners
class AiSettingsStore {
  final AiPrefs _prefs;

  AiSettings? _cache;
  bool _loading = false;

  final StreamController<AiSettings> _controller =
      StreamController<AiSettings>.broadcast();

  AiSettingsStore({AiPrefs? prefs}) : _prefs = prefs ?? AiPrefs();

  /// Whether [load] is currently running.
  bool get isLoading => _loading;

  /// Last cached value (may be null until [load] runs).
  AiSettings? get cached => _cache;

  /// Stream that emits the latest settings whenever they change.
  Stream<AiSettings> watch() => _controller.stream;

  /// Load from storage and update cache.
  Future<AiSettings> load({bool force = false}) async {
    if (!force && _cache != null) return _cache!;
    if (_loading) {
      // If concurrent callers hit load(), wait until first one populates cache.
      // This keeps behavior deterministic without adding a mutex dependency.
      while (_loading) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      return _cache ?? const AiSettings(preferLocal: true, groqApiKey: null);
    }

    _loading = true;
    try {
      final preferLocal = await _prefs.getPreferLocal();
      final groqKey = await _prefs.getGroqApiKey();
      final next = AiSettings(preferLocal: preferLocal, groqApiKey: groqKey);

      _cache = next;
      _emit(next);
      return next;
    } finally {
      _loading = false;
    }
  }

  /// Convenience: always returns a non-null settings snapshot.
  Future<AiSettings> getCurrent() async {
    return _cache ?? await load();
  }

  Future<void> setPreferLocal(bool v) async {
    await _prefs.setPreferLocal(v);
    final current = await getCurrent();
    final next = current.copyWith(preferLocal: v);
    _cache = next;
    _emit(next);
  }

  Future<void> setGroqApiKey(String? key) async {
    await _prefs.setGroqApiKey(key);
    final current = await getCurrent();
    final next = current.copyWith(groqApiKey: (key == null || key.trim().isEmpty)
        ? null
        : key.trim());
    _cache = next;
    _emit(next);
  }

  /// Clears the Groq key and resets preferLocal to default (true).
  Future<void> resetToDefaults() async {
    await _prefs.setGroqApiKey(null);
    await _prefs.setPreferLocal(true);

    const next = AiSettings(preferLocal: true, groqApiKey: null);
    _cache = next;
    _emit(next);
  }

  void _emit(AiSettings s) {
    if (_controller.isClosed) return;
    _controller.add(s);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}