import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../domain/entities/instruction_step_data.dart';
import 'instruction_step_tile.dart';

class InstructionStepInputSection extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  const InstructionStepInputSection({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<InstructionStepInputSection> createState() =>
      InstructionStepInputSectionState();
}

class InstructionStepInputSectionState
    extends State<InstructionStepInputSection> {
  final _instructionController = TextEditingController();
  final _noteController = TextEditingController();
  final List<String> _selectedTags = [];

  static const _quickTags = [
    '# Chef Tip', '# Note', '# Low Heat', '# High Heat', '# Simmer', '# Technique',
  ];

  @override
  void dispose() {
    _instructionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool commitPending() {
    final inst = _instructionController.text.trim();
    final note = _noteController.text.trim();
    if (inst.isEmpty && note.isEmpty && _selectedTags.isEmpty) return false;
    _handleAdd();
    return true;
  }

  void _handleAdd() {
    final inst = _instructionController.text.trim();
    final note = _noteController.text.trim();
    if (inst.isEmpty && note.isEmpty) return;

    final effectiveInst = inst.isNotEmpty ? inst : note;
    final effectiveNote = inst.isNotEmpty ? (note.isNotEmpty ? note : null) : null;
    final formatted = InstructionStepData.format(
      instruction: effectiveInst,
      note: effectiveNote,
      tags: _selectedTags,
    );
    widget.onAdd(formatted);
    setState(() {
      _instructionController.clear();
      _noteController.clear();
      _selectedTags.clear();
    });
  }

  void _toggleQuickTag(String tag) {
    setState(() {
      _selectedTags.contains(tag) ? _selectedTags.remove(tag) : _selectedTags.add(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.format_list_numbered_rounded, size: AppIconSize.s18, color: AppColors.primary),
          AppSpacing.gapW8,
          Expanded(
            child: Text(
              'Instructions / Steps (${widget.items.length})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getBoldStyle(context: context, fontSize: FontSize.s14),
            ),
          ),
        ]),
        AppSpacing.gapH4,
        Text('Add cooking steps with optional "#" notes, tags, or temperature tips', style: getRegularStyle(context: context, fontSize: FontSize.s12, color: secColor)),
        AppSpacing.gapH8,
        _buildInputCard(context, isDark),
        if (widget.items.isNotEmpty) ...[
          AppSpacing.gapH12,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            separatorBuilder: (_, _) => AppSpacing.gapH8,
            itemBuilder: (context, index) => InstructionStepTile(
              index: index,
              rawStep: widget.items[index],
              onRemove: () => widget.onRemove(index),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputCard(BuildContext context, bool isDark) {
    final tagColor = isDark ? AppColors.secondaryLight : AppColors.secondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _instructionController,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _handleAdd(),
            decoration: InputDecoration(
              hintText: 'Step instruction (e.g. Crisp guanciale in pan)',
              prefixIcon: Icon(Icons.menu_book_rounded, size: AppIconSize.s18, color: AppColors.primary),
              border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            ),
          ),
          Divider(height: 1.h, color: borderColor),
          TextField(
            controller: _noteController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleAdd(),
            decoration: InputDecoration(
              hintText: 'Optional note / #tag (e.g. # Chef Tip: Render slowly)',
              prefixIcon: Icon(Icons.tag_rounded, size: AppIconSize.s18, color: tagColor),
              border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            ),
          ),
          AppSpacing.gapH8,
          Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            children: _quickTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                selected: isSelected,
                showCheckmark: true,
                checkmarkColor: Colors.white,
                selectedColor: tagColor,
                label: Text(tag, style: getMediumStyle(fontSize: FontSize.s11, color: isSelected ? Colors.white : tagColor)),
                backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                side: BorderSide(color: tagColor.withValues(alpha: 0.35)),
                onSelected: (_) => _toggleQuickTag(tag),
              );
            }).toList(),
          ),
          AppSpacing.gapH8,
          ElevatedButton.icon(
            onPressed: _handleAdd,
            icon: Icon(Icons.add_rounded, size: AppIconSize.s18),
            label: const Text('Add Step to Recipe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }
}
