import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';

class DynamicListInputSection extends StatefulWidget {
  final String title;
  final String hintText;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;
  final bool isNumbered;

  const DynamicListInputSection({
    super.key,
    required this.title,
    required this.hintText,
    required this.icon,
    required this.items,
    required this.onAdd,
    required this.onRemove,
    this.isNumbered = false,
  });

  @override
  State<DynamicListInputSection> createState() =>
      DynamicListInputSectionState();
}

class DynamicListInputSectionState extends State<DynamicListInputSection> {
  final _controller = TextEditingController();

  /// Commits any pending text in the input field into the list.
  bool commitPending() {
    final text = _controller.text.trim();
    if (text.isEmpty) return false;
    _handleAdd();
    return true;
  }

  void _handleAdd() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, size: AppIconSize.s18, color: AppColors.primary),
            AppSpacing.gapW8,
            Text(
              '${widget.title} (${widget.items.length})',
              style: getBoldStyle(context: context, fontSize: FontSize.s14),
            ),
          ],
        ),
        AppSpacing.gapH8,
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleAdd(),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.r12,
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.gapW8,
            IconButton.filled(
              onPressed: _handleAdd,
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.r12,
                ),
              ),
            ),
          ],
        ),
        if (widget.items.isNotEmpty) ...[
          AppSpacing.gapH8,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            separatorBuilder: (_, _) => AppSpacing.gapH4,
            itemBuilder: (context, index) {
              final prefix = widget.isNumbered ? '${index + 1}. ' : '• ';
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariantLight,
                  borderRadius: AppBorderRadius.r8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$prefix${widget.items[index]}',
                        style: getRegularStyle(
                          context: context,
                          fontSize: FontSize.s13,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => widget.onRemove(index),
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
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
            },
          ),
        ],
      ],
    );
  }
}
