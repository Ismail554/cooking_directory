import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/app/app.dart';
import 'package:cooking_directory/features/authentication/presentation/screens/auth_screen.dart';
import 'package:cooking_directory/features/home/presentation/screens/home_screen.dart';
import 'package:cooking_directory/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:cooking_directory/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets(
      'CookingDirectoryApp follows Splash -> Onboarding -> Auth -> Home flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CookingDirectoryApp());

    // Step 1: Splash Screen renders initially
    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance past splash timer -> lands on OnboardingScreen when not logged in
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);

    // Step 2: Tap Skip on Onboarding -> lands on AuthScreen
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);

    // Step 3: Tap Sign in with Google -> authenticates and navigates to HomeScreen
    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
