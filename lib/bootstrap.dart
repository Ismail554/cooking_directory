import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cooking_directory/app/app.dart';
import 'package:cooking_directory/firebase_options.dart';

/// Application bootstrap entry point.
/// Initializes bindings, local services, and error handling before running the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Google Sign In for mobile if supported
  if (!kIsWeb) {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      if (kDebugMode) debugPrint('GoogleSignIn initialization notice: $e');
    }
  }

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
