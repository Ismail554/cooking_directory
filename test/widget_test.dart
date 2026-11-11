import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/app/app.dart';
import 'package:cooking_directory/features/home/presentation/screens/home_screen.dart';
import 'package:cooking_directory/features/home/presentation/widgets/home_header.dart';

void main() {
  testWidgets('CookingDirectoryApp renders smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CookingDirectoryApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(HomeHeader), findsOneWidget);
    expect(find.text('Hello, Chef Ismail'), findsOneWidget);
    expect(find.text('What are we cooking today?'), findsOneWidget);
  });
}
