import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../domain/entities/instruction_step_data.dart';

/// Single instruction step tile with numbered node, direction text, '#' note chips, and delete button.
class InstructionStepTile extends StatelessWidget {
  final int index;
  final String rawStep;
  final VoidCallback onRemove;
  final ValueChanged<String>? onUpdate;

  const InstructionStepTile({
    super.key,
    required this.index,
    required this.rawStep,
    required this.onRemove,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parsed = InstructionStepData.parse(rawStep);
    final tagColor = isDark ? AppColors.secondaryLight : AppColors.secondary;

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: AppBorderRadius.r8,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22.r,
            height: 22.r,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: getBoldStyle(fontSize: FontSize.s11, color: Colors.white),
            ),
          ),
          AppSpacing.gapW8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parsed.instruction,
                  style: getMediumStyle(context: context, fontSize: FontSize.s13),
                ),
                if (parsed.hasNotes) ...[
                  AppSpacing.gapH4,
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: parsed.notes.map((note) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.14),
                          borderRadius: AppBorderRadius.r4,
                          border: Border.all(color: tagColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          note,
                          style: getMediumStyle(fontSize: FontSize.s11, color: tagColor),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onRemove,
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.close_rounded,
                size: AppIconSize.s18,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
