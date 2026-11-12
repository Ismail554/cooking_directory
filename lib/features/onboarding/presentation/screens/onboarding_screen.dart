import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/asset_manager.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/onboarding_slide_card.dart';

/// Multi-step culinary Onboarding Screen that leads unauthenticated users to AuthScreen.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      badge: 'Culinary Vault',
      title: 'Curate Your Signature Recipes',
      description:
          'Organize ingredients, step-by-step instructions with #chef-tip tags, and import or export recipes via CSV.',
      svgAsset: AssetManager.svgChefHat,
      fallbackIcon: Icons.menu_book_rounded,
      accentColor: AppColors.primary,
    ),
    OnboardingSlideData(
      badge: 'Hands-Free Kitchen',
      title: 'Interactive Step-by-Step Cooking Mode',
      description:
          'Follow distraction-free cooking steps with highlighted chef notes, live progress tracking, and kitchen timers.',
      svgAsset: AssetManager.svgCookingPot,
      fallbackIcon: Icons.soup_kitchen_rounded,
      accentColor: AppColors.secondary,
    ),
    OnboardingSlideData(
      badge: 'Smart Budgeting',
      title: 'Track Monthly Food & Grocery Expenses',
      description:
          'Monitor grocery runs, spices, kitchen tools, and dining out against your customizable monthly food budget.',
      svgAsset: AssetManager.svgChefHat,
      fallbackIcon: Icons.account_balance_wallet_rounded,
      accentColor: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() => context.go(AppRoutePaths.auth);

  void _nextSlide() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentIndex == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: AppIconSize.s20),
                        AppSpacing.gapW8,
                        Flexible(
                          child: Text(
                            'Cooking Directory',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getBoldStyle(context: context, fontSize: FontSize.s14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: getSemiBoldStyle(
                        fontSize: FontSize.s14,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (_, index) => OnboardingSlideCard(data: _slides[index]),
              ),
            ),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final active = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 8.h,
                        width: active ? 26.w : 8.w,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          borderRadius: AppBorderRadius.circular,
                        ),
                      );
                    }),
                  ),
                  AppSpacing.gapH24,
                  AppButton(
                    text: isLast ? 'Get Started' : 'Next',
                    icon: isLast ? Icons.login_rounded : Icons.arrow_forward_rounded,
                    onPressed: _nextSlide,
                  ),
                  AppSpacing.gapH8,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
