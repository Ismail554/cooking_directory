import 'package:flutter/material.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';

/// Common themed culinary background wrapper used across the app.
/// Renders [AssetManager.splashBackground] in Light Theme and
/// [AssetManager.splashBackgroundDark] in Dark Theme with ambient culinary
/// radial highlights and a subtle readability veil.
class AppThemedBackground extends StatelessWidget {
  final Widget child;
  final bool? forceDark;
  final double imageOpacity;

  const AppThemedBackground({
    super.key,
    required this.child,
    this.forceDark,
    this.imageOpacity = 0.92,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        forceDark ?? (Theme.of(context).brightness == Brightness.dark);
    final bgAsset = isDark
        ? AssetManager.splashBackgroundDark
        : AssetManager.splashBackground;
    final baseColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return ColoredBox(
      color: baseColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: imageOpacity,
                child: Image.asset(
                  bgAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, _, _) => Image.asset(
                    AssetManager.splashBackground,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    color: isDark
                        ? AppColors.backgroundDark.withValues(alpha: 0.88)
                        : null,
                    colorBlendMode: isDark ? BlendMode.darken : null,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.85, -0.75),
                    radius: 1.15,
                    colors: [
                      (isDark ? AppColors.primaryLight : AppColors.primary)
                          .withValues(alpha: isDark ? 0.10 : 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      baseColor.withValues(alpha: isDark ? 0.18 : 0.10),
                      Colors.transparent,
                      baseColor.withValues(alpha: isDark ? 0.30 : 0.16),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
