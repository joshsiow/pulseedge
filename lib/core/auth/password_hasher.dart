// lib/core/auth/password_hasher.dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Production-grade password hashing utility
/// Uses PBKDF2-HMAC-SHA256
///
/// Compatible with AuthService.
/// No Flutter dependencies. Pure Dart.

class PasswordHasher {
  static const int defaultIterations = 150000;
  static const int defaultSaltBytes = 16;
  static const int defaultKeyLength = 32;

  const PasswordHasher();

  /// Create salted PBKDF2 hash
  HashResult hashPassword(
    String password, {
    int iterations = defaultIterations,
    int saltBytes = defaultSaltBytes,
    int dkLen = defaultKeyLength,
  }) {
    final salt = _randomBytes(saltBytes);

    final derived = _pbkdf2(
      password: utf8.encode(password),
      salt: salt,
      iterations: iterations,
      dkLen: dkLen,
    );

    return HashResult(
      saltB64: base64Encode(salt),
      hashB64: base64Encode(derived),
      iterations: iterations,
    );
  }

  /// Verify password safely (never throws)
  bool verifyPassword(
    String password, {
    required String saltB64,
    required String hashB64,
    required int iterations,
  }) {
    try {
      final salt = base64Decode(saltB64);
      final expected = base64Decode(hashB64);

      final actual = _pbkdf2(
        password: utf8.encode(password),
        salt: salt,
        iterations: iterations,
        dkLen: expected.length,
      );

      return _constantTimeEquals(expected, actual);
    } catch (_) {
      // If corrupted DB content, just fail safely
      return false;
    }
  }

  // ---------------------------------------------------------
  // PBKDF2 Implementation
  // ---------------------------------------------------------

  List<int> _pbkdf2({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int dkLen,
  }) {
    const hLen = 32; // SHA256 output length
    final l = (dkLen / hLen).ceil();
    final r = dkLen - (l - 1) * hLen;

    final out = <int>[];

    for (var i = 1; i <= l; i++) {
      final block = _f(password, salt, iterations, i);
      out.addAll(i == l ? block.sublist(0, r) : block);
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

/// Returned after hashing a password
class HashResult {
  const HashResult({
    required this.saltB64,
    required this.hashB64,
    required this.iterations,
  });

  final String saltB64;
  final String hashB64;
  final int iterations;
}