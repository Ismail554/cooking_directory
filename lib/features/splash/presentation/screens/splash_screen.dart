import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/asset_manager.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/string_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_themed_background.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

/// Branded entry Splash Screen with staggered culinary animations and auth routing:
/// - If logged in -> HomeScreen (`/`)
/// - If not logged in -> OnboardingScreen (`/onboarding`) -> AuthScreen (`/auth`)
class SplashScreen extends StatefulWidget {
  final Duration delay;
  const SplashScreen({super.key, this.delay = const Duration(milliseconds: 1200)});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.84, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack)),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );
    _controller.forward();
    _navTimer = Timer(widget.delay, _resolveNextRoute);
  }

  void _resolveNextRoute() {
    if (!mounted) return;
    final isLoggedIn = context.read<AuthProvider?>()?.isAuthenticated ?? false;
    context.go(isLoggedIn ? AppRoutePaths.home : AppRoutePaths.onboarding);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryTone = isDark ? AppColors.primaryLight : AppColors.primary;

    return AppThemedBackground(
      imageOpacity: 1.0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: (constraints.maxHeight - 32.h).clamp(0.0, double.infinity)),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTopBadge(isDark, primaryTone),
                      AppSpacing.gapH16,
                      SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(scale: _scaleAnim, child: _buildHeroEmblem(isDark)),
                            AppSpacing.gapH24,
                            Text(StringManager.appName, textAlign: TextAlign.center, style: getBoldStyle(context: context, fontSize: FontSize.s28, letterSpacing: -0.5)),
                            AppSpacing.gapH8,
                            Text(StringManager.appTagline, textAlign: TextAlign.center, style: getRegularStyle(context: context, fontSize: FontSize.s14, color: secColor)),
                            AppSpacing.gapH16,
                            _buildFeaturePills(isDark),
                          ],
                        ),
                      ),
                      AppSpacing.gapH16,
                      _buildProgressCard(context, isDark, secColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBadge(bool isDark, Color primaryTone) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withValues(alpha: 0.85),
        borderRadius: AppBorderRadius.r20,
        border: Border.all(color: primaryTone.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AssetManager.svgChefHat, width: 16.r, height: 16.r),
          AppSpacing.gapW8,
          Text('CULINARY STUDIO & VAULT', style: getBoldStyle(fontSize: FontSize.s10, color: primaryTone, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildHeroEmblem(bool isDark) {
    return Container(
      width: 132.r,
      height: 132.r,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.10),
        border: Border.all(color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.22), width: 1.5),
      ),
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [AppColors.glowingOrangeShadow]),
        child: ClipOval(
          child: Image.asset(AssetManager.appLogo, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(Icons.restaurant_menu_rounded, size: AppIconSize.s48, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildFeaturePills(bool isDark) {
    const items = ['Smart Recipes', 'Step Timers', 'Budget Sync'];
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      alignment: WrapAlignment.center,
      children: items.map((label) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceLight).withValues(alpha: 0.85),
          borderRadius: AppBorderRadius.r12,
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Text(label, style: getMediumStyle(context: context, fontSize: FontSize.s11)),
      )).toList(),
    );
  }

  Widget _buildProgressCard(BuildContext context, bool isDark, Color secColor) {
    return Container(
      constraints: BoxConstraints(maxWidth: 280.w),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withValues(alpha: 0.88),
        borderRadius: AppBorderRadius.r16,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: const [AppColors.culinaryCardShadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 16.r, height: 16.r, child: const CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
          AppSpacing.gapW8,
          Flexible(child: Text('Preparing your culinary workspace...', maxLines: 1, overflow: TextOverflow.ellipsis, style: getMediumStyle(context: context, fontSize: FontSize.s12, color: secColor))),
        ],
      ),
    );
  }
}
