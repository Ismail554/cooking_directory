import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const String appName = 'Cooking Directory';
  static const String appVersion = '1.0.0';

  // ScreenUtil base design size (Standard modern mobile canvas)
  static const Size designSize = Size(375, 812);

  // Timeouts & Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration apiTimeout = Duration(seconds: 15);
}
