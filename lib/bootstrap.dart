import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/app/app.dart';

/// Application bootstrap entry point.
/// Initializes bindings, local services, and error handling before running the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure screen size is prepared for ScreenUtil
  await ScreenUtil.ensureScreenSize();

  // Setup Flutter error capture
  FlutterError.onError = (details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Uncaught Platform Error: $error\n$stack');
    }
    return true;
  };

  runApp(const CookingDirectoryApp());
}
