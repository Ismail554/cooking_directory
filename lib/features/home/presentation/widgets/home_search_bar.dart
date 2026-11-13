import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

/// Refined, focus-aware culinary search bar with animated border highlight,
/// clear action, and styled filter button.
class HomeSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;
  final String hintText;
  final bool hasActiveFilter;

  const HomeSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onClear,
    this.hintText = 'Search recipes, ingredients...',
    this.hasActiveFilter = false,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool _showClear = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _showClear = _effectiveController.text.isNotEmpty;
    _isFocused = _effectiveFocusNode.hasFocus;
    _effectiveController.addListener(_onTextChange);
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(HomeSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(_onTextChange);
      _effectiveController.addListener(_onTextChange);
      _showClear = _effectiveController.text.isNotEmpty;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(_onFocusChange);
      _effectiveFocusNode.addListener(_onFocusChange);
      _isFocused = _effectiveFocusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onTextChange);
    _effectiveFocusNode.removeListener(_onFocusChange);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _onTextChange() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (_showClear != hasText && mounted) setState(() => _showClear = hasText);
  }

  void _onFocusChange() {
    final focused = _effectiveFocusNode.hasFocus;
    if (_isFocused != focused && mounted) setState(() => _isFocused = focused);
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTone = isDark ? AppColors.primaryLight : AppColors.primary;
    final borderColor = _isFocused ? primaryTone : (isDark ? AppColors.borderDark : AppColors.borderLight.withValues(alpha: 0.75));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: isDark ? 0.94 : 0.98),
        borderRadius: AppBorderRadius.r16,
        boxShadow: [_isFocused ? AppColors.glowingOrangeShadow : AppColors.culinaryCardShadow],
        border: Border.all(color: borderColor, width: _isFocused ? 1.5.w : 1.w),
      ),
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 6.w, 4.h),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: primaryTone.withValues(alpha: _isFocused ? 0.16 : 0.10), borderRadius: AppBorderRadius.r12),
            child: Icon(Icons.search_rounded, color: primaryTone, size: AppIconSize.s20),
          ),
          AppSpacing.gapW8,
          Expanded(
            child: TextField(
              controller: _effectiveController,
              focusNode: _effectiveFocusNode,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTapOutside: (_) => _effectiveFocusNode.unfocus(),
              style: getMediumStyle(context: context, fontSize: FontSize.s14),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: getRegularStyle(
                  context: context,
                  fontSize: FontSize.s13,
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: _showClear
                ? IconButton(
                    key: const ValueKey('search_clear_btn'),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close_rounded, size: AppIconSize.s18, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                    onPressed: _handleClear,
                    tooltip: 'Clear search',
                  )
                : const SizedBox.shrink(),
          ),
          Container(width: 1, height: 22.h, margin: EdgeInsets.symmetric(horizontal: 4.w), color: isDark ? AppColors.borderDark : AppColors.borderLight),
          _FilterIconButton(primaryTone: primaryTone, hasActiveFilter: widget.hasActiveFilter, onTap: widget.onFilterTap),
        ],
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  final Color primaryTone;
  final bool hasActiveFilter;
  final VoidCallback? onTap;
  const _FilterIconButton({required this.primaryTone, required this.hasActiveFilter, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: hasActiveFilter ? primaryTone.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: AppBorderRadius.r12,
          child: IconButton(visualDensity: VisualDensity.compact, icon: Icon(Icons.tune_rounded, size: AppIconSize.s20, color: primaryTone), onPressed: onTap, tooltip: 'Filter recipes'),
        ),
        if (hasActiveFilter)
          Positioned(
            right: 6.r,
            top: 6.r,
            child: Container(
              width: 7.r,
              height: 7.r,
              decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).cardColor, width: 1.2)),
            ),
          ),
      ],
    );
  }
}
