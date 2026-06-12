import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/otp_input_field.dart';

class ForgotPasswordOtpScreen extends ConsumerStatefulWidget {
  final String driverId;
  const ForgotPasswordOtpScreen({super.key, required this.driverId});

  @override
  ConsumerState<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends ConsumerState<ForgotPasswordOtpScreen> {
  String _currentOtp = '';
  bool _isLoading = false;
  int _countdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _countdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleVerify() async {
    if (_currentOtp.length != 6) return;
    
    // Pass OTP to next screen
    context.push(
      RouteNames.resetPassword,
      extra: {
        'driverId': widget.driverId,
        'otp': _currentOtp,
      },
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verify Phone',
                style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to your registered phone number.',
                style: AppTextStyles.bodyMedium.copyWith(color: textMutedColor),
              ),
              const SizedBox(height: 32),
              OtpInputField(
                length: 6,
                onChanged: (value) {
                  setState(() => _currentOtp = value);
                },
                onCompleted: (value) {
                  setState(() => _currentOtp = value);
                  _handleVerify();
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: AppTextStyles.bodyMedium.copyWith(color: textMutedColor),
                  ),
                  GestureDetector(
                    onTap: _countdown == 0 ? () {
                      _startTimer();
                      // Would normally call resend OTP here
                    } : null,
                    child: Text(
                      _countdown > 0 ? "Resend in ${_countdown}s" : "Resend",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _countdown > 0 ? textMutedColor : AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _currentOtp.length == 6 ? _handleVerify : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Verify",
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
