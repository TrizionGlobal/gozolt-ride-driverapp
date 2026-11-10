import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/delivery_history_record.dart';
import '../providers/delivery_history_provider.dart';
import '../providers/food_grocery_delivery_home_provider.dart';

class DeliveryCashActivityScreen extends ConsumerWidget {
  const DeliveryCashActivityScreen({
    super.key,
    required this.serviceType,
    required this.onBack,
  });

  final PartnerServiceType serviceType;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final history = ref.watch(
      deliveryHistoryProvider(serviceType),
    );

    final homeState = ref.watch(
      foodGroceryDeliveryHomeProvider(serviceType),
    );

    final cashRecords = history.records
        .where(
          (record) => record.wasCashPayment,
        )
        .toList(growable: false);

    final backgroundColor =
        isDark ? AppColors.backgroundDarker : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: const Color(0xFF04213C),
        elevation: 0,
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: Text(
          'Cash Activity',
          style: AppTextStyles.titleMedium.copyWith(
            color: const Color(0xFF04213C),
            fontWeight: FontWeight.w700,
          ),
        ),
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
            _CashSummaryCard(
              isDark: isDark,
              cashCollected: homeState.todaySummary.cashCollected,
              cashDeliveryCount: cashRecords.length,
            ),
            const SizedBox(height: 14),
            _CashNoticeCard(
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            Text(
              'Recent cash deliveries',
              style: AppTextStyles.titleMedium.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 11),
            if (cashRecords.isEmpty)
              _EmptyCashView(
                isDark: isDark,
              )
            else
              ...cashRecords.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: _CashDeliveryCard(
                    isDark: isDark,
                    record: record,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CashSummaryCard extends StatelessWidget {
  const _CashSummaryCard({
    required this.isDark,
    required this.cashCollected,
    required this.cashDeliveryCount,
  });

  final bool isDark;
  final double cashCollected;
  final int cashDeliveryCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(
          alpha: isDark ? 0.14 : 0.11,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 28,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash collected today',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '€${cashCollected.toStringAsFixed(2)}',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cashDeliveryCount completed cash '
                  '${cashDeliveryCount == 1 ? 'delivery' : 'deliveries'}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CashNoticeCard extends StatelessWidget {
  const _CashNoticeCard({
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.info,
            size: 22,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Cash collected is the customer’s order payment. '
              'It is recorded separately from your delivery earnings '
              'and will be reconciled according to GOZOLT policy.',
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

class _CashDeliveryCard extends StatelessWidget {
  const _CashDeliveryCard({
    required this.isDark,
    required this.record,
  });

  final bool isDark;
  final DeliveryHistoryRecord record;

  String _formatDate(DateTime value) {
    final localValue = value.toLocal();

    final day = localValue.day.toString().padLeft(2, '0');
    final month = localValue.month.toString().padLeft(2, '0');
    final hour = localValue.hour.toString().padLeft(2, '0');
    final minute = localValue.minute.toString().padLeft(2, '0');

    return '$day/$month • $hour:$minute';
  }

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
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 22,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(record.completedAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '€${record.cashCollected.toStringAsFixed(2)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _CashDetailRow(
            isDark: isDark,
            label: 'Order reference',
            value: record.orderId,
          ),
          const SizedBox(height: 8),
          _CashDetailRow(
            isDark: isDark,
            label: 'Delivery earning',
            value: '€${record.deliveryEarning.toStringAsFixed(2)}',
            valueColor: AppColors.success,
          ),
          const SizedBox(height: 8),
          _CashDetailRow(
            isDark: isDark,
            label: 'Status',
            value: 'Recorded',
            valueColor: AppColors.info,
          ),
        ],
      ),
    );
  }
}

class _CashDetailRow extends StatelessWidget {
  const _CashDetailRow({
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
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodySmall.copyWith(
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

class _EmptyCashView extends StatelessWidget {
  const _EmptyCashView({
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        28,
        20,
        28,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.money_off_csred_outlined,
            size: 48,
            color: AppColors.primaryGold,
          ),
          const SizedBox(height: 13),
          Text(
            'No completed cash deliveries',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Completed cash deliveries will appear here.',
            textAlign: TextAlign.center,
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
