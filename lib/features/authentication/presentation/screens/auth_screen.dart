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
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/validation/validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_themed_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../recipes/presentation/providers/recipe_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_helpers.dart';
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

  void _syncSessionData() {
    context.read<RecipeProvider?>()?.loadRecipes();
    context.read<ExpenseProvider?>()?.loadExpenses();
    context.read<ThemeProvider?>()?.loadPreferences();
  }

  Future<void> _handleEmailSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim();
    final ok = _isLogin ? await auth.signInWithEmail(email, _passCtrl.text) : await auth.registerWithEmail(_nameCtrl.text.trim(), email, _passCtrl.text);
    if (!mounted || !ok) return;
    _syncSessionData();
    CustomSnackbar.showSuccess(
      context,
      _isLogin
          ? 'Welcome back, ${auth.displayName ?? 'Chef'}!'
          : 'Account created! Verification link sent to $email.',
    );
    context.go(AppRoutePaths.home);
  }

  Future<void> _handleForgotPassword() async {
    final sent = await showForgotPasswordDialog(context, initialEmail: _emailCtrl.text.trim());
    if (!mounted || sent != true) return;
    CustomSnackbar.showSuccess(context, 'Password reset link sent to your email.');
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    if (!await auth.signInWithGoogle() || !mounted) return;
    _syncSessionData();
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

    return AppThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                      width: 68.r, height: 68.r,
                      decoration: BoxDecoration(borderRadius: AppBorderRadius.r20, boxShadow: const [AppColors.culinaryCardShadow]),
                      child: ClipRRect(
                        borderRadius: AppBorderRadius.r20,
                        child: Image.asset(AssetManager.appLogo, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.restaurant_menu_rounded, color: Colors.white)),
                      ),
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
                  AuthModeTabs(isLogin: _isLogin, isDark: isDark, onSelectMode: _switchMode),
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
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : _handleForgotPassword,
                        child: Text('Forgot Password?', style: getMediumStyle(fontSize: FontSize.s12, color: isDark ? AppColors.primaryLight : AppColors.primary)),
                      ),
                    ),
                  AppSpacing.gapH12,
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
      ),
    );
  }
}
