import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  static const _secure = FlutterSecureStorage();

  static String? userId;
  static String? username;
  static String? role;
  static String? unitId;
  static String? unitName;

  static Future<void> load() async {
    if (Platform.isMacOS) {
      final f = await _file();
      if (!await f.exists()) return;
      final s = await f.readAsString();
      final parts = s.split('|');
      if (parts.length < 5) return;
      userId = parts[0].isEmpty ? null : parts[0];
      username = parts[1].isEmpty ? null : parts[1];
      role = parts[2].isEmpty ? null : parts[2];
      unitId = parts[3].isEmpty ? null : parts[3];
      unitName = parts[4].isEmpty ? null : parts[4];
      return;
    }

    userId = await _secure.read(key: 'sess_userId');
    username = await _secure.read(key: 'sess_username');
    role = await _secure.read(key: 'sess_role');
    unitId = await _secure.read(key: 'sess_unitId');
    unitName = await _secure.read(key: 'sess_unitName');
  }

  static Future<void> save({
    required String userId,
    required String username,
    required String role,
    required String unitId,
    required String unitName,
  }) async {
    SessionStore.userId = userId;
    SessionStore.username = username;
    SessionStore.role = role;
    SessionStore.unitId = unitId;
    SessionStore.unitName = unitName;

    if (Platform.isMacOS) {
      final f = await _file();
      await f.create(recursive: true);
      await f.writeAsString('$userId|$username|$role|$unitId|$unitName', flush: true);
      return;
    }

    await _secure.write(key: 'sess_userId', value: userId);
    await _secure.write(key: 'sess_username', value: username);
    await _secure.write(key: 'sess_role', value: role);
    await _secure.write(key: 'sess_unitId', value: unitId);
    await _secure.write(key: 'sess_unitName', value: unitName);
  }

  static Future<void> clear() async {
    userId = username = role = unitId = unitName = null;

    if (Platform.isMacOS) {
      final f = await _file();
      if (await f.exists()) await f.delete();
      return;
    }

    await _secure.delete(key: 'sess_userId');
    await _secure.delete(key: 'sess_username');
    await _secure.delete(key: 'sess_role');
    await _secure.delete(key: 'sess_unitId');
    await _secure.delete(key: 'sess_unitName');
  }

  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'pulseedge_session.txt'));
  }

  static bool get isLoggedIn => userId != null && unitId != null;
}