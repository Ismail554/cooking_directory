import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_constants.dart';
import 'package:cooking_directory/core/theme/app_theme.dart';
import 'package:cooking_directory/features/app_shell/presentation/screens/app_shell.dart';

class CookingDirectoryApp extends StatelessWidget {
  const CookingDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: AppConstants.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: child,
        );
      },
      child: const AppShell(),
    );
  }
}
