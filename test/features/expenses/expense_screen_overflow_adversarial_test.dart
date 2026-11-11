import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/features/expenses/presentation/screens/expense_screen.dart';

Widget _buildOverflowHarness({
  required Widget child,
  required Size logicalSize,
  double textScale = 1.0,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: logicalSize,
          textScaler: TextScaler.linear(textScale),
        ),
        child: SizedBox(
          width: logicalSize.width,
          height: logicalSize.height,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('ExpenseScreen Adversarial Layout & Flex Safety', () {
    testWidgets('renders cleanly on standard viewport (375x812)', (tester) async {
      await tester.pumpWidget(
        _buildOverflowHarness(
          child: const ExpenseScreen(),
          logicalSize: const Size(375, 812),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Monthly Food Budget'), findsOneWidget);
      expect(find.text('40% spent'), findsOneWidget);
    });

    testWidgets('renders cleanly on narrow viewport (320x568 iPhone SE)', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildOverflowHarness(
          child: const ExpenseScreen(),
          logicalSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Monthly Food Budget'), findsOneWidget);
      expect(find.text('40% spent'), findsOneWidget);
      expect(find.text('Total Budget'), findsOneWidget);
      expect(find.text('Spent'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
    });

    testWidgets('renders cleanly on ultra-narrow viewport (280x653 Fold outer)', (tester) async {
      tester.view.physicalSize = const Size(280 * 2.0, 653 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildOverflowHarness(
          child: const ExpenseScreen(),
          logicalSize: const Size(280, 653),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Monthly Food Budget'), findsOneWidget);
      expect(find.text('40% spent'), findsOneWidget);
    });

    testWidgets('renders cleanly on 320x568 with 1.5x font scaling', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildOverflowHarness(
          child: const ExpenseScreen(),
          logicalSize: const Size(320, 568),
          textScale: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Monthly Food Budget'), findsOneWidget);
      expect(find.text('40% spent'), findsOneWidget);
    });

    testWidgets('renders cleanly on 320x568 with 2.0x accessibility font scaling', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildOverflowHarness(
          child: const ExpenseScreen(),
          logicalSize: const Size(320, 568),
          textScale: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Monthly Food Budget'), findsOneWidget);
    });

    testWidgets('category filter pills scroll horizontally and switch without overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildOverflowHarness(
          child: const ExpenseScreen(),
          logicalSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Dining Out
      await tester.tap(find.text('Dining Out'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Trattoria Pasta Dinner'), findsOneWidget);

      // Scroll and tap Snacks (empty state)
      await tester.drag(find.text('Dining Out'), const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(find.text('Snacks'), findsOneWidget);
      await tester.tap(find.text('Snacks'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('No Expenses Found'), findsOneWidget);
    });
  });
}
