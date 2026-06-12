import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/models/auth_state.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String driverId;
  const ResetPasswordScreen({super.key, required this.driverId});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  bool _hasLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final text = _passwordController.text;
    setState(() {
      _hasLength = text.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(text);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(text);
      _hasNumber = RegExp(r'[0-9]').hasMatch(text);
      _hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(text);
    });
  }

  bool get _isFormValid {
    return _hasLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecial &&
        _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _handleReset() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).resetPassword(
          driverId: widget.driverId,
          newPassword: _passwordController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go(RouteNames.resetSuccess);
      } else {
        final state = ref.read(authProvider);
        if (state is AuthError) {
          SnackbarUtils.showError(context, state.message);
        }
      }
    }
  }

  Widget _buildValidationRow(String text, bool isValid, Color textMutedColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: isValid ? Colors.green : textMutedColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: isValid ? Colors.green : textMutedColor,
            ),
          ),
        ],
      ),
    );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create New Password',
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your new password must be different from previous used passwords.',
                style: AppTextStyles.bodyMedium.copyWith(color: textMutedColor),
              ),
              const SizedBox(height: 32),

              // Password field
              Text(
                "New Password",
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                keyboardType: TextInputType.visiblePassword,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Enter new password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Validation rules
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildValidationRow('Minimum 8 characters', _hasLength, textMutedColor),
                    _buildValidationRow('At least one uppercase letter', _hasUppercase, textMutedColor),
                    _buildValidationRow('At least one lowercase letter', _hasLowercase, textMutedColor),
                    _buildValidationRow('At least one number', _hasNumber, textMutedColor),
                    _buildValidationRow('At least one special character', _hasSpecial, textMutedColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirm Password field
              Text(
                "Confirm Password",
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.visiblePassword,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
              ),
              
              if (_confirmPasswordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4),
                  child: Text(
                    'Passwords do not match',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isLoading ? _handleReset : null,
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
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
