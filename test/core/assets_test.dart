import 'dart:convert';
import 'dart:io';

import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const List<String> allAssets = <String>[
    AssetManager.appLogo,
    AssetManager.splashBackground,
    AssetManager.recipePlaceholder,
    AssetManager.userAvatar,
    AssetManager.emptyStateIllustration,
    AssetManager.icTimer,
    AssetManager.icRecipe,
    AssetManager.icExpense,
    AssetManager.svgCookingPot,
    AssetManager.svgChefHat,
    AssetManager.svgNoData,
    AssetManager.lottieCooking,
    AssetManager.lottieLoading,
  ];

  const List<String> pngAssets = <String>[
    AssetManager.appLogo,
    AssetManager.splashBackground,
    AssetManager.recipePlaceholder,
    AssetManager.userAvatar,
    AssetManager.emptyStateIllustration,
    AssetManager.icTimer,
    AssetManager.icRecipe,
    AssetManager.icExpense,
  ];

  const List<String> svgAssets = <String>[
    AssetManager.svgCookingPot,
    AssetManager.svgChefHat,
    AssetManager.svgNoData,
  ];

  const List<String> lottieAssets = <String>[
    AssetManager.lottieCooking,
    AssetManager.lottieLoading,
  ];

  group('AssetManager Contract and Inventory Verification', () {
    test('declares exactly 13 assets matching the contract', () {
      expect(allAssets.length, equals(13));
      expect(pngAssets.length, equals(8));
      expect(svgAssets.length, equals(3));
      expect(lottieAssets.length, equals(2));
    });

    test('all 13 declared assets exist on disk and have non-zero size', () {
      for (final String path in allAssets) {
        final File file = File(path);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Expected asset file to exist at: $path',
        );
        final int byteLength = file.lengthSync();
        expect(
          byteLength,
          greaterThan(0),
          reason: 'Asset file at $path must not be empty (was $byteLength bytes)',
        );
      }
    });
  });

  group('Binary and Format Integrity', () {
    test('all 8 PNG assets have valid 8-byte PNG header signatures', () {
      const List<int> expectedPngHeader = <int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
      ];

      for (final String path in pngAssets) {
        final File file = File(path);
        final List<int> bytes = file.readAsBytesSync();
        expect(bytes.length, greaterThanOrEqualTo(8));
        final List<int> header = bytes.sublist(0, 8);
        expect(
          header,
          equals(expectedPngHeader),
          reason: 'File at $path is not a valid PNG image binary',
        );
      }
    });

    test('all 3 SVG assets are well-formed XML vectors with valid viewBox', () {
      for (final String path in svgAssets) {
        final File file = File(path);
        final String content = file.readAsStringSync();
        expect(
          content,
          contains('<svg'),
          reason: 'SVG file $path missing <svg root tag',
        );
        expect(
          content,
          contains('viewBox='),
          reason: 'SVG file $path must declare a viewBox',
        );
        expect(
          content,
          contains('xmlns="http://www.w3.org/2000/svg"'),
          reason: 'SVG file $path missing xmlns namespace',
        );
      }
    });

    test('all 2 Lottie JSON assets are valid Bodymovin specifications', () {
      for (final String path in lottieAssets) {
        final File file = File(path);
        final String content = file.readAsStringSync();
        final dynamic decoded = jsonDecode(content);

        expect(decoded, isA<Map<String, dynamic>>());
        final Map<String, dynamic> lottie = decoded as Map<String, dynamic>;

        expect(lottie.containsKey('v'), isTrue);
        expect(lottie.containsKey('fr'), isTrue);
        expect(lottie.containsKey('ip'), isTrue);
        expect(lottie.containsKey('op'), isTrue);
        expect(lottie.containsKey('layers'), isTrue);
        expect(lottie['layers'], isA<List<dynamic>>());
        expect((lottie['layers'] as List<dynamic>).isNotEmpty, isTrue);
      }
    });
  });

  group('pubspec.yaml Asset Registration and Dependencies', () {
    test('pubspec.yaml registers all 4 asset directory prefixes', () {
      final File pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);

      final String content = pubspecFile.readAsStringSync();
      expect(
        content.contains('assets/images/'),
        isTrue,
        reason: 'pubspec.yaml must register assets/images/',
      );
      expect(
        content.contains('assets/icons/'),
        isTrue,
        reason: 'pubspec.yaml must register assets/icons/',
      );
      expect(
        content.contains('assets/svgs/'),
        isTrue,
        reason: 'pubspec.yaml must register assets/svgs/',
      );
      expect(
        content.contains('assets/jsons/'),
        isTrue,
        reason: 'pubspec.yaml must register assets/jsons/',
      );
    });

    test('pubspec.yaml declares flutter_svg and lottie dependencies', () {
      final File pubspecFile = File('pubspec.yaml');
      final String content = pubspecFile.readAsStringSync();

      expect(content.contains('flutter_svg:'), isTrue);
      expect(content.contains('lottie:'), isTrue);
    });
  });

  group('Flutter AssetBundle Loading Verification', () {
    test('rootBundle loads all 13 assets cleanly in test environment', () async {
      for (final String path in allAssets) {
        final ByteData byteData = await rootBundle.load(path);
        expect(
          byteData.lengthInBytes,
          greaterThan(0),
          reason: 'Failed to load $path via rootBundle',
        );
      }
    });
  });
}
