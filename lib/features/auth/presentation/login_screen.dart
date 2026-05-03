import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gozolt_logo.dart';
import '../domain/models/auth_state.dart';
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

    // Save or clear remembered driver ID
    final storage = ref.read(secureStorageProvider);
    await storage.setRememberMe(
      formState.rememberMe,
      driverId: formState.driverId,
    );

    await ref.read(authProvider.notifier).login(
          driverId: formState.driverId,
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

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo
              const Center(child: GozoltLogo(size: 80)),
              const SizedBox(height: 32),
              // Welcome text
              Text(
                l10n.welcomeBack,
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.signInSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Error message
              if (formState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
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
                l10n.driverIdLabel,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _driverIdController,
                onChanged: ref.read(loginFormProvider.notifier).setDriverId,
                keyboardType: TextInputType.text,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l10n.driverIdPlaceholder,
                  prefixIcon: const Icon(
                    Icons.badge_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Password field
              Text(
                l10n.passwordLabel,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                onChanged: ref.read(loginFormProvider.notifier).setPassword,
                obscureText: formState.obscurePassword,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l10n.passwordPlaceholder,
                  prefixIcon: const Icon(
                    Icons.lock_rounded,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      formState.obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_rounded,
                      color: AppColors.textMuted,
                    ),
                    onPressed: ref
                        .read(loginFormProvider.notifier)
                        .togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Remember me
              GestureDetector(
                onTap:
                    ref.read(loginFormProvider.notifier).toggleRememberMe,
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
                        checkColor: AppColors.backgroundPrimary,
                        side: const BorderSide(
                          color: AppColors.textMuted,
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.rememberMe,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Sign In button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      isLoading || !formState.isValid ? null : _handleLogin,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.backgroundPrimary,
                          ),
                        )
                      : Text(
                          l10n.signIn,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.backgroundPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Contact Your Supplier
              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.comingSoon),
                        backgroundColor: AppColors.surfaceDark,
                      ),
                    );
                  },
                  child: Text(
                    l10n.contactSupplier,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Footer
              _LoginFooter(),
              const SizedBox(height: 24),
            ],
          ),
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
              errorBuilder: (_, _, _) =>
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
              errorBuilder: (_, _, _) =>
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
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }
}
