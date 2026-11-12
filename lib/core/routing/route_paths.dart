/// Centralized route paths for GoRouter.
abstract final class AppRoutePaths {
  // Entry & Auth Flow
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';

  // Main Tab Destinations
  static const String home = '/';
  static const String expenses = '/expenses';
  static const String profile = '/profile';

  // Sub-routes & Pushed screens
  static const String recipeDetails = '/recipe-details';
  static const String addRecipe = '/add-recipe';
  static const String addExpense = '/add-expense';
  static const String cookingMode = '/cooking-mode';
}
