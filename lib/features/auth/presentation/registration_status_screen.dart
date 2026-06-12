import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/snackbar_utils.dart';

class RegistrationStatusScreen extends StatefulWidget {
  final bool isFleet;
  final String? phone;

  const RegistrationStatusScreen({
    super.key,
    required this.isFleet,
    this.phone,
  });

  @override
  State<RegistrationStatusScreen> createState() => _RegistrationStatusScreenState();
}

class _RegistrationStatusScreenState extends State<RegistrationStatusScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  bool _isChecking = false;

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    if (widget.phone == null) {
      SnackbarUtils.showInfo(context, 'Checking live status... Application is still under review.');
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final dio = createDio();
      final response = await dio.get(
        '${ApiConstants.driverRegistrationStatus}?phone=${Uri.encodeComponent(widget.phone!)}',
      );
      
      if (mounted) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String?;
        final driverId = data['driverId'] as String?;

        if (status == 'ACTIVE' || status == 'APPROVED') {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                  SizedBox(width: 10),
                  Text('Application Approved!', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Congratulations! Your driver application has been successfully approved.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Your Driver ID:', style: TextStyle(color: Colors.white70)),
                        Text(
                          driverId ?? 'N/A',
                          style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please check your email for your temporary password to log in.',
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go(RouteNames.welcome);
                  },
                  child: const Text('LOG IN NOW', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else {
          SnackbarUtils.showInfo(context, 'Status: ${status?.replaceAll('_', ' ') ?? 'UNDER REVIEW'}. Application is still being processed.');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Unable to fetch status. Application is still under review.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _contactSupport() async {
    final bodyText = widget.phone != null ? 'My registered phone number is: ${widget.phone}' : '';
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@gozolt.com',
      query: 'subject=Gozolt Driver Onboarding Support Request&body=${Uri.encodeComponent(bodyText)}',
    );
    try {
      if (!await launchUrl(emailLaunchUri)) {
        throw 'Could not launch email client';
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showInfo(context, 'Support email: support@gozolt.com');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundPrimary : Colors.white;
    final cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Shield Header
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primaryGold,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Application Under Review',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle/Info Text
                Text(
                  'Your application is being reviewed. Once approved, you will receive an email with your login details.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Status Steps visualizer card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStepRow(
                        context,
                        title: 'Phone OTP Verified',
                        isCompleted: true,
                        isPending: false,
                      ),
                      _buildStepDivider(),
                      _buildStepRow(
                        context,
                        title: 'Application Documents Received',
                        isCompleted: true,
                        isPending: false,
                      ),
                      _buildStepDivider(),
                      _buildStepRow(
                        context,
                        title: widget.isFleet
                            ? 'Supplier Approval & Verification'
                            : 'Document Verification',
                        isCompleted: false,
                        isPending: false,
                        isInProgress: true,
                      ),
                      _buildStepDivider(),
                      _buildStepRow(
                        context,
                        title: 'Login Credentials Emailed',
                        isCompleted: false,
                        isPending: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Action buttons
                ElevatedButton(
                  onPressed: _isChecking ? null : _checkStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Check Live Status',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _contactSupport,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    side: BorderSide(
                      color: isDark ? Colors.white30 : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Contact Support',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Pop back to welcome/login screen
                    context.go(RouteNames.welcome);
                  },
                  child: const Text(
                    'Back to Welcome Screen',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context, {
    required String title,
    required bool isCompleted,
    required bool isPending,
    bool isInProgress = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget statusIcon;

    if (isCompleted) {
      statusIcon = const Icon(
        Icons.check_circle_rounded,
        color: Colors.green,
        size: 24,
      );
    } else if (isInProgress) {
      statusIcon = const Icon(
        Icons.hourglass_empty_rounded,
        color: AppColors.primaryGold,
        size: 22,
      );
    } else {
      statusIcon = Icon(
        Icons.radio_button_off_rounded,
        color: isDark ? Colors.white30 : Colors.black26,
        size: 24,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          statusIcon,
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isCompleted || isInProgress
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: isCompleted
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isInProgress
                        ? AppColors.primaryGold
                        : (isDark ? Colors.white30 : Colors.black38)),
              ),
            ),
          ),
          if (isInProgress)
            const Text(
              'In Progress',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryGold,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 2,
          height: 16,
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
    );
  }
}
