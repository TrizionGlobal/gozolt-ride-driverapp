import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/delivery_payment_method.dart';
import '../providers/food_grocery_delivery_session_provider.dart';
import '../providers/handover_verification_provider.dart';

class CustomerHandoverScreen extends ConsumerStatefulWidget {
  const CustomerHandoverScreen({
    super.key,
    required this.serviceType,
    required this.onBack,
    required this.onVerified,
  });

  final PartnerServiceType serviceType;
  final VoidCallback onBack;
  final VoidCallback onVerified;

  @override
  ConsumerState<CustomerHandoverScreen> createState() =>
      _CustomerHandoverScreenState();
}

class _CustomerHandoverScreenState
    extends ConsumerState<CustomerHandoverScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    FocusScope.of(context).unfocus();

    final verified = await ref
        .read(
          handoverVerificationProvider(
            widget.serviceType,
          ).notifier,
        )
        .verifyPin();

    _pinController.clear();

    if (!mounted || !verified) {
      return;
    }

    widget.onVerified();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final session = ref.watch(
      foodGroceryDeliverySessionProvider(
        widget.serviceType,
      ),
    );

    final verification = ref.watch(
      handoverVerificationProvider(
        widget.serviceType,
      ),
    );

    final job = session.activeJob;

    if (job == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundSecondary : AppColors.backgroundLight,
        appBar: _buildAppBar(
          title: 'Delivery Verification',
        ),
        body: _MissingDeliveryView(
          isDark: isDark,
          onBack: widget.onBack,
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundSecondary : AppColors.backgroundLight,
      appBar: _buildAppBar(
        title: 'Verify Delivery',
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            28,
          ),
          children: [
            _OrderReferenceCard(
              isDark: isDark,
              customerName: job.customerName,
              orderId: job.orderId,
              packageLabel: job.packageLabel,
              paymentMethod: job.paymentMethod,
              cashAmountToCollect: job.cashAmountToCollect,
            ),
            const SizedBox(height: 14),
            Text(
              'Delivery PIN verification',
              style: AppTextStyles.titleMedium.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _PinVerificationPanel(
              isDark: isDark,
              controller: _pinController,
              enabled: !verification.isVerifying &&
                  !verification.isVerified &&
                  !verification.isLocked,
              remainingAttempts: verification.remainingAttempts,
              onChanged: (value) {
                ref
                    .read(
                      handoverVerificationProvider(
                        widget.serviceType,
                      ).notifier,
                    )
                    .updatePin(value);
              },
            ),
            if (verification.errorMessage != null) ...[
              const SizedBox(height: 14),
              _ErrorMessageCard(
                message: verification.errorMessage!,
              ),
            ],
            const SizedBox(height: 14),
            _SecurityNotice(
              isDark: isDark,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            12,
          ),
          decoration: BoxDecoration(
            color:
                isDark ? AppColors.backgroundSecondary : AppColors.surfaceLight,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.textMuted.withValues(alpha: 0.22)
                    : AppColors.textMutedLight.withValues(alpha: 0.30),
              ),
            ),
          ),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: verification.isLocked ||
                      verification.isVerified ||
                      verification.isVerifying ||
                      !verification.canSubmitPin
                  ? null
                  : _verifyPin,
              icon: verification.isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF04213C),
                      ),
                    )
                  : const Icon(
                      Icons.verified_user_outlined,
                      size: 20,
                    ),
              label: Text(
                verification.isVerified
                    ? 'Delivery verified'
                    : verification.isVerifying
                        ? 'Verifying delivery'
                        : 'Verify delivery PIN',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: verification.isVerified
                    ? AppColors.success
                    : AppColors.primaryGold,
                foregroundColor: const Color(0xFF04213C),
                disabledBackgroundColor: verification.isVerified
                    ? AppColors.success
                    : AppColors.primaryGold.withValues(alpha: 0.45),
                disabledForegroundColor:
                    const Color(0xFF04213C).withValues(alpha: 0.70),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar({
    required String title,
  }) {
    return AppBar(
      backgroundColor: AppColors.primaryGold,
      foregroundColor: const Color(0xFF04213C),
      elevation: 0,
      leading: IconButton(
        onPressed: widget.onBack,
        icon: const Icon(
          Icons.arrow_back_rounded,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: const Color(0xFF04213C),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PinVerificationPanel extends StatelessWidget {
  const _PinVerificationPanel({
    required this.isDark,
    required this.controller,
    required this.enabled,
    required this.remainingAttempts,
    required this.onChanged,
  });

  final bool isDark;
  final TextEditingController controller;
  final bool enabled;
  final int remainingAttempts;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.pin_outlined,
            size: 46,
            color: AppColors.primaryGold,
          ),
          const SizedBox(height: 12),
          Text(
            'Enter the 4-digit delivery PIN',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Ask the customer for the delivery PIN shown in the GOZOLT app.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            obscureText: true,
            obscuringCharacter: '●',
            maxLength: 4,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: onChanged,
            style: AppTextStyles.headlineSmall.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 12,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              filled: true,
              fillColor:
                  isDark ? AppColors.surfaceInput : AppColors.surfaceInputLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.primaryGold.withValues(alpha: 0.45),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryGold,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Temporary testing PIN: 1357',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$remainingAttempts verification attempts available',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderReferenceCard extends StatelessWidget {
  const _OrderReferenceCard({
    required this.isDark,
    required this.customerName,
    required this.orderId,
    required this.packageLabel,
    required this.paymentMethod,
    required this.cashAmountToCollect,
  });

  final bool isDark;
  final String customerName;
  final String orderId;
  final String packageLabel;
  final DeliveryPaymentMethod paymentMethod;
  final double? cashAmountToCollect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.textMuted.withValues(alpha: 0.22)
              : AppColors.textMutedLight.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        children: [
          _ReferenceRow(
            isDark: isDark,
            label: 'Customer',
            value: customerName,
          ),
          const SizedBox(height: 11),
          _ReferenceRow(
            isDark: isDark,
            label: 'Order reference',
            value: orderId,
            emphasize: true,
          ),
          const SizedBox(height: 11),
          _ReferenceRow(
            isDark: isDark,
            label: 'Packages',
            value: packageLabel,
          ),
        ],
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({
    required this.isDark,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final bool isDark;
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(
              color: emphasize
                  ? AppColors.primaryGold
                  : isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorMessageCard extends StatelessWidget {
  const _ErrorMessageCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice({
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 18,
          color: AppColors.success,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Customer handover verification is securely linked to this delivery. '
            'Never request or share a verification code outside the GOZOLT app.',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _MissingDeliveryView extends StatelessWidget {
  const _MissingDeliveryView({
    required this.isDark,
    required this.onBack,
  });

  final bool isDark;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              'No active delivery found',
              style: AppTextStyles.titleMedium.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onBack,
              child: const Text('Back to customer'),
            ),
          ],
        ),
      ),
    );
  }
}
