import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/routing/route_paths.dart';
import 'package:cooking_directory/core/widgets/app_empty_view.dart';
import 'package:cooking_directory/core/widgets/app_loading_view.dart';
import 'package:cooking_directory/features/home/presentation/widgets/featured_recipe_card.dart';
import 'package:cooking_directory/features/home/presentation/widgets/home_category_pills.dart';
import 'package:cooking_directory/features/home/presentation/widgets/home_header.dart';
import 'package:cooking_directory/features/home/presentation/widgets/home_search_bar.dart';
import 'package:cooking_directory/features/home/presentation/widgets/recipe_grid_card.dart';

/// Modernized Discover & Recipe Feed Screen adhering strictly to Clean Architecture.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isRefreshing = false);
  }

  bool get _hasRecipesInSelectedCategory {
    if (_selectedCategory == 'All') return true;
    if (_selectedCategory == 'Dinner' || _selectedCategory == 'Lunch') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              const HomeHeader(),
              AppSpacing.gapH16,
              HomeSearchBar(onFilterTap: () {}),
              AppSpacing.gapH16,
              HomeCategoryPills(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
              ),
              AppSpacing.gapH20,
              if (_isRefreshing) ...[
                const SizedBox(
                  height: 140,
                  child: AppLoadingView(message: 'Simmering fresh recipes...'),
                ),
              ] else if (!_hasRecipesInSelectedCategory) ...[
                AppEmptyView(
                  title: 'No Recipes in $_selectedCategory',
                  message: 'No recipes found in this category yet. Tap below to create your first $_selectedCategory recipe!',
                  actionLabel: 'Add Recipe',
                  onAction: () => context.push(AppRoutePaths.addRecipe),
                ),
              ] else ...[
                _buildSectionHeader('Featured Recipe', onViewAll: () {}),
                AppSpacing.gapH12,
                const FeaturedRecipeCard(),
                AppSpacing.gapH20,
                _buildSectionHeader('Popular Recipes', onViewAll: () {}),
                AppSpacing.gapH12,
                Row(
                  children: [
                    const Expanded(
                      child: RecipeGridCard(
                        recipeId: 'recipe_002',
                        title: 'Beef Bolognese',
                        prepTime: '20 min',
                        calories: 550,
                        rating: 4.8,
                      ),
                    ),
                    AppSpacing.gapW12,
                    const Expanded(
                      child: RecipeGridCard(
                        recipeId: 'recipe_003',
                        title: 'Quinoa Salad',
                        prepTime: '15 min',
                        calories: 320,
                        rating: 4.7,
                      ),
                    ),
                  ],
                ),
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
        label: Text(
          'New Recipe',
          style: getSemiBoldStyle(fontSize: FontSize.s14, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: getBoldStyle(context: context, fontSize: FontSize.s16),
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'View All',
              style: getSemiBoldStyle(
                fontSize: FontSize.s13,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
