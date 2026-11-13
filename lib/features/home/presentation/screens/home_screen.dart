import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/asset_manager.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_themed_background.dart';
import '../../../../core/widgets/recipe_image_view.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../recipes/data/datasources/recipe_seed_data.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/presentation/providers/recipe_provider.dart';
import '../widgets/featured_recipe_card.dart';
import '../widgets/home_category_pills.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/recipe_grid_card.dart';

/// Modernized Discover & Recipe Feed Screen adhering strictly to Clean Architecture.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider?>();
    final authProvider = context.watch<AuthProvider?>();
    final user = authProvider?.currentUser;
    final greeting = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? 'Hello, ${user.displayName}'
        : 'Hello, Chef Ismail';

    final recipes = recipeProvider != null
        ? recipeProvider.filteredRecipes
        : kSeedRecipes.map((e) => e.toEntity()).toList();
    final selectedCategory = recipeProvider?.selectedCategory ?? 'All';
    final isLoading = recipeProvider?.isLoading ?? false;

    final Recipe? featured = recipes.isNotEmpty ? recipes.first : null;
    final otherRecipes = recipes.length > 1 ? recipes.sublist(1) : <Recipe>[];
    final popularRecipes = otherRecipes.take(2).toList();
    final moreRecipes = otherRecipes.length > 2 ? otherRecipes.sublist(2) : <Recipe>[];

    return AppThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => recipeProvider?.loadRecipes(),
          color: AppColors.primary,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              HomeHeader(greeting: greeting, onAvatarTap: () => context.go(AppRoutePaths.profile)),
              AppSpacing.gapH16,
              HomeSearchBar(
                hasActiveFilter: selectedCategory != 'All',
                onChanged: (val) => recipeProvider?.setSearchQuery(val),
                onFilterTap: () => recipeProvider?.setCategory('All'),
              ),
              AppSpacing.gapH16,
              HomeCategoryPills(selectedCategory: selectedCategory, onCategorySelected: (cat) => recipeProvider?.setCategory(cat)),
              AppSpacing.gapH20,
              if (isLoading && recipes.isEmpty) ...[
                const SizedBox(height: 140, child: AppLoadingView(message: 'Simmering fresh recipes...')),
              ] else if (recipes.isEmpty) ...[
                AppEmptyView(
                  title: 'No Recipes Found',
                  message: 'No recipes match "$selectedCategory". Tap below to add or import your first recipe!',
                  actionLabel: 'Add Recipe',
                  onAction: () => context.push(AppRoutePaths.addRecipe),
                ),
              ] else ...[
                if (featured != null) ...[
                  _buildSectionHeader(context, 'Featured Recipe'),
                  AppSpacing.gapH12,
                  FeaturedRecipeCard(
                    recipeId: featured.id,
                    title: featured.title,
                    description: featured.subtitle.isNotEmpty ? featured.subtitle : featured.description,
                    prepTime: '${featured.prepTimeMinutes + featured.cookTimeMinutes} min',
                    difficulty: featured.difficulty,
                    imageAsset: featured.imageUrl.isNotEmpty ? featured.imageUrl : AssetManager.recipePlaceholder,
                    isFavorite: featured.isFavorite,
                    onTap: () => context.push('${AppRoutePaths.recipeDetails}?id=${featured.id}'),
                    onFavoriteToggle: (_) => recipeProvider?.toggleFavorite(featured.id),
                  ),
                  AppSpacing.gapH20,
                ],
                if (popularRecipes.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Popular Recipes'),
                  AppSpacing.gapH12,
                  Row(
                    children: [
                      for (int i = 0; i < popularRecipes.length; i++) ...[
                        if (i > 0) AppSpacing.gapW12,
                        Expanded(
                          child: RecipeGridCard(
                            recipeId: popularRecipes[i].id,
                            title: popularRecipes[i].title,
                            prepTime: '${popularRecipes[i].prepTimeMinutes} min',
                            calories: popularRecipes[i].calories,
                            rating: 4.8,
                            imageAsset: popularRecipes[i].imageUrl.isNotEmpty ? popularRecipes[i].imageUrl : AssetManager.recipePlaceholder,
                            onTap: () => context.push('${AppRoutePaths.recipeDetails}?id=${popularRecipes[i].id}'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (moreRecipes.isNotEmpty) ...[
                  AppSpacing.gapH20,
                  _buildSectionHeader(context, 'More Culinary Recipes'),
                  AppSpacing.gapH12,
                  ...moreRecipes.map((r) => _buildCompactRecipeTile(context, r)),
                ],
              ],
              AppSpacing.gapH48,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutePaths.addRecipe),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New Recipe', style: getSemiBoldStyle(fontSize: FontSize.s14, color: Colors.white)),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title, style: getBoldStyle(context: context, fontSize: FontSize.s16));
  }

  Widget _buildCompactRecipeTile(BuildContext context, Recipe recipe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        onTap: () => context.push('${AppRoutePaths.recipeDetails}?id=${recipe.id}'),
        borderRadius: AppBorderRadius.r12,
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppBorderRadius.r12,
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppBorderRadius.r12,
                child: SizedBox(
                  width: 44.r,
                  height: 44.r,
                  child: recipe.imageUrl.isNotEmpty
                      ? RecipeImageView(imageSource: recipe.imageUrl, fit: BoxFit.cover)
                      : Container(color: AppColors.primaryContainer, child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary)),
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: getBoldStyle(context: context, fontSize: FontSize.s14)),
                    AppSpacing.gapH2,
                    Text(
                      '${recipe.category} • ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min • ${recipe.calories} kcal',
                      style: getRegularStyle(
                        context: context,
                        fontSize: FontSize.s12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
