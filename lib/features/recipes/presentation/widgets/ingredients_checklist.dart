import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

/// Interactive culinary ingredients checklist with dynamic servings adjustment,
/// checkboxes, and visual strike-through completion indicators.
class IngredientsChecklist extends StatefulWidget {
  const IngredientsChecklist({
    super.key,
    required this.ingredients,
    this.initialServings = 4,
    this.onServingsChanged,
  });

  final List<String> ingredients;
  final int initialServings;
  final ValueChanged<int>? onServingsChanged;

  @override
  State<IngredientsChecklist> createState() => _IngredientsChecklistState();
}

class _IngredientsChecklistState extends State<IngredientsChecklist> {
  late int _servings;
  final Set<int> _checkedIndices = {};

  @override
  void initState() {
    super.initState();
    _servings = widget.initialServings > 0 ? widget.initialServings : 4;
  }

  void _updateServings(int delta) {
    final next = _servings + delta;
    if (next >= 1 && next <= 20) {
      setState(() => _servings = next);
      widget.onServingsChanged?.call(_servings);
    }
  }

  void _toggleCheck(int index) {
    setState(() {
      if (!_checkedIndices.add(index)) _checkedIndices.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Ingredients (${widget.ingredients.length})',
                style: getBoldStyle(context: context, fontSize: FontSize.s16, color: onSurface),
              ),
            ),
            _buildServingsStepper(context, isDark, onSurface),
          ],
        ),
        AppSpacing.gapH12,
        ...List.generate(widget.ingredients.length, (index) {
          final isChecked = _checkedIndices.contains(index);
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.s8),
            child: InkWell(
              onTap: () => _toggleCheck(index),
              borderRadius: AppBorderRadius.r12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: isChecked
                      ? (isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.4) : AppColors.surfaceVariantLight.withValues(alpha: 0.5))
                      : theme.cardColor,
                  borderRadius: AppBorderRadius.r12,
                  border: Border.all(
                    color: isChecked ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: Checkbox(
                        value: isChecked,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r4),
                        onChanged: (_) => _toggleCheck(index),
                      ),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Text(
                        widget.ingredients[index],
                        style: getRegularStyle(
                          context: context,
                          fontSize: FontSize.s14,
                          color: isChecked ? onSurfaceVariant : onSurface,
                          decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildServingsStepper(BuildContext context, bool isDark, Color onSurface) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight,
        borderRadius: AppBorderRadius.r20,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            iconSize: AppIconSize.s16,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 26.r, height: 26.r),
            color: _servings > 1 ? AppColors.primary : AppColors.textTertiaryLight,
            onPressed: _servings > 1 ? () => _updateServings(-1) : null,
          ),
          AppSpacing.gapW4,
          Text('$_servings serv', style: getSemiBoldStyle(context: context, fontSize: FontSize.s12, color: onSurface)),
          AppSpacing.gapW4,
          IconButton(
            icon: const Icon(Icons.add_rounded),
            iconSize: AppIconSize.s16,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 26.r, height: 26.r),
            color: _servings < 20 ? AppColors.primary : AppColors.textTertiaryLight,
            onPressed: _servings < 20 ? () => _updateServings(1) : null,
          ),
        ],
      ),
    );
  }
}
