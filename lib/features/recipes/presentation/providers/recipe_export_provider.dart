import 'package:flutter/foundation.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/usecases/export_recipes_to_csv_usecase.dart';

/// Represents the current lifecycle status of the recipe export operation.
enum ExportStatus {
  initial,
  exporting,
  success,
  error,
}

/// Provider managing the state and execution of exporting recipes to CSV.
class RecipeExportProvider extends ChangeNotifier {
  final ExportRecipesToCsvUseCase _exportUseCase;

  ExportStatus _status = ExportStatus.initial;
  String? _exportedFilePath;
  String? _errorMessage;

  RecipeExportProvider({
    ExportRecipesToCsvUseCase? exportUseCase,
  }) : _exportUseCase = exportUseCase ??
            ExportRecipesToCsvUseCase(RecipeRepositoryImpl());

  ExportStatus get status => _status;
  bool get isExporting => _status == ExportStatus.exporting;
  String? get exportedFilePath => _exportedFilePath;
  String? get errorMessage => _errorMessage;

  /// Initiates the recipe export process.
  /// Returns `true` if the export succeeded, `false` otherwise.
  Future<bool> exportAllRecipes() async {
    _status = ExportStatus.exporting;
    _errorMessage = null;
    notifyListeners();

    try {
      final path = await _exportUseCase();
      _exportedFilePath = path;
      _status = ExportStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e
          .toString()
          .replaceFirst(RegExp(r'^(Exception|StateError|Bad state):\s*'), '');
      notifyListeners();
      return false;
    }
  }

  /// Resets the export status back to initial state.
  void resetStatus() {
    _status = ExportStatus.initial;
    _errorMessage = null;
    _exportedFilePath = null;
    notifyListeners();
  }
}
