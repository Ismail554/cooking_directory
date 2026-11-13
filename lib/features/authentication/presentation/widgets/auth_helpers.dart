import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../providers/auth_provider.dart';

class AuthModeTabs extends StatelessWidget {
  final bool isLogin;
  final bool isDark;
  final ValueChanged<bool> onSelectMode;

  const AuthModeTabs({super.key, required this.isLogin, required this.isDark, required this.onSelectMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: AppBorderRadius.r12,
      ),
      child: Row(children: [
        Expanded(child: _tabButton('Sign In', isLogin, () => onSelectMode(true))),
        Expanded(child: _tabButton('Create Account', !isLogin, () => onSelectMode(false))),
      ]),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: AppBorderRadius.r8),
        alignment: Alignment.center,
        child: Text(label, style: getBoldStyle(fontSize: FontSize.s13, color: active ? Colors.white : null)),
      ),
    );
  }
}

Future<bool?> showForgotPasswordDialog(BuildContext context, {String initialEmail = ''}) async {
  final emailCtrl = TextEditingController(text: initialEmail);
  final sent = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Reset Password'),
      content: TextField(
        controller: emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Account Email'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final ok = await context.read<AuthProvider>().sendPasswordResetEmail(emailCtrl.text.trim());
            if (ctx.mounted) Navigator.pop(ctx, ok);
          },
          child: const Text('Send Link'),
        ),
      ],
    ),
  );
  emailCtrl.dispose();
  return sent;
}
