import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionContext {
  final String userId;
  final String unitId;
  final String unitName;
  final DateTime startedAt;
  final DateTime expiresAt;

  const SessionContext({
    required this.userId,
    required this.unitId,
    required this.unitName,
    required this.startedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'unitId': unitId,
        'unitName': unitName,
        'startedAt': startedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  static SessionContext fromJson(Map<String, dynamic> j) => SessionContext(
        userId: j['userId'] as String,
        unitId: j['unitId'] as String,
        unitName: j['unitName'] as String,
        startedAt: DateTime.parse(j['startedAt'] as String),
        expiresAt: DateTime.parse(j['expiresAt'] as String),
      );
}

class SessionContextStore {
  static const _key = 'active_session_context_json';
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<SessionContext?> getActive() async {
    final raw = await _secure.read(key: _key);
    if (raw == null) return null;

    try {
      final ctx = SessionContext.fromJson(jsonDecode(raw));
      if (ctx.isExpired) {
        await clear();
        return null;
      }
      return ctx;
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> setActive(SessionContext ctx) async {
    await _secure.write(key: _key, value: jsonEncode(ctx.toJson()));
  }

  Future<void> clear() async {
    await _secure.delete(key: _key);
  }
}

final sessionContextStoreProvider = Provider<SessionContextStore>((ref) {
  return SessionContextStore();
});