import 'package:flutter/material.dart';
import 'package:cooking_directory/core/theme/dark_theme.dart';
import 'package:cooking_directory/core/theme/light_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => getLightTheme();
  static ThemeData get dark => getDarkTheme();
}
