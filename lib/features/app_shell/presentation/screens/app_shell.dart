import 'package:flutter/material.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/features/expenses/presentation/screens/expense_screen.dart';
import 'package:cooking_directory/features/home/presentation/screens/home_screen.dart';
import 'package:cooking_directory/features/profile/presentation/screens/profile_screen.dart';

/// Main navigation shell managing persistent bottom navigation.
/// Home (Recipes) is index 1, Expenses is index 0, Profile is index 2.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 1});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    ExpenseScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        indicatorColor: AppColors.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
