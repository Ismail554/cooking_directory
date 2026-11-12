import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../../../authentication/presentation/providers/auth_provider.dart';

/// Branded entry Splash Screen that checks authentication status and routes:
/// - If logged in -> HomeScreen (`/`)
/// - If not logged in -> OnboardingScreen (`/onboarding`) -> AuthScreen (`/auth`)
class SplashScreen extends StatefulWidget {
  final Duration delay;

  const SplashScreen({
    super.key,
    this.delay = const Duration(milliseconds: 1200),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _navTimer = Timer(widget.delay, _resolveNextRoute);
  }

  void _resolveNextRoute() {
    if (!mounted) return;
    final auth = context.read<AuthProvider?>();
    final isLoggedIn = auth?.isAuthenticated ?? false;
    if (isLoggedIn) {
      context.go(AppRoutePaths.home);
    } else {
      context.go(AppRoutePaths.onboarding);
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.25,
            child: Image.asset(
              AssetManager.splashBackground,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC12100E),
                  Color(0xF212100E),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Column(
                        children: [
                          Container(
                            width: 104.r,
                            height: 104.r,
                            padding: EdgeInsets.all(18.r),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: AppBorderRadius.r24,
                              boxShadow: const [AppColors.culinaryCardShadow],
                            ),
                            child: Image.asset(
                              AssetManager.appLogo,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.restaurant_menu_rounded,
                                size: AppIconSize.s48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          AppSpacing.gapH24,
                          Text(
                            StringManager.appName,
                            textAlign: TextAlign.center,
                            style: getBoldStyle(
                              fontSize: FontSize.s28,
                              color: Colors.white,
                            ),
                          ),
                          AppSpacing.gapH8,
                          Text(
                            StringManager.appTagline,
                            textAlign: TextAlign.center,
                            style: getRegularStyle(
                              fontSize: FontSize.s14,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  SizedBox(
                    width: 26.r,
                    height: 26.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                    ),
                  ),
                  AppSpacing.gapH12,
                  Text(
                    'Preparing your culinary workspace...',
                    style: getMediumStyle(
                      fontSize: FontSize.s12,
                      color: AppColors.textHintDark,
                    ),
                  ),
                  AppSpacing.gapH24,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
