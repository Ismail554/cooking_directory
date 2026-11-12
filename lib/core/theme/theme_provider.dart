import 'package:flutter/material.dart';

/// Centralized provider for app theme mode (Light / Dark / System)
/// and shared culinary preferences (dietary options, currency, monthly budget).
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;
  List<String> _dietaryPreferences;
  String _currency;
  double _monthlyBudget;

  ThemeProvider({
    ThemeMode initialThemeMode = ThemeMode.system,
    List<String>? initialDietaryPreferences,
    String initialCurrency = 'USD (\$)',
    double initialMonthlyBudget = 1200.0,
  })  : _themeMode = initialThemeMode,
        _dietaryPreferences =
            initialDietaryPreferences ?? ['Halal', 'Gluten-Free'],
        _currency = initialCurrency,
        _monthlyBudget = initialMonthlyBudget;

  ThemeMode get themeMode => _themeMode;
  List<String> get dietaryPreferences => List.unmodifiable(_dietaryPreferences);
  String get currency => _currency;
  double get monthlyBudget => _monthlyBudget;

  /// Resolves the currency symbol (e.g. $, €, £, ৳) from the selected currency label.
  String get currencySymbol {
    final match = RegExp(r'\((.+?)\)').firstMatch(_currency);
    if (match != null && match.group(1) != null) {
      return match.group(1)!;
    }
    return '\$';
  }

  /// Resolves whether dark mode is currently active given the [context].
  bool isDarkActive(BuildContext context) {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Explicitly toggles between Dark and Light mode.
  void toggleDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Sets the [ThemeMode] directly.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  /// Updates the chef's dietary preferences.
  void setDietaryPreferences(List<String> preferences) {
    _dietaryPreferences = List<String>.from(preferences);
    notifyListeners();
  }

  /// Updates currency and monthly food budget limit.
  void setCurrencyAndBudget(String currency, double budget) {
    _currency = currency;
    _monthlyBudget = budget > 0 ? budget : _monthlyBudget;
    notifyListeners();
  }
}

