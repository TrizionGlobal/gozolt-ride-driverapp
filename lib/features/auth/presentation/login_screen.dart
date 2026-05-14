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
import 'package:gozolt_driver/features/auth/domain/models/country_code.dart';
import 'providers/auth_provider.dart';
import 'providers/login_form_provider.dart';
import 'widgets/country_code_picker.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRememberedPhone();
  }

  Future<void> _loadRememberedPhone() async {
    final storage = ref.read(secureStorageProvider);
    final rememberMe = await storage.getRememberMe();
    if (rememberMe) {
      final savedPhone = await storage.getSavedDriverId(); // Reuse the same slot for now
      if (savedPhone != null && mounted) {
        _phoneController.text = savedPhone;
        ref.read(loginFormProvider.notifier).prefillPhoneNumber(savedPhone);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final formState = ref.read(loginFormProvider);
    if (!formState.isValid) return;

    final success = await ref.read(authProvider.notifier).sendOtp(formState.fullPhoneNumber);
    if (success && mounted) {
      context.push(RouteNames.otp);
    }
  }

  void _showCountryPicker() {
    final formState = ref.read(loginFormProvider);
    final selectedCountry = supportedCountryCodes.firstWhere(
      (c) => c.dialCode == formState.dialCode,
      orElse: () => supportedCountryCodes.first,
    );

    CountryCodePicker.show(
      context,
      selected: selectedCountry,
      onSelected: (country) {
        ref.read(loginFormProvider.notifier).setDialCode(country.dialCode);
      },
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                "Login with your phone number to continue",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Error message
              if (formState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
              // Phone field
              Text(
                "Phone Number",
                style: AppTextStyles.titleSmall.copyWith(
                  color: Theme.of(context).textTheme.titleSmall?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                onChanged: ref.read(loginFormProvider.notifier).setPhoneNumber,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: '0000 0000',
                  prefixIcon: GestureDetector(
                    onTap: _showCountryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            supportedCountryCodes.firstWhere(
                              (c) => c.dialCode == formState.dialCode,
                              orElse: () => supportedCountryCodes.first,
                            ).flag,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formState.dialCode,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                        checkColor: Theme.of(context).scaffoldBackgroundColor,
                        side: BorderSide(
                          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted,
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.rememberMe,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
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
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onPrimary,
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
                      fontWeight: FontWeight.w600,
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
