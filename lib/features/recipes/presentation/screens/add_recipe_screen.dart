import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recipe_provider.dart';
import '../widgets/csv_import_dialog.dart';
import '../widgets/dynamic_list_input_section.dart';
import '../widgets/instruction_step_input_section.dart';
import '../widgets/recipe_form_time_servings_row.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ingredientsKey = GlobalKey<DynamicListInputSectionState>();
  final _stepsKey = GlobalKey<InstructionStepInputSectionState>();

  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _notesController = TextEditingController();
  final _prepController = TextEditingController(text: '15');
  final _cookController = TextEditingController(text: '20');
  final _servingsController = TextEditingController(text: '4');

  static const _categories = ['Dinner', 'Lunch', 'Breakfast', 'Desserts', 'Healthy', 'General'];
  static const _difficulties = ['Easy', 'Medium', 'Hard'];

  String _selectedCategory = 'Dinner';
  String _selectedDifficulty = 'Medium';
  final List<String> _ingredients = [];
  final List<String> _steps = [];
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in [_titleController, _subtitleController, _notesController, _prepController, _cookController, _servingsController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onSave() async {
    _ingredientsKey.currentState?.commitPending();
    _stepsKey.currentState?.commitPending();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_ingredients.isEmpty) {
      CustomSnackbar.showError(context, 'Please add at least one ingredient');
      return;
    }
    if (_steps.isEmpty) {
      CustomSnackbar.showError(context, 'Please add at least one instruction step');
      return;
    }

    setState(() => _isSaving = true);
    final title = _titleController.text.trim();
    final recipe = Recipe(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: _subtitleController.text.trim(),
      description: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : _subtitleController.text.trim(),
      category: _selectedCategory,
      prepTimeMinutes: int.tryParse(_prepController.text.trim()) ?? 15,
      cookTimeMinutes: int.tryParse(_cookController.text.trim()) ?? 20,
      servings: int.tryParse(_servingsController.text.trim()) ?? 4,
      calories: 400,
      difficulty: _selectedDifficulty,
      ingredients: List.from(_ingredients),
      steps: List.from(_steps),
      createdAt: DateTime.now(),
    );

    final provider = context.read<RecipeProvider?>();
    if (provider != null) await provider.addRecipe(recipe);

    if (!mounted) return;
    setState(() => _isSaving = false);
    CustomSnackbar.show(context, message: 'Recipe "$title" saved!', type: SnackbarType.success);
    Navigator.of(context).pop();
  }

  InputDecoration _buildDecoration({required String label, required String hint, IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = OutlineInputBorder(
      borderRadius: AppBorderRadius.r12,
      borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.w),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      prefixIcon: icon != null ? Icon(icon, size: AppIconSize.s20, color: AppColors.primary) : null,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Recipe', style: getBoldStyle(context: context, fontSize: FontSize.s18, color: onSurface)),
        actions: [
          TextButton.icon(onPressed: () => CsvImportDialog.show(context), icon: const Icon(Icons.file_upload_outlined, size: 18), label: const Text('Import CSV')),
          AppSpacing.gapW8,
        ],
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
                AppSpacing.gapH8,
                TextFormField(controller: _subtitleController, decoration: _buildDecoration(label: 'Subtitle', hint: 'Authentic Roman pasta specialty', icon: Icons.subtitles_outlined)),
                AppSpacing.gapH12,
                DynamicListInputSection(
                  key: _ingredientsKey, title: 'Ingredients', hintText: 'e.g. 200g spaghetti', icon: Icons.egg_alt_outlined,
                  items: _ingredients, onAdd: (item) => setState(() => _ingredients.add(item)), onRemove: (idx) => setState(() => _ingredients.removeAt(idx)),
                ),
                AppSpacing.gapH12,
                InstructionStepInputSection(
                  key: _stepsKey, items: _steps, onAdd: (step) => setState(() => _steps.add(step)), onRemove: (idx) => setState(() => _steps.removeAt(idx)),
                ),
                AppSpacing.gapH12,
                TextFormField(controller: _notesController, maxLines: 2, decoration: _buildDecoration(label: 'Notes / Description', hint: 'Chef tips, seasoning notes...', icon: Icons.description_outlined)),
                AppSpacing.gapH12,
                RecipeFormTimeServingsRow(prepController: _prepController, cookController: _cookController, servingsController: _servingsController, buildDecoration: _buildDecoration),
                AppSpacing.gapH12,
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: _buildDecoration(label: 'Category', hint: 'Dinner', icon: Icons.category_outlined),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) { if (v != null) setState(() => _selectedCategory = v); },
                    ),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDifficulty,
                      decoration: _buildDecoration(label: 'Difficulty', hint: 'Medium', icon: Icons.speed_rounded),
                      items: _difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) { if (v != null) setState(() => _selectedDifficulty = v); },
                    ),
                  ),
                ]),
                AppSpacing.gapH16,
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(children: [
            Expanded(child: AppButton(text: 'Cancel', isOutlined: true, onPressed: () => Navigator.of(context).pop())),
            AppSpacing.gapW12,
            Expanded(child: AppButton(text: 'Save Recipe', icon: Icons.check_circle_rounded, isLoading: _isSaving, onPressed: _onSave)),
          ]),
        ),
      ),
    );
  }
}
