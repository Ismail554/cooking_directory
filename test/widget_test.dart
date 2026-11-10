import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/app/app.dart';

void main() {
  testWidgets('CookingDirectoryApp renders smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CookingDirectoryApp());
    await tester.pump();

    expect(find.text('Cooking Directory'), findsOneWidget);
  });
}
