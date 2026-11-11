import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';

/// Main navigation shell managing persistent bottom navigation with [GoRouter].
/// Index 0: Expenses, Index 1: Recipes (Home), Index 2: Profile.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildImageIcon({
    required String assetPath,
    required IconData fallbackIcon,
    required Color color,
    double size = 24,
  }) {
    return Image.asset(
      assetPath,
      width: size.r,
      height: size.r,
      color: color,
      errorBuilder: (_, _, _) => Icon(
        fallbackIcon,
        size: size.r,
        color: color,
      ),
    );
  }

  Widget _buildAvatarIcon({
    required Color fallbackColor,
    bool isSelected = false,
  }) {
    final image = ClipOval(
      child: Image.asset(
        AssetManager.userAvatar,
        width: isSelected ? 22.r : 24.r,
        height: isSelected ? 22.r : 24.r,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          isSelected ? Icons.person_rounded : Icons.person_outline_rounded,
          size: isSelected ? 22.r : 24.r,
          color: fallbackColor,
        ),
      ),
    );

    if (!isSelected) return image;

    return Container(
      padding: EdgeInsets.all(1.5.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2.r,
        ),
      ),
      child: image,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unselectedColor = theme.colorScheme.onSurfaceVariant;
    final isHomeTab = navigationShell.currentIndex == 1;

    return PopScope(
      canPop: isHomeTab,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!isHomeTab) {
          _onDestinationSelected(1);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          indicatorColor: AppColors.primaryContainer,
          destinations: [
            NavigationDestination(
              icon: _buildImageIcon(
                assetPath: AssetManager.icExpense,
                fallbackIcon: Icons.account_balance_wallet_outlined,
                color: unselectedColor,
              ),
              selectedIcon: _buildImageIcon(
                assetPath: AssetManager.icExpense,
                fallbackIcon: Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
              ),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: _buildImageIcon(
                assetPath: AssetManager.icRecipe,
                fallbackIcon: Icons.restaurant_menu_rounded,
                color: unselectedColor,
              ),
              selectedIcon: _buildImageIcon(
                assetPath: AssetManager.icRecipe,
                fallbackIcon: Icons.restaurant_menu_rounded,
                color: AppColors.primary,
              ),
              label: 'Recipes',
            ),
            NavigationDestination(
              icon: _buildAvatarIcon(
                fallbackColor: unselectedColor,
                isSelected: false,
              ),
              selectedIcon: _buildAvatarIcon(
                fallbackColor: AppColors.primary,
                isSelected: true,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
