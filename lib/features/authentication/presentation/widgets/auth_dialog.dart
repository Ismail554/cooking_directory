import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/validation/validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../providers/auth_provider.dart';
import 'google_sign_in_button.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const AuthDialog(),
    );
  }

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn(AuthProvider auth) async {
    final success = await auth.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      CustomSnackbar.showSuccess(context, 'Signed in with Google!');
      Navigator.of(context).pop();
    } else if (auth.errorMessage != null) {
      CustomSnackbar.showError(context, auth.errorMessage!);
    }
  }

  Future<void> _submit(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    final success = _isRegister
        ? await auth.registerWithEmail(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          )
        : await auth.signInWithEmail(_emailController.text.trim(), _passwordController.text.trim());

    if (!mounted) return;
    if (success) {
      CustomSnackbar.showSuccess(
        context,
        _isRegister ? 'Account created successfully!' : 'Signed in successfully!',
      );
      Navigator.of(context).pop();
    } else if (auth.errorMessage != null) {
      CustomSnackbar.showError(context, auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r20),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: SingleChildScrollView(
        padding: AppSpacing.dialogPadding,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isRegister ? 'Create Chef Profile' : 'Sign In to Recipe Vault',
                style: getBoldStyle(context: context, fontSize: FontSize.s18),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapH4,
              Text(
                'Sync your recipes, meal logs, and cloud storage',
                style: getRegularStyle(
                  context: context,
                  fontSize: FontSize.s12,
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapH20,
              GoogleSignInButton(
                isLoading: auth.isLoading,
                onPressed: () => _handleGoogleSignIn(auth),
              ),
              AppSpacing.gapH16,
              _buildOrDivider(),
              AppSpacing.gapH16,
              if (_isRegister) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInput('Chef Name', Icons.person_outline_rounded),
                  validator: (v) => Validator.required(v, 'Chef name is required'),
                ),
                AppSpacing.gapH12,
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInput('Email Address', Icons.email_outlined),
                validator: Validator.email,
              ),
              AppSpacing.gapH12,
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _buildInput('Password', Icons.lock_outline_rounded),
                validator: Validator.password,
              ),
              AppSpacing.gapH20,
              AppButton(
                text: _isRegister ? 'Create Account' : 'Sign In with Email',
                isLoading: auth.isLoading,
                onPressed: () => _submit(auth),
              ),
              AppSpacing.gapH12,
              TextButton(
                onPressed: () => setState(() => _isRegister = !_isRegister),
                child: Text(
                  _isRegister
                      ? 'Already have an account? Sign In'
                      : "Don't have an account? Create one",
                  style: getMediumStyle(
                    fontSize: FontSize.s13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'OR',
            style: getMediumStyle(fontSize: FontSize.s11, color: AppColors.textTertiaryLight),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }

  InputDecoration _buildInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: AppIconSize.s20, color: AppColors.primary),
      filled: true,
      border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: BorderSide(color: AppColors.borderLight, width: 1.w),
      ),
    );
  }
}
