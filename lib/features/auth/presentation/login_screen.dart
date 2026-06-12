import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gozolt_logo.dart';
import 'package:gozolt_driver/features/auth/domain/models/auth_state.dart';
import 'providers/auth_provider.dart';
import 'providers/login_form_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _driverIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedDriverId();
  }

  Future<void> _loadRememberedDriverId() async {
    final storage = ref.read(secureStorageProvider);
    final rememberMe = await storage.getRememberMe();
    if (rememberMe) {
      final savedId = await storage.getSavedDriverId();
      if (savedId != null && mounted) {
        _driverIdController.text = savedId;
        ref.read(loginFormProvider.notifier).prefillDriverId(savedId);
      }
    }
  }

  @override
  void dispose() {
    _driverIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final formState = ref.read(loginFormProvider);
    if (!formState.isValid) return;

    final storage = ref.read(secureStorageProvider);
    await storage.setRememberMe(formState.rememberMe, driverId: formState.driverId);

    await ref.read(authProvider.notifier).loginWithPassword(
      driverId: formState.driverId.trim(),
      password: formState.password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Listen for auth state changes to navigate or show errors
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go(RouteNames.home);
      } else if (next is AuthError) {
        ref.read(loginFormProvider.notifier).setError(next.message);
      }
    });

    final formState = ref.watch(loginFormProvider);
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.welcome);
            }
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 3),
                        
                        // Logo
                        const Center(child: GozoltLogo(size: 90)),
                        const SizedBox(height: 24),
                        
                        // Title
                        Text(
                          l10n.welcomeBack,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Login with your credentials to continue",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.textMuted : AppColors.textMutedLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const Spacer(flex: 2),

                        // Error message
                        if (formState.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formState.errorMessage!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Driver ID field
                        Text(
                          "Driver ID",
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _driverIdController,
                          onChanged: ref.read(loginFormProvider.notifier).setDriverId,
                          keyboardType: TextInputType.text,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter Driver ID',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        Text(
                          "Password",
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          onChanged: ref.read(loginFormProvider.notifier).setPassword,
                          obscureText: !_isPasswordVisible,
                          keyboardType: TextInputType.visiblePassword,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Remember me
                            GestureDetector(
                              onTap: ref.read(loginFormProvider.notifier).toggleRememberMe,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: formState.rememberMe,
                                      onChanged: (_) => ref
                                          .read(loginFormProvider.notifier)
                                          .toggleRememberMe(),
                                      activeColor: AppColors.primaryGold,
                                      checkColor: Theme.of(context).scaffoldBackgroundColor,
                                      side: BorderSide(
                                        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    l10n.rememberMe,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Forgot Password
                            GestureDetector(
                              onTap: () {
                                context.push(RouteNames.forgotPassword);
                              },
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading || !formState.isValid ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const Spacer(flex: 3),

                        // Register section using RichText
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: "Register",
                                  style: const TextStyle(
                                    color: AppColors.primaryGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => context.push(RouteNames.register),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (formState.errorMessage != null &&
                            (formState.errorMessage!.toLowerCase().contains('supplier') ||
                             formState.errorMessage!.toLowerCase().contains('fleet'))) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.comingSoon),
                                    backgroundColor: AppColors.surfaceDark,
                                  ),
                                );
                              },
                              child: Text(
                                l10n.contactSupplier,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),

                        // Footer
                        _LoginFooter(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.maltaFlag,
              width: 24,
              height: 16,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, st) =>
                  const Text('🇲🇹', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
            const Text(
              'Born in Malta, Loved by Europe',
              style: AppTextStyles.footerText,
            ),
            const SizedBox(width: 8),
            Image.asset(
              AssetPaths.euFlag,
              width: 24,
              height: 16,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, st) =>
                  const Text('🇪🇺', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Powered By ', style: AppTextStyles.footerText),
            const Text('PRIMOOO', style: AppTextStyles.footerAccent),
            const SizedBox(width: 8),
            Image.asset(
              AssetPaths.primoooLogo,
              width: 32,
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }
}
