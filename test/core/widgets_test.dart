import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';
import 'package:cooking_directory/core/widgets/app_empty_view.dart';
import 'package:cooking_directory/core/widgets/app_error_view.dart';
import 'package:cooking_directory/core/widgets/app_loading_view.dart';

Widget _buildTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('renders primary button with gradient container and text', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildTestApp(
          AppButton(
            text: 'Cook Now',
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cook Now'), findsOneWidget);

      // Verify the container has primary gradient
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.gradient, AppColors.primaryGradient);

      // Tap button
      await tester.tap(find.text('Cook Now'));
      expect(tapped, isTrue);
    });

    testWidgets('renders outlined button without gradient', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          AppButton(
            text: 'Cancel',
            isOutlined: true,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders loading state with spinner and disables tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildTestApp(
          AppButton(
            text: 'Save',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);

      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    });

    testWidgets('renders icon with text wrapped in Flexible', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          AppButton(
            text: 'Add Recipe',
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add Recipe'), findsOneWidget);
      expect(find.byType(Flexible), findsOneWidget);
    });
  });

  group('AppEmptyView Widget Tests', () {
    testWidgets('renders empty view with icon and action button', (tester) async {
      var actionTapped = false;
      await tester.pumpWidget(
        _buildTestApp(
          AppEmptyView(
            title: 'No Recipes Found',
            message: 'Try adjusting your search filters.',
            icon: Icons.search_off_rounded,
            actionLabel: 'Reset Filters',
            onAction: () => actionTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Recipes Found'), findsOneWidget);
      expect(find.text('Try adjusting your search filters.'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.text('Reset Filters'), findsOneWidget);

      await tester.tap(find.text('Reset Filters'));
      expect(actionTapped, isTrue);
    });
  });

  group('AppErrorView Widget Tests', () {
    testWidgets('renders error view with retry button and triggers callback', (tester) async {
      var retryTapped = false;
      await tester.pumpWidget(
        _buildTestApp(
          AppErrorView(
            title: 'Connection Lost',
            message: 'Please check your internet connection and try again.',
            onRetry: () => retryTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Connection Lost'), findsOneWidget);
      expect(find.text('Please check your internet connection and try again.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retryTapped, isTrue);
    });
  });

  group('AppLoadingView Widget Tests', () {
    testWidgets('renders fallback spinner cleanly when useLottie is false', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const AppLoadingView(
            message: 'Simmering ingredients...',
            useLottie: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Simmering ingredients...'), findsOneWidget);
    });

    testWidgets('does not overflow inside constrained SizedBox(height: 140) or tight height', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const Column(
            children: [
              SizedBox(
                height: 140,
                child: AppLoadingView(message: 'Simmering fresh recipes...'),
              ),
              SizedBox(
                height: 60,
                child: AppLoadingView(message: 'Loading...', useLottie: false),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Simmering fresh recipes...'), findsOneWidget);
    });
  });
}
