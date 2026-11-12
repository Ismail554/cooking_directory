import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cooking_directory/core/constants/app_constants.dart';
import 'package:cooking_directory/core/routing/app_router.dart';
import 'package:cooking_directory/core/theme/app_theme.dart';
import 'package:cooking_directory/core/theme/theme_provider.dart';
import 'package:cooking_directory/features/authentication/presentation/providers/auth_provider.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_export_provider.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_provider.dart';

class CookingDirectoryApp extends StatelessWidget {
  const CookingDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<RecipeProvider>(
          create: (_) => RecipeProvider(),
        ),
        ChangeNotifierProvider<RecipeExportProvider>(
          create: (_) => RecipeExportProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: AppConstants.designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final themeMode = context.select<ThemeProvider, ThemeMode>(
            (p) => p.themeMode,
          );
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
