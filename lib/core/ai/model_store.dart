// lib/core/ai/model_store.dart
//
// Offline-first GGUF model management:
// - Stores model outside APK/IPA (in Application Support dir)
// - Downloads via streamed HTTP (no huge RAM spikes)
// - Verifies SHA-256 integrity (optional but strongly recommended)
// - Supports simple progress reporting
//
// Requires pubspec.yaml:
//   dependencies:
//     http: ^1.2.2
//     path: ^1.9.0
//     path_provider: ^2.1.3
//     crypto: ^3.0.3
//
// Notes:
// - Use Application Support (not Documents) for “app-internal assets”.
// - The model can be delivered via:
//   a) signed URL (recommended), or
//   b) MDM/IT copy into the directory (then ensureModelReady just verifies).
//
// Usage (example):
//   final store = ModelStore(
//     modelFileName: 'Llama-3.2-3B-Instruct-Q5_K_M.gguf',
//     downloadUrl: '<SIGNED_URL>',
//     sha256Hex: '<EXPECTED_SHA256_HEX>',
//   );
//   final path = await store.ensureModelReady(
//     onProgress: (p) => debugPrint('download: ${(p * 100).toStringAsFixed(1)}%'),
//   );

import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(double progress0to1);

class ModelStoreException implements Exception {
  ModelStoreException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() =>
      'ModelStoreException: $message${cause == null ? '' : ' ($cause)'}';
}

class ModelStore {
  ModelStore({
    required this.modelFileName,
    this.downloadUrl,
    this.sha256Hex,
    http.Client? httpClient,
    this.subdir = 'models',
  }) : _http = httpClient ?? http.Client();

  /// Filename on disk (e.g. Llama-3.2-3B-Instruct-Q5_K_M.gguf)
  final String modelFileName;

  /// Optional remote URL. Prefer short-lived signed URL (or MDM).
  final String? downloadUrl;

  /// Optional integrity check (hex string, lowercase recommended).
  /// If provided, the store verifies file integrity after download and on reuse.
  final String? sha256Hex;

  /// Subdirectory under Application Support dir.
  final String subdir;

  final http.Client _http;

  /// Close HTTP client when you're done (or rely on provider dispose).
  void dispose() => _http.close();

  /// Returns the directory where models are stored.
  Future<Directory> _modelDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, subdir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Returns the full path to the model file location.
  Future<String> modelPath() async {
    final dir = await _modelDir();
    return p.join(dir.path, modelFileName);
  }

  /// Checks if the model exists (and passes sha256 if configured).
  Future<bool> isModelReady() async {
    final path = await modelPath();
    final f = File(path);
    if (!await f.exists()) return false;

    if (sha256Hex != null && sha256Hex!.trim().isNotEmpty) {
      final ok = await _verifySha256File(f, sha256Hex!.trim());
      return ok;
    }
    return true;
  }

  /// Ensure model is available locally and (optionally) verified.
  ///
  /// Returns the model file path if ready, otherwise throws.
  ///
  /// - If file exists and verifies: returns path.
  /// - If missing and downloadUrl present: downloads to a temp file, verifies,
  ///   then atomically renames.
  /// - If missing and no downloadUrl: throws.
  Future<String> ensureModelReady({
    ProgressCallback? onProgress,
    Duration timeout = const Duration(minutes: 30),
    bool deleteCorruptFile = true,
  }) async {
    final path = await modelPath();
    final f = File(path);

    // 1) If exists, verify (optional) and return.
    if (await f.exists()) {
      if (await _verifyIfNeeded(f, deleteCorruptFile: deleteCorruptFile)) {
        return path;
      }
      // If verification failed and deleteCorruptFile=false, we fall through.
    }

    // 2) If missing, must have downloadUrl.
    final url = downloadUrl;
    if (url == null || url.trim().isEmpty) {
      throw ModelStoreException(
        'Model file not found locally and no downloadUrl provided.',
      );
    }

    // 3) Download to temp file and atomically move.
    final dir = await _modelDir();
    final tmpPath = p.join(dir.path, '.$modelFileName.download');
    final tmpFile = File(tmpPath);

    // Cleanup any previous partial download.
    if (await tmpFile.exists()) {
      try {
        await tmpFile.delete();
      } catch (_) {/* ignore */}
    }

    await _downloadFileStreamed(
      url: url,
      outFile: tmpFile,
      onProgress: onProgress,
      timeout: timeout,
    );

    // 4) Verify downloaded file if expected hash is provided.
    if (sha256Hex != null && sha256Hex!.trim().isNotEmpty) {
      final ok = await _verifySha256File(tmpFile, sha256Hex!.trim());
      if (!ok) {
        try {
          await tmpFile.delete();
        } catch (_) {/* ignore */}
        throw ModelStoreException('SHA-256 verification failed after download.');
      }
    }

    // 5) Atomically replace target.
    try {
      // Ensure parent dir exists (already created).
      if (await f.exists()) {
        await f.delete();
      }
      await tmpFile.rename(path);
    } catch (e) {
      // If rename fails across filesystems, fallback to copy+delete.
      try {
        await tmpFile.copy(path);
        await tmpFile.delete();
      } catch (e2) {
        throw ModelStoreException(
          'Failed to finalize model file.',
          cause: e2,
        );
      }
    }

    return path;
  }

  /// Deletes the stored model file (useful for reset / force upgrade).
  Future<void> deleteModelIfExists() async {
    final path = await modelPath();
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }

  /// Returns stored model size in bytes if present, else null.
  Future<int?> modelSizeBytes() async {
    final path = await modelPath();
    final f = File(path);
    if (!await f.exists()) return null;
    return f.length();
  }

  // --------------------------------------------------------------------------
  // Internals
  // --------------------------------------------------------------------------

  Future<bool> _verifyIfNeeded(
    File f, {
    required bool deleteCorruptFile,
  }) async {
    final expected = sha256Hex;
    if (expected == null || expected.trim().isEmpty) return true;

    final ok = await _verifySha256File(f, expected.trim());
    if (!ok && deleteCorruptFile) {
      try {
        await f.delete();
      } catch (_) {/* ignore */}
    }
    return ok;
  }

  Future<void> _downloadFileStreamed({
    required String url,
    required File outFile,
    ProgressCallback? onProgress,
    required Duration timeout,
  }) async {
    final uri = Uri.parse(url);

    // Ensure parent dir exists
    await outFile.parent.create(recursive: true);

    http.StreamedResponse res;
    try {
      final req = http.Request('GET', uri);
      res = await _http.send(req).timeout(timeout);
    } catch (e) {
      throw ModelStoreException('Failed to start download.', cause: e);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ModelStoreException('Download failed: HTTP ${res.statusCode}.');
    }

    final contentLen = res.contentLength; // may be null
    final sink = outFile.openWrite(mode: FileMode.writeOnly);

    int received = 0;
    final completer = Completer<void>();

    StreamSubscription<List<int>>? sub;
    Timer? progressTimer;

    void emitProgress() {
      if (onProgress == null) return;
      if (contentLen == null || contentLen <= 0) {
        // Unknown size: emit -1? We'll emit 0 until end, then 1.
        onProgress(received == 0 ? 0.0 : 0.01);
      } else {
        final p = received / contentLen;
        onProgress(p.clamp(0.0, 1.0));
      }
    }

    // Throttle progress callbacks to avoid UI spam
    progressTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      emitProgress();
    });

    sub = res.stream.listen(
      (chunk) {
        received += chunk.length;
        sink.add(chunk);
      },
      onError: (e) async {
        progressTimer?.cancel();
        try {
          await sink.close();
        } catch (_) {/* ignore */}
        try {
          await outFile.delete();
        } catch (_) {/* ignore */}
        if (!completer.isCompleted) {
          completer.completeError(ModelStoreException('Download stream error.', cause: e));
        }
      },
      onDone: () async {
        progressTimer?.cancel();
        try {
          await sink.flush();
          await sink.close();
        } catch (e) {
          try {
            await outFile.delete();
          } catch (_) {/* ignore */}
          if (!completer.isCompleted) {
            completer.completeError(ModelStoreException('Failed to finalize download file.', cause: e));
          }
          return;
        }

        // Emit final progress as 1.0 if known, else still signal completion.
        if (onProgress != null) onProgress(1.0);

        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );

    // Await completion
    try {
      await completer.future;
    } finally {
      await sub.cancel();
      progressTimer.cancel();
    }
  }

  Future<bool> _verifySha256File(File f, String expectedHex) async {
    // Normalize
    final expected = expectedHex.toLowerCase().trim();

    // For big files, streaming hash is essential.
    Digest digest;
    try {
      final input = f.openRead();
      digest = await sha256.bind(input).first;
    } catch (e) {
      throw ModelStoreException('Failed to compute SHA-256.', cause: e);
    }

    final actual = digest.toString().toLowerCase();
    if (kDebugMode) {
      debugPrint('ModelStore sha256 actual=$actual expected=$expected');
    }
    return actual == expected;
  }
}