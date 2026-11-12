import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../recipes/presentation/providers/recipe_export_provider.dart';

/// Settings tile that triggers recipe catalog export to an RFC 4180 CSV file.
class ExportRecipesTile extends StatelessWidget {
  const ExportRecipesTile({super.key});

  @override
  Widget build(BuildContext context) {
    final exportProvider = Provider.of<RecipeExportProvider?>(context);
    final isExporting = exportProvider?.isExporting ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.file_download_outlined,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      title: Text(
        'Export Recipes (CSV)',
        style: getMediumStyle(
          context: context,
          fontSize: FontSize.s14,
        ),
      ),
      subtitle: Text(
        'Export culinary catalog in standard CSV format',
        style: getRegularStyle(
          context: context,
          fontSize: FontSize.s12,
          color: secColor,
        ),
      ),
      trailing: isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Icon(Icons.chevron_right_rounded, size: 20, color: secColor),
      onTap: (isExporting || exportProvider == null)
          ? null
          : () => _handleExport(context, exportProvider),
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    RecipeExportProvider provider,
  ) async {
    final success = await provider.exportAllRecipes();
    if (!context.mounted) return;

    if (success) {
      final filePath = provider.exportedFilePath ?? '';
      final fileName = filePath.contains(Platform.pathSeparator)
          ? filePath.split(Platform.pathSeparator).last
          : filePath;
      CustomSnackbar.showSuccess(
        context,
        fileName.isNotEmpty
            ? 'Recipes exported to $fileName'
            : 'Recipes exported successfully',
      );
    } else {
      final errorMsg = provider.errorMessage ?? 'Failed to export recipes';
      CustomSnackbar.showError(context, errorMsg);
    }
  }
}
