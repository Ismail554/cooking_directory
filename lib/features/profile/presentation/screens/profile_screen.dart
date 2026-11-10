import 'package:flutter/material.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: getBoldStyle(
            fontSize: FontSize.s18,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            _buildUserHeader(),
            AppSpacing.gapH24,
            _buildTile(Icons.person_outline, 'Personal Information'),
            _buildTile(Icons.restaurant_outlined, 'Dietary Preferences'),
            _buildTile(Icons.attach_money_rounded, 'Currency & Budget Settings'),
            _buildTile(Icons.dark_mode_outlined, 'Appearance'),
            _buildTile(Icons.notifications_none_rounded, 'Notifications'),
            AppSpacing.gapH16,
            _buildTile(
              Icons.logout_rounded,
              'Log Out',
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primaryContainer,
          child: const Icon(Icons.person, size: 36, color: AppColors.primary),
        ),
        AppSpacing.gapW16,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chef Ismail',
              style: getBoldStyle(fontSize: FontSize.s18),
            ),
            AppSpacing.gapH4,
            Text(
              'ismail@example.com',
              style: getRegularStyle(
                fontSize: FontSize.s13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, {Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.textPrimaryLight),
      title: Text(
        title,
        style: getMediumStyle(
          fontSize: FontSize.s14,
          color: color ?? AppColors.textPrimaryLight,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () {},
    );
  }
}
