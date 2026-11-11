import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';

Widget _buildThemedHarness({
  required ThemeData theme,
  required Widget Function(BuildContext) builder,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, child) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(builder: builder),
        ),
      );
    },
  );
}

void main() {
  group('StyleManager Tests', () {
    testWidgets('resolves theme onSurface in light mode', (tester) async {
      TextStyle? regularStyle;
      TextStyle? boldStyle;
      TextStyle? themeAwareStyle;

      await tester.pumpWidget(
        _buildThemedHarness(
          theme: ThemeData.light(),
          builder: (context) {
            regularStyle = getRegularStyle(context: context);
            boldStyle = getBoldStyle(context: context);
            themeAwareStyle = getThemeAwareStyle(
              context,
              fontSize: 16,
            );
            return const Text('Test Light');
          },
        ),
      );
      await tester.pumpAndSettle();

      final lightOnSurface = ThemeData.light().colorScheme.onSurface;
      expect(regularStyle?.color, lightOnSurface);
      expect(boldStyle?.color, lightOnSurface);
      expect(themeAwareStyle?.color, lightOnSurface);
    });

    testWidgets('resolves dark theme onSurface in dark mode', (tester) async {
      TextStyle? regularStyle;
      TextStyle? boldStyle;
      TextStyle? themeAwareStyle;
      TextStyle? lightStyle;

      await tester.pumpWidget(
        _buildThemedHarness(
          theme: ThemeData.dark(),
          builder: (context) {
            regularStyle = getRegularStyle(context: context);
            boldStyle = getBoldStyle(context: context);
            themeAwareStyle = getThemeAwareStyle(
              context,
              fontSize: 16,
            );
            lightStyle = getLightStyle(context: context);
            return const Text('Test Dark');
          },
        ),
      );
      await tester.pumpAndSettle();

      final darkOnSurface = ThemeData.dark().colorScheme.onSurface;
      final darkOnSurfaceVariant = ThemeData.dark().colorScheme.onSurfaceVariant;
      expect(regularStyle?.color, darkOnSurface);
      expect(boldStyle?.color, darkOnSurface);
      expect(themeAwareStyle?.color, darkOnSurface);
      expect(lightStyle?.color, darkOnSurfaceVariant);
    });

    test('explicit color overrides context and defaults', () {
      final style = getBoldStyle(color: Colors.red);
      expect(style.color, Colors.red);
      expect(style.fontWeight, FontWeightManager.bold);
    });

    test('omitted color and context produces null color for ambient inheritance', () {
      final style = getRegularStyle();
      expect(style.color, isNull);
      expect(style.fontWeight, FontWeightManager.regular);
    });
  });
}
