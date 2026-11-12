import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/asset_manager.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/validation/validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../recipes/presentation/providers/recipe_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/google_sign_in_button.dart';

/// Full-screen Authentication Screen (Sign In, Create Account & Sign in with Google).
class AuthScreen extends StatefulWidget {
  final bool initialIsLogin;
  const AuthScreen({super.key, this.initialIsLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late bool _isLogin = widget.initialIsLogin;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _switchMode(bool loginMode) {
    if (_isLogin == loginMode) return;
    context.read<AuthProvider?>()?.clearError();
    _formKey.currentState?.reset();
    setState(() => _isLogin = loginMode);
  }

  Future<void> _handleEmailSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim();
    final success = _isLogin
        ? await auth.signInWithEmail(email, _passCtrl.text)
        : await auth.registerWithEmail(_nameCtrl.text.trim(), email, _passCtrl.text);

    if (!mounted || !success) return;
    context.read<RecipeProvider?>()?.loadRecipes();
    CustomSnackbar.showSuccess(
      context,
      _isLogin ? 'Welcome back, ${auth.displayName ?? 'Chef'}!' : 'Account created! Welcome, ${auth.displayName ?? 'Chef'}!',
    );
    context.go(AppRoutePaths.home);
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!mounted || !success) return;
    context.read<RecipeProvider?>()?.loadRecipes();
    CustomSnackbar.showSuccess(context, 'Signed in as ${auth.displayName ?? auth.email ?? 'Chef'}');
    context.go(AppRoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider?>();
    final isLoading = auth?.isLoading ?? false;
    final errorMsg = auth?.errorMessage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.gapH16,
                Center(
                  child: Container(
                    width: 68.r, height: 68.r, padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient, borderRadius: AppBorderRadius.r20,
                      boxShadow: const [AppColors.culinaryCardShadow],
                    ),
                    child: Image.asset(AssetManager.appLogo, errorBuilder: (_, _, _) => const Icon(Icons.restaurant_menu_rounded, color: Colors.white)),
                  ),
                ),
                AppSpacing.gapH16,
                Text(_isLogin ? 'Welcome Back, Chef' : 'Create Chef Account', textAlign: TextAlign.center, style: getBoldStyle(context: context, fontSize: FontSize.s24)),
                AppSpacing.gapH4,
                Text(
                  _isLogin ? 'Sign in to access your recipes, cooking timers & budget' : 'Register to curate and sync your personal culinary vault',
                  textAlign: TextAlign.center, style: getRegularStyle(context: context, fontSize: FontSize.s13, color: secColor),
                ),
                AppSpacing.gapH20,
                _buildModeTabs(isDark),
                if (errorMsg != null && errorMsg.isNotEmpty) ...[
                  AppSpacing.gapH12,
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: AppBorderRadius.r12, border: Border.all(color: AppColors.error.withValues(alpha: 0.4))),
                    child: Text(errorMsg, style: getMediumStyle(fontSize: FontSize.s12, color: AppColors.error)),
                  ),
                ],
                AppSpacing.gapH16,
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameCtrl, textInputAction: TextInputAction.next,
                    validator: (v) => Validator.required(v, 'Name is required'),
                    decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                  ),
                  AppSpacing.gapH12,
                ],
                TextFormField(
                  controller: _emailCtrl, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next,
                  validator: Validator.email,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                ),
                AppSpacing.gapH12,
                TextFormField(
                  controller: _passCtrl, obscureText: _obscurePassword, textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleEmailSubmit(), validator: Validator.password,
                  decoration: InputDecoration(
                    labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                AppSpacing.gapH20,
                AppButton(text: _isLogin ? 'Sign In' : 'Create Account', isLoading: isLoading, onPressed: _handleEmailSubmit),
                AppSpacing.gapH16,
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10.w), child: Text('OR', style: getMediumStyle(fontSize: FontSize.s11, color: secColor))),
                  const Expanded(child: Divider()),
                ]),
                AppSpacing.gapH16,
                GoogleSignInButton(isLoading: isLoading, onPressed: _handleGoogleSignIn),
                AppSpacing.gapH12,
                TextButton(
                  onPressed: isLoading ? null : () => _switchMode(!_isLogin),
                  child: Text(
                    _isLogin ? "Don't have an account? Create one" : 'Already have an account? Sign In',
                    style: getSemiBoldStyle(fontSize: FontSize.s13, color: isDark ? AppColors.primaryLight : AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabs(bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight, borderRadius: AppBorderRadius.r12),
      child: Row(children: [
        Expanded(child: _tabButton('Sign In', _isLogin, () => _switchMode(true))),
        Expanded(child: _tabButton('Create Account', !_isLogin, () => _switchMode(false))),
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
