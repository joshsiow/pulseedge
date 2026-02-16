import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ModelInfo {
  final String id;
  final String version;
  final String sha256;
  final int size;
  final String path;

  ModelInfo({
    required this.id,
    required this.version,
    required this.sha256,
    required this.size,
    required this.path,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'version': version,
        'sha256': sha256,
        'size': size,
        'path': path,
      };

  factory ModelInfo.fromJson(Map<String, dynamic> json) => ModelInfo(
        id: json['id'],
        version: json['version'],
        sha256: json['sha256'],
        size: json['size'],
        path: json['path'],
      );
}

class ModelManager extends StateNotifier<AsyncValue<ModelInfo?>> {
  ModelManager() : super(const AsyncLoading()) {
    _init();
  }

  static const _methodChannel = MethodChannel('com.yourapp/modelmanager'); // Must match AppDelegate.swift
  late Directory _appDir;
  late String _manifestPath;
  ModelInfo? _currentModel;
  CancelToken? _cancelToken;

  // Exposed for UI progress bar
  double downloadProgress = 0.0;

  Future<void> _init() async {
    try {
      _appDir = await getApplicationSupportDirectory();
      _manifestPath = p.join(_appDir.path, 'model_manifest.json');
      await _loadManifest();

      // Auto-preload bundled model if present and no manifest exists
      if (_currentModel == null) {
        await _preloadBundledModelIfAvailable();
      }
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> _loadManifest() async {
    final file = File(_manifestPath);
    if (await file.exists()) {
      final json = jsonDecode(await file.readAsString());
      _currentModel = ModelInfo.fromJson(json);
      if (await File(_currentModel!.path).exists()) {
        state = AsyncData(_currentModel);
        return;
      }
    }
    state = const AsyncData(null);
  }

  // Optional auto-preload from assets (great for dev/testing with your large bundled GGUF)
  Future<void> _preloadBundledModelIfAvailable() async {
    const bundledAssetPath = 'assets/model/Llama-3.2-3B-Instruct-Q5_K_M.gguf'; // Match your pubspec assets entry
    try {
      final byteData = await rootBundle.load(bundledAssetPath);
      final targetPath = p.join(_appDir.path, 'Llama-3.2-3B-Instruct-Q5_K_M.gguf');
      final file = File(targetPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Bundled model is trusted — skip full verification, but set do-not-backup
      if (Platform.isIOS) {
        await _methodChannel.invokeMethod('setDoNotBackup', {'path': targetPath});
      }

      // Hardcoded metadata (update SHA256/size if you want strict check later)
      // You can compute real SHA256 in Terminal: shasum -a 256 path/to/your.gguf
      // Example placeholder values — replace with real ones for production
      _currentModel = ModelInfo(
        id: 'llama-3.2-3b-instruct',
        version: 'q5_k_m',
        sha256: 'replace_with_actual_sha256_if_verifying', // Optional: leave as placeholder if skipping check
        size: byteData.lengthInBytes,
        path: targetPath,
      );

      await File(_manifestPath).writeAsString(jsonEncode(_currentModel!.toJson()));
      state = AsyncData(_currentModel);
    } catch (e) {
      // No bundled asset or error — ignore and stay in "missing" state
      debugPrint('No bundled model found or preload failed: $e');
    }
  }

  Future<void> downloadModel({
    required String url,
    required String expectedSha256,
    required String id,
    required String version,
    required int expectedSize,
  }) async {
    state = const AsyncLoading();
    downloadProgress = 0.0;
    _cancelToken = CancelToken();

    try {
      final modelPath = p.join(_appDir.path, 'model_$id.gguf');
      await Dio().download(
        url,
        modelPath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            downloadProgress = received / total;
            state = const AsyncLoading(); // Notify UI of progress
          }
        },
      );

      await _verifyAndSave(modelPath, expectedSha256, expectedSize, id, version);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(e, StackTrace.current);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _verifyAndSave(String path, String expectedSha256, int expectedSize, String id, String version) async {
    final file = File(path);

    // Size check
    if (await file.length() != expectedSize) {
      throw Exception('File size mismatch');
    }

    // SHA-256 check (slow on large files — optional in production if trusted source)
    final computedHash = await _computeSha256(file);
    if (computedHash != expectedSha256.toLowerCase()) {
      throw Exception('SHA-256 mismatch');
    }

    // iOS do-not-backup
    if (Platform.isIOS) {
      await _methodChannel.invokeMethod('setDoNotBackup', {'path': path});
    }

    _currentModel = ModelInfo(
      id: id,
      version: version,
      sha256: expectedSha256,
      size: expectedSize,
      path: path,
    );
    await File(_manifestPath).writeAsString(jsonEncode(_currentModel!.toJson()));
    state = AsyncData(_currentModel);
  }

  Future<String> _computeSha256(File file) async {
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }

  // Import from file picker (verification required — fill in known values or temporarily comment checks)
  Future<void> importModel() async {
    state = const AsyncLoading();
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) {
      state = AsyncData(_currentModel);
      return;
    }

    final pickedPath = result.files.single.path!;
    final fileName = p.basename(pickedPath);
    final newPath = p.join(_appDir.path, fileName);
    await File(pickedPath).copy(newPath);

    // TODOFor your Llama-3.2-3B file, replace these with real values
    // SHA256: Run in Terminal → shasum -a 256 /path/to/Llama-3.2-3B-Instruct-Q5_K_M.gguf
    // Size: Get Info in Finder → exact bytes
    try {
      await _verifyAndSave(
        newPath,
        'replace_with_actual_sha256', // e.g., 'a1b2c3d4e5...'
        1234567890, // e.g., 2823456789
        'llama-3.2-3b-instruct',
        'q5_k_m',
      );
    } catch (e) {
      // For quick testing, you can temporarily bypass verification here
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteModel() async {
    if (_currentModel == null) return;
    await File(_currentModel!.path).delete();
    await File(_manifestPath).delete();
    _currentModel = null;
    state = const AsyncData(null);
  }

  void cancelDownload() {
    _cancelToken?.cancel();
  }
}

// Riverpod provider
final modelManagerProvider = StateNotifierProvider<ModelManager, AsyncValue<ModelInfo?>>((ref) => ModelManager());