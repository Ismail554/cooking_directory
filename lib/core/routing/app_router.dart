import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_directory/core/routing/page_transitions.dart';
import 'package:cooking_directory/core/routing/route_names.dart';
import 'package:cooking_directory/core/routing/route_paths.dart';
import 'package:cooking_directory/core/widgets/app_error_view.dart';
import 'package:cooking_directory/features/app_shell/presentation/screens/app_shell.dart';
import 'package:cooking_directory/features/cooking_mode/presentation/screens/cooking_mode_screen.dart';
import 'package:cooking_directory/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:cooking_directory/features/expenses/presentation/screens/expense_screen.dart';
import 'package:cooking_directory/features/home/presentation/screens/home_screen.dart';
import 'package:cooking_directory/features/profile/presentation/screens/profile_screen.dart';
import 'package:cooking_directory/features/recipes/presentation/screens/add_recipe_screen.dart';
import 'package:cooking_directory/features/recipes/presentation/screens/recipe_details_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final GlobalKey<NavigatorState> _expensesTabKey =
    GlobalKey<NavigatorState>(debugLabel: 'expensesNav');
final GlobalKey<NavigatorState> _homeTabKey =
    GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final GlobalKey<NavigatorState> _profileTabKey =
    GlobalKey<NavigatorState>(debugLabel: 'profileNav');

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutePaths.home,
    errorBuilder: (context, state) => Scaffold(
      body: AppErrorView(
        title: 'Page Not Found',
        message: state.error?.message ?? 'The requested page was not found.',
        onRetry: () => context.go(AppRoutePaths.home),
      ),
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Expenses
          StatefulShellBranch(
            navigatorKey: _expensesTabKey,
            routes: [
              GoRoute(
                path: AppRoutePaths.expenses,
                name: AppRouteNames.expenses,
                pageBuilder: (context, state) => PageTransitions.cupertino(
                  state: state,
                  child: const ExpenseScreen(),
                ),
              ),
            ],
          ),

          // Branch 1: Recipes / Home (Default Central Screen)
          StatefulShellBranch(
            navigatorKey: _homeTabKey,
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                name: AppRouteNames.home,
                pageBuilder: (context, state) => PageTransitions.cupertino(
                  state: state,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),

          // Branch 2: Profile / Settings
          StatefulShellBranch(
            navigatorKey: _profileTabKey,
            routes: [
              GoRoute(
                path: AppRoutePaths.profile,
                name: AppRouteNames.profile,
                pageBuilder: (context, state) => PageTransitions.cupertino(
                  state: state,
                  child: const ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Pushed Screens with Native iOS Cupertino Transition
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.recipeDetails,
        name: AppRouteNames.recipeDetails,
        pageBuilder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return PageTransitions.cupertino(
            state: state,
            child: RecipeDetailsScreen(recipeId: id),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.cookingMode,
        name: AppRouteNames.cookingMode,
        pageBuilder: (context, state) {
          final id = state.uri.queryParameters['id'];
          final title = state.uri.queryParameters['title'];
          return PageTransitions.cupertino(
            state: state,
            child: CookingModeScreen(
              recipeId: id,
              title: title,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.addRecipe,
        name: AppRouteNames.addRecipe,
        pageBuilder: (context, state) => PageTransitions.cupertinoModal(
          state: state,
          child: const AddRecipeScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.addExpense,
        name: AppRouteNames.addExpense,
        pageBuilder: (context, state) => PageTransitions.cupertinoModal(
          state: state,
          child: const AddExpenseScreen(),
        ),
      ),
    ],
  );
}
