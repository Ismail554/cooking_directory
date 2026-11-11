import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';
import 'package:cooking_directory/core/widgets/custom_snackbar.dart';

/// Form screen for creating a new recipe with keyboard overflow protection.
class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _prepController = TextEditingController();
  final _cookController = TextEditingController();
  final _servingsController = TextEditingController(text: '4');

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _prepController.dispose();
    _cookController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      CustomSnackbar.show(
        context,
        message: 'Recipe "${_titleController.text.trim()}" saved!',
        type: SnackbarType.success,
      );
      Navigator.of(context).pop();
    }
  }

  InputDecoration _buildDecoration({required String label, required String hint, IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: AppIconSize.s20, color: AppColors.primary) : null,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Recipe', style: getBoldStyle(context: context, fontSize: FontSize.s18, color: onSurface)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: _buildDecoration(label: 'Recipe Title', hint: "Grandma's Carbonara", icon: Icons.restaurant_rounded),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter recipe title' : null,
                ),
                AppSpacing.gapH16,
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: _buildDecoration(label: 'Description', hint: 'Brief summary of the dish...', icon: Icons.description_outlined),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter description' : null,
                ),
                AppSpacing.gapH16,
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prepController,
                        keyboardType: TextInputType.number,
                        decoration: _buildDecoration(label: 'Prep Time (m)', hint: '15', icon: Icons.timer_outlined),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: TextFormField(
                        controller: _cookController,
                        keyboardType: TextInputType.number,
                        decoration: _buildDecoration(label: 'Cook Time (m)', hint: '25', icon: Icons.local_fire_department_outlined),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH16,
                TextFormField(
                  controller: _servingsController,
                  keyboardType: TextInputType.number,
                  decoration: _buildDecoration(label: 'Servings', hint: '4', icon: Icons.people_outline_rounded),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                AppSpacing.gapH24,
                Row(
                  children: [
                    Expanded(
                      child: AppButton(text: 'Cancel', isOutlined: true, onPressed: () => Navigator.of(context).pop()),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: AppButton(text: 'Save Recipe', icon: Icons.check_circle_rounded, onPressed: _onSave),
                    ),
                  ],
                ),
                AppSpacing.gapH24,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
