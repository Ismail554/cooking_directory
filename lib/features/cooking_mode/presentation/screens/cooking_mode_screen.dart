import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';
import 'package:cooking_directory/features/cooking_mode/presentation/widgets/cooking_celebration_dialog.dart';
import 'package:cooking_directory/features/recipes/data/datasources/recipe_local_datasource.dart';

/// Safe platform channel wrapper for screen wakelock in cooking mode.
class WakelockPlus {
  static const MethodChannel _ch = MethodChannel('wakelock_plus');
  static Future<void> enable() async { try { await _ch.invokeMethod<void>('toggle', {'enable': true}); } catch (_) {} }
  static Future<void> disable() async { try { await _ch.invokeMethod<void>('toggle', {'enable': false}); } catch (_) {} }
}

/// Interactive step-by-step cooking mode screen with wakelock and timers.
class CookingModeScreen extends StatefulWidget {
  const CookingModeScreen({super.key, this.recipeId, this.title});
  final String? recipeId, title;

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _currentStep = 0;
  List<String> _steps = const [
    'Gather and prep all fresh ingredients, seasonings, and utensils.',
    'Heat cooking oil in a skillet over medium-high heat until hot.',
    'Sear the main ingredients evenly on all sides until golden.',
    'Simmer with sauce and herbs, adjust seasoning, and serve warm.',
  ];

  @override
  void initState() {
    super.initState();
    try { WakelockPlus.enable(); } catch (_) {}
    _loadRecipeSteps();
  }

  @override
  void dispose() {
    try { WakelockPlus.disable(); } catch (_) {}
    super.dispose();
  }

  Future<void> _loadRecipeSteps() async {
    try {
      final recipes = await const RecipeLocalDataSourceImpl().getSeedRecipes();
      final match = recipes.firstWhere(
        (r) => r.id == widget.recipeId || (widget.recipeId == null && r.title == widget.title),
        orElse: () => recipes.first,
      );
      if (mounted && match.steps.isNotEmpty) setState(() => _steps = match.steps);
    } catch (_) {}
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _showFinishDialog();
    }
  }

  void _showFinishDialog() {
    CookingCelebrationDialog.show(context, title: widget.title);
  }

  void _showTimerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
        title: Row(children: [
          const Icon(Icons.timer_outlined, color: AppColors.primary),
          AppSpacing.gapW8,
          Flexible(child: Text('Quick Timer', style: getBoldStyle(context: context, fontSize: FontSize.s18))),
        ]),
        content: Text('Step ${_currentStep + 1} timer: 5 minutes.', style: getRegularStyle(context: context, fontSize: FontSize.s14)),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final totalSteps = _steps.length;
    final progress = (_currentStep + 1) / totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Cooking Mode', style: getBoldStyle(context: context, fontSize: FontSize.s18, color: onSurface)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close_rounded), tooltip: 'Exit', onPressed: () => context.pop()),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.s12),
            child: ActionChip(
              avatar: Image.asset(AssetManager.icTimer, width: 16.r, height: 16.r, errorBuilder: (_, _, _) => const Icon(Icons.timer_outlined, size: 16, color: AppColors.primary)),
              label: Text('Timers', style: getMediumStyle(context: context, fontSize: FontSize.s12, color: AppColors.primary)),
              backgroundColor: AppColors.primaryContainer,
              side: BorderSide.none,
              onPressed: _showTimerDialog,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: AppBorderRadius.r8,
                child: LinearProgressIndicator(value: progress, minHeight: 8.h, backgroundColor: theme.colorScheme.surfaceContainerHighest, valueColor: const AlwaysStoppedAnimation(AppColors.primary)),
              ),
              AppSpacing.gapH12,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Step ${_currentStep + 1} of $totalSteps', maxLines: 1, overflow: TextOverflow.ellipsis, style: getSemiBoldStyle(context: context, fontSize: FontSize.s14, color: AppColors.primary)),
                  ),
                  AppSpacing.gapW8,
                  Text('${(progress * 100).round()}% Completed', style: getRegularStyle(context: context, fontSize: FontSize.s12, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              AppSpacing.gapH24,
              Expanded(
                child: Card(
                  elevation: AppElevation.e2,
                  shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.s8),
                            decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                            child: Text('${_currentStep + 1}', style: getBoldStyle(context: context, fontSize: FontSize.s16, color: AppColors.primary)),
                          ),
                          AppSpacing.gapW12,
                          Expanded(child: Text('Instruction', style: getBoldStyle(context: context, fontSize: FontSize.s16, color: onSurface))),
                          SvgPicture.asset(AssetManager.svgCookingPot, width: 22.r, height: 22.r),
                        ]),
                        AppSpacing.gapH16,
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(_steps[_currentStep], style: getRegularStyle(context: context, fontSize: FontSize.s16, height: 1.5, color: onSurface)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppSpacing.gapH24,
              Row(children: [
                if (_currentStep > 0) ...[
                  Expanded(child: AppButton(text: 'Previous', isOutlined: true, onPressed: () => setState(() => _currentStep--))),
                  AppSpacing.gapW16,
                ],
                Expanded(
                  child: AppButton(
                    text: _currentStep == totalSteps - 1 ? 'Finish' : 'Next Step',
                    icon: _currentStep == totalSteps - 1 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                    onPressed: _nextStep,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
