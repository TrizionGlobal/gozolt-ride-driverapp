import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/delivery_history_record.dart';
import '../providers/delivery_history_provider.dart';
import '../providers/food_grocery_delivery_home_provider.dart';
import '../../../home/presentation/widgets/bottom_nav_bar.dart';

class DeliveryHistoryEarningsScreen extends ConsumerWidget {
  const DeliveryHistoryEarningsScreen({
    super.key,
    required this.serviceType,
    required this.initialTabIndex,
    required this.onBack,
    required this.onNavigationSelected,
  });

  final PartnerServiceType serviceType;
  final int initialTabIndex;
  final VoidCallback onBack;
  final ValueChanged<int> onNavigationSelected;

  bool get _isFoodDelivery {
    return serviceType == PartnerServiceType.foodDelivery;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final history = ref.watch(
      deliveryHistoryProvider(serviceType),
    );

    final homeState = ref.watch(
      foodGroceryDeliveryHomeProvider(serviceType),
    );

    final backgroundColor =
        isDark ? AppColors.backgroundDarker : AppColors.backgroundLight;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex == 1 ? 1 : 0,
      child: Scaffold(
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
            _isFoodDelivery
                ? 'Food Delivery Activity'
                : 'Grocery Delivery Activity',
            style: AppTextStyles.titleMedium.copyWith(
              color: const Color(0xFF04213C),
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF04213C),
            unselectedLabelColor:
                const Color(0xFF04213C).withValues(alpha: 0.55),
            indicatorColor: const Color(0xFF04213C),
            indicatorWeight: 3,
            labelStyle: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(
                icon: Icon(
                  Icons.delivery_dining_rounded,
                  size: 21,
                ),
                text: 'Deliveries',
              ),
              Tab(
                icon: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 21,
                ),
                text: 'Earnings',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DeliveriesTab(
              isDark: isDark,
              isLoading: history.isLoading,
              errorMessage: history.errorMessage,
              records: history.records,
            ),
            _EarningsTab(
              isDark: isDark,
              completedDeliveries: homeState.todaySummary.completedDeliveries,
              deliveryEarnings: homeState.todaySummary.deliveryEarnings,
              pendingEarnings: homeState.todaySummary.pendingEarnings,
              cashCollected: homeState.todaySummary.cashCollected,
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: initialTabIndex == 1 ? 1 : 2,
          onTap: onNavigationSelected,
        ),
      ),
    );
  }
}

class _DeliveriesTab extends StatelessWidget {
  const _DeliveriesTab({
    required this.isDark,
    required this.isLoading,
    required this.errorMessage,
    required this.records,
  });

  final bool isDark;
  final bool isLoading;
  final String? errorMessage;
  final List<DeliveryHistoryRecord> records;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGold,
        ),
      );
    }

    if (records.isEmpty) {
      return _EmptyHistoryView(
        isDark: isDark,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        28,
      ),
      itemCount: records.length + (errorMessage == null ? 0 : 1),
      separatorBuilder: (context, index) {
        return const SizedBox(height: 11);
      },
      itemBuilder: (context, index) {
        if (errorMessage != null && index == 0) {
          return _ErrorCard(
            isDark: isDark,
            message: errorMessage!,
          );
        }

        final recordIndex = errorMessage == null ? index : index - 1;

        return _DeliveryHistoryCard(
          isDark: isDark,
          record: records[recordIndex],
        );
      },
    );
  }
}

class _DeliveryHistoryCard extends StatelessWidget {
  const _DeliveryHistoryCard({
    required this.isDark,
    required this.record,
  });

  final bool isDark;
  final DeliveryHistoryRecord record;

  String _formatCompletedAt(DateTime value) {
    final localValue = value.toLocal();

    final day = localValue.day.toString().padLeft(2, '0');
    final month = localValue.month.toString().padLeft(2, '0');
    final year = localValue.year.toString();
    final hour = localValue.hour.toString().padLeft(2, '0');
    final minute = localValue.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
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
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  record.isFoodDelivery
                      ? Icons.restaurant_rounded
                      : Icons.shopping_basket_rounded,
                  color: AppColors.primaryGold,
                  size: 22,
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
                      _formatCompletedAt(record.completedAt),
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
                '€${record.deliveryEarning.toStringAsFixed(2)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _HistoryRow(
            isDark: isDark,
            label: 'Order',
            value: record.orderId,
          ),
          const SizedBox(height: 8),
          _HistoryRow(
            isDark: isDark,
            label: 'Customer',
            value: record.customerName,
          ),
          const SizedBox(height: 8),
          _HistoryRow(
            isDark: isDark,
            label: 'Payment',
            value: record.paymentMethodLabel,
          ),
          if (record.wasCashPayment) ...[
            const SizedBox(height: 8),
            _HistoryRow(
              isDark: isDark,
              label: 'Cash collected',
              value: '€${record.cashCollected.toStringAsFixed(2)}',
              valueColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
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
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _EarningsTab extends StatelessWidget {
  const _EarningsTab({
    required this.isDark,
    required this.completedDeliveries,
    required this.deliveryEarnings,
    required this.pendingEarnings,
    required this.cashCollected,
  });

  final bool isDark;
  final int completedDeliveries;
  final double deliveryEarnings;
  final double pendingEarnings;
  final double cashCollected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        28,
      ),
      children: [
        Text(
          'Today’s earnings summary',
          style: AppTextStyles.titleMedium.copyWith(
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _EarningCard(
                isDark: isDark,
                icon: Icons.check_circle_outline_rounded,
                label: 'Completed',
                value: '$completedDeliveries',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EarningCard(
                isDark: isDark,
                icon: Icons.payments_outlined,
                label: 'Delivery earnings',
                value: '€${deliveryEarnings.toStringAsFixed(2)}',
                color: AppColors.primaryGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _EarningCard(
                isDark: isDark,
                icon: Icons.schedule_rounded,
                label: 'Pending earnings',
                value: '€${pendingEarnings.toStringAsFixed(2)}',
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EarningCard(
                isDark: isDark,
                icon: Icons.account_balance_wallet_outlined,
                label: 'Cash collected',
                value: '€${cashCollected.toStringAsFixed(2)}',
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(15),
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
                Icons.account_balance_outlined,
                color: AppColors.primaryGold,
                size: 22,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Pending earnings will be processed according to the '
                  'GOZOLT payout and settlement cycle. Cash collected is '
                  'shown separately and is not your delivery earning.',
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
        ),
      ],
    );
  }
}

class _EarningCard extends StatelessWidget {
  const _EarningCard({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final bool isDark;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView({
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delivery_dining_outlined,
              size: 62,
              color: AppColors.primaryGold,
            ),
            const SizedBox(height: 16),
            Text(
              'No completed deliveries yet',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Completed deliveries will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.isDark,
    required this.message,
  });

  final bool isDark;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
