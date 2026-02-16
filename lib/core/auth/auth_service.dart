// lib/core/auth/auth_service.dart
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService._internal());

class AuthService {
  AuthService._internal();

  final AppDatabase db = AppDatabase.instance;

  User? currentUser;

  Future<void> initialize() async {
    // Ensure at least one admin exists
    await _ensureSeedAdmin();

    // Repair any legacy/broken password fields (like DEV_SEEDED==)
    await _repairAdminPasswordIfCorrupt();

    debugPrint('AuthService initialized');
  }

  Future<void> _ensureSeedAdmin() async {
    final existingCountExpr = db.users.id.count();
    final existingCount = await (db.selectOnly(db.users)..addColumns([existingCountExpr]))
        .map((row) => row.read(existingCountExpr) ?? 0)
        .getSingle();

    if (existingCount > 0) return;

    final now = DateTime.now();
    final unitId = const UuidV4().generate();
    final userId = const UuidV4().generate();

    await db.into(db.units).insert(UnitsCompanion.insert(
          id: unitId,
          name: 'Default Unit',
          code: 'DEFAULT',
          createdAt: now,
        ));

    final hp = _hashPassword('admin123');

    await db.into(db.users).insert(UsersCompanion.insert(
          id: userId,
          username: 'admin',
          displayName: const Value('Administrator'),
          role: 'admin',
          passwordSaltB64: hp.saltB64,
          passwordHashB64: hp.hashB64,
          passwordIterations: hp.iterations,
          isActive: const Value(true),
          createdAt: now,
        ));

    await db.into(db.userUnits).insert(UserUnitsCompanion.insert(
          userId: userId,
          unitId: unitId,
          createdAt: now,
        ));

    debugPrint('Seeded default admin: admin/admin123');
  }

  /// Fixes old broken DB content (e.g. passwordSaltB64 = "DEV_SEEDED==")
  Future<void> _repairAdminPasswordIfCorrupt() async {
    final admin = await (db.select(db.users)
          ..where((u) => u.username.equals('admin')))
        .getSingleOrNull();

    if (admin == null) return;

    final okSalt = _isValidStdBase64(admin.passwordSaltB64);
    final okHash = _isValidStdBase64(admin.passwordHashB64);
    final okIter = admin.passwordIterations > 0;

    if (okSalt && okHash && okIter) return;

    debugPrint(
      'Password fields corrupt/legacy for admin. Repairing -> reset to admin123',
    );

    await setPassword(
      userId: admin.id,
      newPassword: 'admin123',
      iterations: 150000,
    );
  }

  /// Your UI currently calls: auth.login(username, password)
  Future<User?> login(String username, String password) async {
    final user = await (db.select(db.users)
          ..where((u) => u.username.equals(username) & u.isActive.equals(true)))
        .getSingleOrNull();

    if (user == null) return null;

    final ok = _verifyPasswordSafe(
      password,
      saltB64: user.passwordSaltB64,
      hashB64: user.passwordHashB64,
      iterations: user.passwordIterations,
    );

    if (!ok) return null;

    currentUser = user;
    return user;
  }

  void logout() {
    currentUser = null;
  }

  Future<void> setPassword({
    required String userId,
    required String newPassword,
    int iterations = 150000,
  }) async {
    final hp = _hashPassword(newPassword, iterations: iterations);

    await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        passwordSaltB64: Value(hp.saltB64),
        passwordHashB64: Value(hp.hashB64),
        passwordIterations: Value(hp.iterations),
      ),
    );
  }

  // ---------------- Password hashing (PBKDF2-HMAC-SHA256) ----------------

  _HashParts _hashPassword(
    String password, {
    int iterations = 150000,
    int saltBytes = 16,
    int dkLen = 32,
  }) {
    final salt = _randomBytes(saltBytes);
    final derived = _pbkdf2HmacSha256(
      password: utf8.encode(password),
      salt: salt,
      iterations: iterations,
      dkLen: dkLen,
    );

    return _HashParts(
      saltB64: base64Encode(salt),
      hashB64: base64Encode(derived),
      iterations: iterations,
    );
  }

  /// Robust verifier: never throws. If DB has junk, it just returns false.
  bool _verifyPasswordSafe(
    String password, {
    required String saltB64,
    required String hashB64,
    required int iterations,
  }) {
    try {
      if (!_isValidStdBase64(saltB64) || !_isValidStdBase64(hashB64) || iterations <= 0) {
        debugPrint('Password verification error (likely invalid stored data): salt/hash not valid base64');
        return false;
      }

      final salt = base64Decode(saltB64);
      final expected = base64Decode(hashB64);

      final actual = _pbkdf2HmacSha256(
        password: utf8.encode(password),
        salt: salt,
        iterations: iterations,
        dkLen: expected.length,
      );

      return _constantTimeEquals(expected, actual);
    } catch (e) {
      debugPrint('Password verification error (likely invalid stored data): $e');
      return false;
    }
  }

  bool _isValidStdBase64(String s) {
    // Reject common “fake” sentinel values like DEV_SEEDED==
    if (s.contains('_') || s.contains('-')) return false; // base64url chars
    try {
      base64Decode(s);
      return true;
    } catch (_) {
      return false;
    }
  }

  List<int> _pbkdf2HmacSha256({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int dkLen,
  }) {
    const hLen = 32;
    final l = (dkLen / hLen).ceil();
    final r = dkLen - (l - 1) * hLen;
    final out = <int>[];

    for (var i = 1; i <= l; i++) {
      final t = _f(password, salt, iterations, i);
      out.addAll(i == l ? t.sublist(0, r) : t);
    }
    return out;
  }

  List<int> _f(List<int> password, List<int> salt, int c, int blockIndex) {
    final block = <int>[
      ...salt,
      (blockIndex >> 24) & 0xff,
      (blockIndex >> 16) & 0xff,
      (blockIndex >> 8) & 0xff,
      blockIndex & 0xff,
    ];

    var u = _hmacSha256(password, block);
    final t = List<int>.from(u);

    for (var i = 2; i <= c; i++) {
      u = _hmacSha256(password, u);
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    return t;
  }

  List<int> _hmacSha256(List<int> key, List<int> message) {
    final h = Hmac(sha256, key);
    return h.convert(message).bytes;
  }

  List<int> _randomBytes(int n) {
    final rnd = Random.secure();
    return List<int>.generate(n, (_) => rnd.nextInt(256));
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

class _HashParts {
  _HashParts({
    required this.saltB64,
    required this.hashB64,
    required this.iterations,
  });

  final String saltB64;
  final String hashB64;
  final int iterations;
}

class UuidV4 {
  const UuidV4();

  String generate() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));

    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    String two(int x) => x.toRadixString(16).padLeft(2, '0');

    return '${two(bytes[0])}${two(bytes[1])}${two(bytes[2])}${two(bytes[3])}-'
        '${two(bytes[4])}${two(bytes[5])}-'
        '${two(bytes[6])}${two(bytes[7])}-'
        '${two(bytes[8])}${two(bytes[9])}-'
        '${two(bytes[10])}${two(bytes[11])}${two(bytes[12])}${two(bytes[13])}${two(bytes[14])}${two(bytes[15])}';
  }
}