import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/models/auth_state.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _driverIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _driverIdController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final driverId = _driverIdController.text.trim();
    if (driverId.isEmpty) {
      SnackbarUtils.showError(context, 'Please enter your Driver ID');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).forgotPassword(driverId);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.push(RouteNames.resetPassword, extra: {'driverId': driverId});
      } else {
        // The error is already handled and shown by the AuthNotifier state listener if we wanted, 
        // but let's just let the AuthNotifier update the state and we show a snackbar here if there's an error.
        final state = ref.read(authProvider);
        if (state is AuthError) {
          SnackbarUtils.showError(context, state.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMutedColor = isDark ? AppColors.textMuted : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset Password',
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your Driver ID to create a new password.',
                style: AppTextStyles.bodyMedium.copyWith(color: textMutedColor),
              ),
              const SizedBox(height: 32),
              Text(
                "Driver ID",
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _driverIdController,
                keyboardType: TextInputType.text,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'Enter Driver ID',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
