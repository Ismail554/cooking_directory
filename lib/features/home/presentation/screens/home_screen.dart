import 'package:flutter/material.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cooking Directory',
              style: getBoldStyle(
                fontSize: FontSize.s18,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'What do you want to cook today?',
              style: getRegularStyle(
                fontSize: FontSize.s12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            _buildSearchBar(),
            AppSpacing.gapH20,
            _buildSectionHeader('Categories', onViewAll: () {}),
            AppSpacing.gapH12,
            _buildCategoryList(),
            AppSpacing.gapH24,
            _buildSectionHeader('Popular Recipes', onViewAll: () {}),
            AppSpacing.gapH12,
            _buildPopularRecipeCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Recipe',
          style: getSemiBoldStyle(
            fontSize: FontSize.s14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search recipes, ingredients...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        suffixIcon: const Icon(Icons.tune_rounded),
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
            style: getBoldStyle(fontSize: FontSize.s16),
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

  Widget _buildCategoryList() {
    final categories = ['Breakfast', 'Lunch', 'Dinner', 'Desserts', 'Healthy'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => AppSpacing.gapW8,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Chip(
            backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceVariantLight,
            label: Text(
              categories[index],
              style: getMediumStyle(
                fontSize: FontSize.s13,
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r20),
          );
        },
      ),
    );
  }

  Widget _buildPopularRecipeCard() {
    return Card(
      elevation: AppElevation.e1,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppBorderRadius.r12,
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            AppSpacing.gapH12,
            Text(
              'Creamy Tuscan Garlic Chicken',
              style: getBoldStyle(fontSize: FontSize.s16),
            ),
            AppSpacing.gapH4,
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondaryLight),
                AppSpacing.gapW4,
                Text(
                  '30 mins',
                  style: getRegularStyle(fontSize: FontSize.s12, color: AppColors.textSecondaryLight),
                ),
                AppSpacing.gapW16,
                const Icon(Icons.local_fire_department_outlined, size: 16, color: AppColors.primary),
                AppSpacing.gapW4,
                Text(
                  '450 kcal',
                  style: getRegularStyle(fontSize: FontSize.s12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
