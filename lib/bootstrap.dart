import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!kIsWeb) {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    }
  } catch (e) {
    if (kDebugMode) debugPrint('Firebase initialization notice: $e');
  }

  // Initialize Google Sign In for mobile with Web & iOS OAuth client IDs
  if (!kIsWeb) {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? '453421733668-3op8qpumtd2p3vs6hdbh0sp5mgceca1m.apps.googleusercontent.com'
            : null,
        serverClientId:
            '453421733668-01cl1epvjhjguc7u1v3v0r19numbioit.apps.googleusercontent.com',
      );
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
