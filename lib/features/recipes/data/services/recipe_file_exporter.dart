import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service responsible for persisting CSV content to device storage
/// and triggering system sharing via [SharePlus].
class RecipeFileExporter {
  const RecipeFileExporter();

  /// Formats the current timestamp as YYYYMMDD_HHmmss.
  String generateTimestamp([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$y$m${d}_$h$min$s';
  }

  /// Writes [csvContent] to a timestamped file in the documents or temp directory,
  /// optionally invokes [Share.shareXFiles], and returns the saved file path.
  Future<String> exportCsvFile(
    String csvContent, {
    Directory? customDirectory,
    bool triggerShare = true,
    DateTime? timestamp,
  }) async {
    final directory = customDirectory ?? await _resolveDirectory();
    final timestampStr = generateTimestamp(timestamp);
    final fileName = 'recipes_export_$timestampStr.csv';
    final filePath = '${directory.path}${Platform.pathSeparator}$fileName';

    final file = File(filePath);
    await file.writeAsString(csvContent, flush: true);

    if (triggerShare) {
      await _safelyShareFile(filePath, fileName);
    }

    return filePath;
  }

  /// Resolves the storage directory, preferring documents directory and falling
  /// back to temporary directory.
  Future<Directory> _resolveDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return await getTemporaryDirectory();
    }
  }

  /// Dispatches the file to the system share dialog.
  /// Silently falls back if system sharing is unavailable (e.g. headless tests).
  Future<void> _safelyShareFile(String filePath, String fileName) async {
    try {
      final xFile = XFile(filePath, mimeType: 'text/csv', name: fileName);
      await Share.shareXFiles(
        [xFile],
        subject: 'Cooking Directory - Exported Recipes',
        text: 'Exported recipe collection from Cooking Directory.',
      );
    } catch (_) {
      // Ignored: fallback ensures file is saved and path is returned
    }
  }
}
