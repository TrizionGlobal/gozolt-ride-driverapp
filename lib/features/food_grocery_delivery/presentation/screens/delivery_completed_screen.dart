import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../providers/food_grocery_delivery_session_provider.dart';

class DeliveryCompletedScreen extends ConsumerWidget {
  const DeliveryCompletedScreen({
    super.key,
    required this.serviceType,
    required this.onReturnHome,
  });

  final PartnerServiceType serviceType;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final session = ref.watch(
      foodGroceryDeliverySessionProvider(serviceType),
    );

    final job = session.activeJob;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: AppColors.primaryGold,
          foregroundColor: const Color(0xFF04213C),
          elevation: 0,
          title: Text(
            'Delivery Completed',
            style: AppTextStyles.titleMedium.copyWith(
              color: const Color(0xFF04213C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: job == null
            ? _MissingDeliveryView(
                isDark: isDark,
                onReturnHome: onReturnHome,
              )
            : SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    22,
                    16,
                    28,
                  ),
                  children: [
                    _SuccessCard(
                      isDark: isDark,
                      deliveryType: job.deliveryTypeLabel,
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      isDark: isDark,
                      title: 'DELIVERY SUMMARY',
                      icon: Icons.receipt_long_outlined,
                      child: Column(
                        children: [
                          _SummaryRow(
                            isDark: isDark,
                            label: 'Order reference',
                            value: job.orderId,
                          ),
                          const SizedBox(height: 11),
                          _SummaryRow(
                            isDark: isDark,
                            label: 'Delivery type',
                            value: job.deliveryTypeLabel,
                          ),
                          const SizedBox(height: 11),
                          _SummaryRow(
                            isDark: isDark,
                            label: job.businessTypeLabel,
                            value: job.businessName,
                          ),
                          const SizedBox(height: 11),
                          _SummaryRow(
                            isDark: isDark,
                            label: 'Customer',
                            value: job.customerName,
                          ),
                          const SizedBox(height: 11),
                          _SummaryRow(
                            isDark: isDark,
                            label: 'Packages',
                            value: job.packageLabel,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      isDark: isDark,
                      title: 'PAYMENT',
                      icon: Icons.account_balance_wallet_outlined,
                      child: Column(
                        children: [
                          _SummaryRow(
                            isDark: isDark,
                            label: 'Payment method',
                            value: job.paymentMethod.displayName,
                          ),
                          if (job.paymentMethod.requiresCashCollection) ...[
                            const SizedBox(height: 11),
                            _SummaryRow(
                              isDark: isDark,
                              label: 'Cash collected',
                              value:
                                  '€${(job.cashAmountToCollect ?? 0).toStringAsFixed(2)}',
                              valueColor: AppColors.success,
                            ),
                          ],
                          const SizedBox(height: 11),
                          _SummaryRow(
                            isDark: isDark,
                            label: 'Your earning',
                            value:
                                '€${job.estimatedEarning.toStringAsFixed(2)}',
                            valueColor: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SettlementCard(
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: job == null
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    12,
                  ),
                  color: isDark
                      ? AppColors.backgroundSecondary
                      : AppColors.surfaceLight,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: onReturnHome,
                      icon: const Icon(
                        Icons.home_outlined,
                        size: 20,
                      ),
                      label: const Text(
                        'Return to delivery home',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: const Color(0xFF04213C),
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
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.isDark,
    required this.deliveryType,
  });

  final bool isDark;
  final String deliveryType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        22,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.40),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Delivery completed',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$deliveryType was successfully delivered and verified.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.40),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 22,
            color: AppColors.primaryGold,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Your delivery earning has been added to pending earnings. '
              'Settlement will be processed according to the GOZOLT payout cycle.',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.child,
  });

  final bool isDark;
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.isDark,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final bool isDark;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
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
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ??
                  (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
              fontWeight: FontWeight.w700,
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
    required this.onReturnHome,
  });

  final bool isDark;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 58,
              color: AppColors.primaryGold,
            ),
            const SizedBox(height: 16),
            Text(
              'Delivery details unavailable',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onReturnHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: const Color(0xFF04213C),
              ),
              child: const Text('Return to home'),
            ),
          ],
        ),
      ),
    );
  }
}
