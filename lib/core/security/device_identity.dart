// lib/core/security/device_identity.dart

import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class DeviceIdentity {
  DeviceIdentity._internal();

  static final DeviceIdentity _instance = DeviceIdentity._internal();
  static DeviceIdentity get instance => _instance;

  static const _storage = FlutterSecureStorage();

  static const _deviceIdKey = 'pulseedge_device_id';
  static const _installIdKey = 'pulseedge_install_id';

  String? _deviceId;
  String? _installId;

  String get deviceId {
    if (_deviceId == null) {
      throw StateError('DeviceIdentity not initialized');
    }
    return _deviceId!;
  }

  String get installId {
    if (_installId == null) {
      throw StateError('DeviceIdentity not initialized');
    }
    return _installId!;
  }

  /// Call once at bootstrap
  static Future<void> initialize() async {
    await instance._init();
  }

  Future<void> _init() async {
    _deviceId = await _storage.read(key: _deviceIdKey);
    _installId = await _storage.read(key: _installIdKey);

    // If no device ID exists, create one
    if (_deviceId == null) {
      _deviceId = _generateSecureId();
      await _storage.write(key: _deviceIdKey, value: _deviceId);
      debugPrint('DeviceIdentity: Generated new deviceId');
    }

    // Install ID changes if app reinstalled
    if (_installId == null) {
      _installId = _generateSecureId();
      await _storage.write(key: _installIdKey, value: _installId);
      debugPrint('DeviceIdentity: Generated new installId');
    }

    debugPrint('DeviceIdentity ready');
  }

  /// Cryptographically strong random ID (128-bit)
  String _generateSecureId({int bytes = 16}) {
    final rnd = Random.secure();
    final data = List<int>.generate(bytes, (_) => rnd.nextInt(256));
    return base64UrlEncode(data).replaceAll('=', '');
  }

  /// Future use:
  /// Bind encryption key derivation to device
  String deriveScopedKey(String namespace) {
    final input = utf8.encode('$deviceId::$namespace');
    final hash = base64UrlEncode(input);
    return hash.substring(0, min(32, hash.length));
  }

  /// Optional: Reset identity (DEV only)
  Future<void> resetForDev() async {
    await _storage.delete(key: _deviceIdKey);
    await _storage.delete(key: _installIdKey);
    _deviceId = null;
    _installId = null;
  }
}