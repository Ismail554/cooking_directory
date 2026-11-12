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
import '../../../recipes/presentation/providers/recipe_provider.dart';
import '../providers/auth_provider.dart';
import 'google_sign_in_button.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key, this.initialIsRegister = false});
  final bool initialIsRegister;

  static Future<bool?> show(BuildContext context, {bool initialIsRegister = false}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AuthDialog(initialIsRegister: initialIsRegister),
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
  late bool _isRegister = widget.initialIsRegister;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn(AuthProvider auth) async {
    final success = await auth.signInWithGoogle();
    if (!mounted || !success) return;
    context.read<RecipeProvider?>()?.loadRecipes();
    Navigator.of(context).pop(true);
    CustomSnackbar.showSuccess(context, 'Signed in as ${auth.displayName ?? auth.email ?? "Chef"}!');
  }

  Future<void> _submit(AuthProvider auth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = _isRegister
        ? await auth.registerWithEmail(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text)
        : await auth.signInWithEmail(_emailController.text.trim(), _passwordController.text);

    if (!mounted || !success) return;
    context.read<RecipeProvider?>()?.loadRecipes();
    Navigator.of(context).pop(true);
    CustomSnackbar.showSuccess(
      context,
      _isRegister ? 'Welcome, ${auth.displayName ?? "Chef"}! Account created.' : 'Welcome back, ${auth.displayName ?? auth.email ?? "Chef"}!',
    );
  }

  void _toggleMode(AuthProvider auth) {
    auth.clearError();
    _formKey.currentState?.reset();
    setState(() => _isRegister = !_isRegister);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

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
              Row(children: [
                const SizedBox(width: 28),
                Expanded(child: Text(_isRegister ? 'Create Chef Profile' : 'Sign In to Recipe Vault', style: getBoldStyle(context: context, fontSize: FontSize.s18), textAlign: TextAlign.center)),
                InkWell(
                  onTap: () => Navigator.of(context).pop(false),
                  borderRadius: AppBorderRadius.circular,
                  child: Padding(padding: EdgeInsets.all(4.r), child: Icon(Icons.close_rounded, size: 20.r, color: secColor)),
                ),
              ]),
              AppSpacing.gapH4,
              Text('Sync your recipes, meal logs, and cloud storage', style: getRegularStyle(context: context, fontSize: FontSize.s12, color: secColor), textAlign: TextAlign.center),
              if (auth.errorMessage != null && auth.errorMessage!.isNotEmpty) ...[
                AppSpacing.gapH12,
                _buildErrorBanner(auth.errorMessage!),
              ],
              AppSpacing.gapH16,
              GoogleSignInButton(isLoading: auth.isLoading, onPressed: () => _handleGoogleSignIn(auth)),
              AppSpacing.gapH16,
              _buildOrDivider(isDark),
              AppSpacing.gapH16,
              if (_isRegister) ...[
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _buildInput('Chef Name', Icons.person_outline_rounded, isDark),
                  validator: (v) => Validator.required(v, 'Chef name is required'),
                ),
                AppSpacing.gapH12,
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _buildInput('Email Address', Icons.email_outlined, isDark),
                validator: Validator.email,
              ),
              AppSpacing.gapH12,
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(auth),
                decoration: _buildInput('Password', Icons.lock_outline_rounded, isDark).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: AppIconSize.s18, color: secColor),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: Validator.password,
              ),
              AppSpacing.gapH20,
              AppButton(text: _isRegister ? 'Create Account' : 'Sign In with Email', isLoading: auth.isLoading, onPressed: () => _submit(auth)),
              AppSpacing.gapH8,
              TextButton(
                onPressed: () => _toggleMode(auth),
                child: Text(_isRegister ? 'Already have an account? Sign In' : "Don't have an account? Create one", style: getMediumStyle(fontSize: FontSize.s13, color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: AppBorderRadius.r12, border: Border.all(color: AppColors.error.withValues(alpha: 0.4))),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
        AppSpacing.gapW8,
        Expanded(child: Text(message, style: getMediumStyle(fontSize: FontSize.s12, color: AppColors.error))),
      ]),
    );
  }

  Widget _buildOrDivider(bool isDark) {
    final divColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Row(children: [
      Expanded(child: Divider(color: divColor)),
      Padding(padding: EdgeInsets.symmetric(horizontal: 12.w), child: Text('OR', style: getMediumStyle(fontSize: FontSize.s11, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight))),
      Expanded(child: Divider(color: divColor)),
    ]);
  }

  InputDecoration _buildInput(String label, IconData icon, bool isDark) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: AppIconSize.s20, color: AppColors.primary),
      filled: true,
      fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
      border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
      enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: borderColor, width: 1.w)),
    );
  }
}
