import 'package:flutter/material.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../recipes/presentation/widgets/csv_import_dialog.dart';

/// Settings tile that triggers recipe catalog import from CSV.
class ImportRecipesTile extends StatelessWidget {
  const ImportRecipesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.file_upload_outlined,
        color: AppColors.primary,
      ),
      title: Text(
        'Import Recipes (CSV)',
        style: getMediumStyle(
          context: context,
          fontSize: FontSize.s14,
        ),
      ),
      subtitle: Text(
        'Import recipes from CSV template or custom file',
        style: getRegularStyle(
          context: context,
          fontSize: FontSize.s12,
          color: AppColors.textSecondaryLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () => CsvImportDialog.show(context),
    );
  }
}

