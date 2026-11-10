/// Centralized user-facing strings and fallbacks.
abstract final class StringManager {
  static const String appName = 'Cooking Directory';
  static const String appTagline = 'Recipes, Cooking & Expenses in One Place';

  // Navigation
  static const String navHome = 'Recipes';
  static const String navExpenses = 'Expenses';
  static const String navProfile = 'Profile';

  // Actions
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String startCooking = 'Start Cooking';
  static const String addRecipe = 'Add Recipe';
  static const String addExpense = 'Add Expense';

  // States
  static const String noRecipesFound = 'No recipes found';
  static const String noRecipesSub = 'Start creating your favorite recipe collection!';
  static const String noExpensesFound = 'No expenses recorded yet';
  static const String errorOccurred = 'Something went wrong';
  static const String checkConnection = 'Please check your internet connection.';
}
