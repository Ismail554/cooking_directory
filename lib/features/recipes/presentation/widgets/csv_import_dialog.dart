import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/services/recipe_csv_converter.dart';
import '../providers/recipe_provider.dart';

class CsvImportDialog extends StatefulWidget {
  const CsvImportDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const CsvImportDialog(),
    );
  }

  @override
  State<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<CsvImportDialog> {
  final _csvController = TextEditingController();
  bool _isImporting = false;

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  void _loadSample() {
    setState(() {
      _csvController.text = RecipeCsvConverter.generateSampleCsv();
    });
  }

  Future<void> _handleImport() async {
    final text = _csvController.text.trim();
    if (text.isEmpty) {
      CustomSnackbar.showError(context, 'Please paste or enter CSV text');
      return;
    }

    setState(() => _isImporting = true);
    final count = await context.read<RecipeProvider>().importFromCsv(text);
    if (!mounted) return;
    setState(() => _isImporting = false);

    if (count > 0) {
      CustomSnackbar.showSuccess(
        context,
        'Successfully imported $count recipe${count > 1 ? 's' : ''}!',
      );
      Navigator.of(context).pop();
    } else {
      final error = context.read<RecipeProvider>().errorMessage ??
          'Could not parse recipes from CSV';
      CustomSnackbar.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r20),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: SingleChildScrollView(
        padding: AppSpacing.dialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.file_upload_outlined, color: AppColors.primary),
                AppSpacing.gapW8,
                Expanded(
                  child: Text(
                    'Import Recipes from CSV',
                    style: getBoldStyle(context: context, fontSize: FontSize.s16),
                  ),
                ),
              ],
            ),
            AppSpacing.gapH8,
            Text(
              'Format: Title, Subtitle, Ingredients, Instructions, Notes/Description, Time (mins), Servings',
              style: getRegularStyle(
                context: context,
                fontSize: FontSize.s11,
                color: AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.gapH12,
            TextField(
              controller: _csvController,
              maxLines: 7,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Paste CSV text here...',
                filled: true,
                border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
              ),
            ),
            AppSpacing.gapH12,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loadSample,
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: const Text('Load Sample', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            AppSpacing.gapH16,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    isOutlined: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: AppButton(
                    text: 'Import',
                    isLoading: _isImporting,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _handleImport,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

