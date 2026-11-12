import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import '../../domain/entities/instruction_step_data.dart';

/// Step-by-step culinary instructions timeline featuring circular numbered
/// badges, instruction cards, and smart timer suggestion chips.
class InstructionsTimeline extends StatelessWidget {
  const InstructionsTimeline({super.key, required this.steps, this.onStartTimer});
  final List<String> steps;
  final void Function(int stepIndex, int minutes)? onStartTimer;

  static final RegExp _timerRegex = RegExp(r'(\d+)\s*(?:minutes|mins|minute|min)', caseSensitive: false);

  int? _extractMinutes(String stepText) {
    final match = _timerRegex.firstMatch(stepText);
    return match != null ? int.tryParse(match.group(1) ?? '') : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions (${steps.length} Steps)',
          style: getBoldStyle(context: context, fontSize: FontSize.s16, color: onSurface),
        ),
        AppSpacing.gapH12,
        ...List.generate(steps.length, (index) {
          final stepNumber = index + 1;
          final stepText = steps[index];
          final minutes = _extractMinutes(stepText);
          final isLast = index == steps.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineNode(stepNumber, isLast, isDark),
                AppSpacing.gapW12,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.s16),
                    child: _buildStepCard(context, stepText, minutes, index, isDark, onSurface),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimelineNode(int stepNumber, bool isLast, bool isDark) {
    return Column(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text('$stepNumber', style: getBoldStyle(fontSize: FontSize.s13, color: AppColors.primary)),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2.w,
              margin: EdgeInsets.symmetric(vertical: 4.h),
              color: isDark ? AppColors.borderDark : AppColors.primaryContainer.withValues(alpha: 0.8),
            ),
          ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, String text, int? minutes, int index, bool isDark, Color onSurface) {
    final parsed = InstructionStepData.parse(text);

    return Container(
      padding: EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(parsed.instruction, style: getRegularStyle(context: context, fontSize: FontSize.s14, height: 1.45, color: onSurface)),
          if (parsed.hasNotes) ...[
            AppSpacing.gapH8,
            _buildNotes(context, parsed.notes, isDark),
          ],
          if (minutes != null && minutes > 0) ...[
            AppSpacing.gapH8,
            InkWell(
              onTap: () => onStartTimer?.call(index, minutes),
              borderRadius: AppBorderRadius.r12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: AppColors.prepTimeTag, borderRadius: AppBorderRadius.r12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: AppIconSize.s14, color: AppColors.prepTimeText),
                    AppSpacing.gapW4,
                    Flexible(
                      child: Text('Step Timer: $minutes min', style: getSemiBoldStyle(context: context, fontSize: FontSize.s12, color: AppColors.prepTimeText)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotes(BuildContext context, List<String> notes, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: notes.map((note) {
        final clean = note.startsWith('#') ? note.substring(1).trim() : note.trim();
        return Container(
          margin: EdgeInsets.only(top: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.secondaryContainer.withValues(alpha: 0.35),
            borderRadius: AppBorderRadius.r8,
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25), width: 1.w),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: AppBorderRadius.r4),
                child: Text('#', style: getBoldStyle(fontSize: FontSize.s11, color: Colors.white)),
              ),
              AppSpacing.gapW8,
              Expanded(
                child: Text(
                  clean,
                  style: getMediumStyle(context: context, fontSize: FontSize.s12, color: isDark ? AppColors.textPrimaryDark : AppColors.secondary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
