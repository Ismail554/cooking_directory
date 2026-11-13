import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Lightweight JSON persistence helper backed by app documents directory.
/// Gracefully falls back to an in-memory map in headless/test environments.
class LocalJsonStore {
  static final Map<String, String> _memoryFallback = {};

  static Future<File?> _resolveFile(String fileName) async {
    if (kIsWeb) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}${Platform.pathSeparator}$fileName');
    } catch (_) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> readList(String fileName) async {
    try {
      final file = await _resolveFile(fileName);
      String? raw;
      if (file != null) {
        if (!await file.exists()) return null;
        raw = await file.readAsString();
      } else {
        raw = _memoryFallback[fileName];
      }
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return null;
  }

  static Future<void> writeList(String fileName, List<Map<String, dynamic>> items) async {
    final encoded = jsonEncode(items);
    try {
      final file = await _resolveFile(fileName);
      if (file != null) {
        await file.writeAsString(encoded, flush: true);
        return;
      }
    } catch (_) {}
    _memoryFallback[fileName] = encoded;
  }

  static Future<void> deleteFile(String fileName) async {
    _memoryFallback.remove(fileName);
    try {
      final file = await _resolveFile(fileName);
      if (file != null && await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
