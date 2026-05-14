import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/models/auth_state.dart';
import 'providers/auth_provider.dart';
import 'providers/login_form_provider.dart';
import 'widgets/otp_input_field.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpKey = GlobalKey<OtpInputFieldState>();
  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;
  bool _hasError = false;
  String? _errorText;
  String _currentOtp = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendSeconds = 30;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onOtpCompleted(String otp) {
    setState(() {
      _currentOtp = otp;
      _hasError = false;
      _errorText = null;
    });
    _verify();
  }

  void _onOtpChanged(String otp) {
    _currentOtp = otp;
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorText = null;
      });
    }
  }

  Future<void> _verify() async {
    if (_currentOtp.length != 6) return;
    HapticFeedback.mediumImpact();

    final phoneNumber = ref.read(loginFormProvider).phoneNumber;
    await ref.read(authProvider.notifier).verifyOtp(
          phoneNumber: phoneNumber,
          otp: _currentOtp,
        );
  }

  void _resendOtp() {
    if (!_canResend) return;
    HapticFeedback.lightImpact();
    final phoneNumber = ref.read(loginFormProvider).phoneNumber;
    ref.read(authProvider.notifier).sendOtp(phoneNumber);
    
    _otpKey.currentState?.clear();
    setState(() {
      _currentOtp = '';
      _hasError = false;
      _errorText = null;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go(RouteNames.home);
      } else if (next is AuthError) {
        setState(() {
          _hasError = true;
          _errorText = next.message;
        });
        _otpKey.currentState?.shake();
      }
    });

    final phoneNumber = ref.watch(loginFormProvider).phoneNumber;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
                color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Verify Your Number',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "We've sent a 6-digit code to\n$phoneNumber",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              OtpInputField(
                key: _otpKey,
                length: 6,
                onCompleted: _onOtpCompleted,
                onChanged: _onOtpChanged,
                hasError: _hasError,
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorText!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  _canResend
                      ? TextButton(
                          onPressed: _resendOtp,
                          child: Text(
                            'Resend',
                            style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryGold),
                          ),
                        )
                      : Text(
                          'Resend in ${_resendSeconds}s',
                          style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryGold),
                        ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading || _currentOtp.length != 6 ? null : _verify,
                  child: isLoading
                      ? CircularProgressIndicator(color: Theme.of(context).scaffoldBackgroundColor)
                      : const Text(
                          'Verify & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E), // Hardcode to background color for contrast
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
