import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/routing/route_paths.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';
import 'package:cooking_directory/core/widgets/app_themed_background.dart';
import 'package:cooking_directory/core/widgets/custom_snackbar.dart';
import 'package:cooking_directory/core/widgets/recipe_image_view.dart';
import 'package:cooking_directory/features/recipes/data/datasources/recipe_local_datasource.dart';
import 'package:cooking_directory/features/recipes/domain/entities/recipe.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_provider.dart';
import 'package:cooking_directory/features/recipes/presentation/widgets/ingredients_checklist.dart';
import 'package:cooking_directory/features/recipes/presentation/widgets/instructions_timeline.dart';
import 'package:cooking_directory/features/recipes/presentation/widgets/recipe_stats_bar.dart';

/// Rich culinary recipe details screen featuring sliver hero header,
/// responsive stats summary, interactive ingredients, and step timeline.
class RecipeDetailsScreen extends StatefulWidget {
  const RecipeDetailsScreen({super.key, this.recipeId, this.title = 'Recipe Details'});
  final String? recipeId;
  final String title;

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late Recipe _recipe;
  bool _isFavorite = true;

  static final Recipe _defaultRecipe = Recipe(
    id: 'recipe_001',
    title: 'Creamy Tuscan Garlic Chicken',
    description: 'Tender chicken breasts in a rich garlic, sun-dried tomato, and spinach cream sauce.',
    category: 'Dinner',
    prepTimeMinutes: 15,
    cookTimeMinutes: 20,
    servings: 4,
    calories: 450,
    difficulty: 'Medium',
    ingredients: const [
      '2 chicken breasts', '3 cloves garlic minced', '1 cup heavy cream',
      '1/2 cup chicken broth', '1/2 cup sun-dried tomatoes', '2 cups baby spinach',
      '1/4 cup parmesan cheese', '1 tbsp olive oil',
    ],
    steps: const [
      'Season chicken with salt, pepper, and Italian herbs.',
      'Heat olive oil in skillet and sear chicken 6 minutes per side.',
      'Sauté garlic, sun-dried tomatoes, and chicken broth.',
      'Pour heavy cream, simmer with spinach and parmesan cheese.',
      'Return chicken to skillet and simmer 3 minutes before serving.',
    ],
    isFavorite: true,
    createdAt: DateTime(2026, 1, 15),
  );

  @override
  void initState() {
    super.initState();
    _recipe = _defaultRecipe;
    _isFavorite = _recipe.isFavorite;
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    try {
      final provider = context.read<RecipeProvider?>();
      if (provider != null) {
        if (widget.recipeId != null) {
          final fetched = await provider.getRecipeById(widget.recipeId!);
          if (mounted) setState(() { _recipe = fetched; _isFavorite = _recipe.isFavorite; });
          return;
        }
        if (provider.allRecipes.isNotEmpty) {
          final match = provider.allRecipes.firstWhere(
            (r) => r.id == widget.recipeId || (widget.recipeId == null && r.title == widget.title),
            orElse: () => provider.allRecipes.first,
          );
          if (mounted) setState(() { _recipe = match; _isFavorite = _recipe.isFavorite; });
          return;
        }
      }
      final recipes = await const RecipeLocalDataSourceImpl().getSeedRecipes();
      final match = recipes.firstWhere(
        (r) => r.id == widget.recipeId || (widget.recipeId == null && r.title == widget.title),
        orElse: () => recipes.first,
      );
      if (mounted) setState(() { _recipe = match.toEntity(); _isFavorite = _recipe.isFavorite; });
    } catch (_) {}
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    context.read<RecipeProvider?>()?.toggleFavorite(_recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return AppThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.h,
            pinned: true,
            leading: _buildCircleAction(icon: Icons.arrow_back_rounded, onTap: () => context.pop()),
            actions: [
              _buildCircleAction(
                icon: _isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                iconColor: _isFavorite ? AppColors.accent : Colors.white,
                onTap: _toggleFavorite,
              ),
              AppSpacing.gapW12,
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  RecipeImageView(imageSource: _recipe.imageUrl, fallbackAsset: AssetManager.recipePlaceholder, fit: BoxFit.cover),
                  const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.heroOverlayGradient)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_recipe.title, style: getBoldStyle(context: context, fontSize: FontSize.s22, color: onSurface)),
                  if (_recipe.subtitle.isNotEmpty) ...[
                    AppSpacing.gapH4,
                    Text(_recipe.subtitle, style: getMediumStyle(context: context, fontSize: FontSize.s14, color: AppColors.primary)),
                  ],
                  AppSpacing.gapH8,
                  Text(_recipe.description, style: getRegularStyle(context: context, fontSize: FontSize.s14, height: 1.45, color: theme.colorScheme.onSurfaceVariant)),
                  AppSpacing.gapH16,
                  RecipeStatsBar(prepTimeMinutes: _recipe.prepTimeMinutes, cookTimeMinutes: _recipe.cookTimeMinutes, calories: _recipe.calories, rating: 4.8, difficulty: _recipe.difficulty),
                  AppSpacing.gapH24,
                  IngredientsChecklist(ingredients: _recipe.ingredients, initialServings: _recipe.servings),
                  AppSpacing.gapH24,
                  InstructionsTimeline(
                    steps: _recipe.steps,
                    onStartTimer: (idx, mins) => CustomSnackbar.showSuccess(context, 'Started $mins min timer for Step ${idx + 1}'),
                  ),
                  AppSpacing.gapH32,
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s12),
          child: AppButton(
            text: 'Start Cooking Mode',
            icon: Icons.play_arrow_rounded,
            gradient: AppColors.primaryGradient,
            boxShadow: const [AppColors.glowingOrangeShadow],
            onPressed: () {
              final encTitle = Uri.encodeComponent(_recipe.title);
              context.push('${AppRoutePaths.cookingMode}?id=${_recipe.id}&title=$encTitle');
            },
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCircleAction({required IconData icon, Color iconColor = Colors.white, required VoidCallback onTap}) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.circular,
        child: Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
          child: Icon(icon, size: AppIconSize.s20, color: iconColor),
        ),
      ),
    );
  }
}
