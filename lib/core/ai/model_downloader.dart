// lib/core/ai/model_downloader.dart

import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ModelDownloader extends StatefulWidget {
  final String modelUrl;
  final String modelFileName;
  final String expectedSha256;
  final int expectedSize;
  final String id;
  final String version;

  final VoidCallback onComplete;
  final void Function(String error)? onError; // Optional enhanced error callback

  const ModelDownloader({
    super.key,
    required this.modelUrl,
    required this.modelFileName,
    required this.expectedSha256,
    required this.expectedSize,
    required this.id,
    required this.version,
    required this.onComplete,
    this.onError,
  });

  @override
  State<ModelDownloader> createState() => _ModelDownloaderState();
}

class _ModelDownloaderState extends State<ModelDownloader> {
  final Logger _logger = Logger();
  static const _methodChannel = MethodChannel('com.yourapp/modelmanager'); // Must match AppDelegate.swift

  double _progress = 0.0;
  String _status = 'Ready';
  bool _isDownloading = false;
  bool _isCancelled = false;
  String? _error;

  Future<String> _getModelPath() async {
    final dir = await getApplicationSupportDirectory(); // Better than Documents for large assets
    return p.join(dir.path, widget.modelFileName);
  }

  Future<void> _startDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _isCancelled = false;
      _status = 'Connecting...';
      _error = null;
      _progress = 0.0;
    });

    http.Client? client;
    RandomAccessFile? sink;
    try {
      final modelPath = await _getModelPath();
      final file = File(modelPath);
      var startByte = 0;

      if (await file.exists()) {
        startByte = await file.length();
        if (startByte > 0) {
          _logger.i('Partial file found: $startByte bytes - attempting resume');
          setState(() => _status = 'Resuming from ${(startByte / (1024 * 1024)).toStringAsFixed(1)} MB');
        }
      }

      // Head request for total size and resume support
      final headResponse = await http.head(Uri.parse(widget.modelUrl));
      final totalBytes = int.tryParse(headResponse.headers['content-length'] ?? '') ?? widget.expectedSize;
      final acceptsRanges = headResponse.headers['accept-ranges'] == 'bytes';

      if (startByte >= totalBytes && totalBytes > 0) {
        setState(() {
          _progress = 1.0;
          _status = 'Already complete - verifying...';
        });
        await _verifyAndFinalize(modelPath);
        return;
      }

      client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.modelUrl));

      if (startByte > 0 && acceptsRanges) {
        request.headers['Range'] = 'bytes=$startByte-';
        _logger.i('Requesting resume from byte $startByte');
      }

      var streamedResponse = await client.send(request);

      // Handle range not satisfiable - restart from beginning
      if (streamedResponse.statusCode == 416 && startByte > 0) {
        _logger.w('Server rejected range - restarting from beginning');
        await file.delete();
        startByte = 0;
        final newRequest = http.Request('GET', Uri.parse(widget.modelUrl));
        streamedResponse = await client.send(newRequest);
      }

      if (streamedResponse.statusCode != 200 && streamedResponse.statusCode != 206) {
        throw Exception('HTTP ${streamedResponse.statusCode}');
      }

      sink = await file.open(mode: startByte > 0 ? FileMode.append : FileMode.write);
      var received = startByte;

      await for (final chunk in streamedResponse.stream) {
        if (_isCancelled) {
          throw Exception('Download cancelled by user');
        }
        await sink.writeFrom(chunk);
        received += chunk.length;

        if (totalBytes > 0) {
          setState(() {
            _progress = received / totalBytes;
            _status = 'Downloading: ${(received / (1024 * 1024)).toStringAsFixed(1)} MB '
                '/ ${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
          });
        }
      }

      setState(() {
        _progress = 1.0;
        _status = 'Download complete - verifying...';
      });

      await _verifyAndFinalize(modelPath);
    } catch (e) {
      if (!_isCancelled) {
        setState(() {
          _error = e.toString();
          _status = 'Failed - tap Retry';
        });
        _logger.e('Download error: $e');
        widget.onError?.call(e.toString());
      }
    } finally {
      await sink?.close();
      client?.close();
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _verifyAndFinalize(String path) async {
    final file = File(path);

    // Size check
    final actualSize = await file.length();
    if (actualSize != widget.expectedSize) {
      throw Exception('Size mismatch: expected ${widget.expectedSize}, got $actualSize');
    }

    // SHA-256 check (slow on large files - consider optional or background)
    setState(() => _status = 'Computing SHA-256...');
    final computedHash = await _computeSha256(file);
    if (computedHash != widget.expectedSha256.toLowerCase()) {
      throw Exception('SHA-256 mismatch');
    }

    // iOS do-not-backup flag
    if (Platform.isIOS) {
      await _methodChannel.invokeMethod('setDoNotBackup', {'path': path});
    }

    setState(() => _status = 'Verified & ready!');
    widget.onComplete();
  }

  Future<String> _computeSha256(File file) async {
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }

  void _cancelDownload() {
    setState(() {
      _isCancelled = true;
      _isDownloading = false;
      _status = 'Cancelled';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline AI Model Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_download, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'One-time download of offline AI model (~2.3 GB) for rural use.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            LinearProgressIndicator(value: _progress > 0 ? _progress : null),
            const SizedBox(height: 16),
            Text(_status, textAlign: TextAlign.center),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isDownloading ? null : _startDownload,
                  child: Text(_isDownloading ? 'Downloading...' : 'Start / Resume'),
                ),
                const SizedBox(width: 16),
                if (_isDownloading)
                  ElevatedButton(
                    onPressed: _cancelDownload,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}