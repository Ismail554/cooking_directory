import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

/// Interactive culinary search bar with clear button and dietary filter action.
class HomeSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;
  final String hintText;

  const HomeSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onClear,
    this.hintText = 'Search recipes, ingredients...',
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _internalController;
  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _showClear = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(HomeSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChange);
      _effectiveController.addListener(_onTextChange);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onTextChange);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onTextChange() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (_showClear != hasText) {
      setState(() => _showClear = hasText);
    }
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppBorderRadius.r16,
        boxShadow: const [AppColors.culinaryCardShadow],
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : AppColors.borderLight.withValues(alpha: 0.6),
          width: 1.w,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: AppIconSize.s24,
          ),
          AppSpacing.gapW8,
          Expanded(
            child: TextField(
              controller: _effectiveController,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: getMediumStyle(
                context: context,
                fontSize: FontSize.s14,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: getRegularStyle(
                  context: context,
                  fontSize: FontSize.s14,
                  color: isDark
                      ? AppColors.textHintDark
                      : AppColors.textHintLight,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          if (_showClear)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: AppIconSize.s18,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
              onPressed: _handleClear,
              tooltip: 'Clear search',
            ),
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              size: AppIconSize.s20,
              color: AppColors.primary,
            ),
            onPressed: widget.onFilterTap,
            tooltip: 'Filter recipes',
          ),
        ],
      ),
    );
  }
}
