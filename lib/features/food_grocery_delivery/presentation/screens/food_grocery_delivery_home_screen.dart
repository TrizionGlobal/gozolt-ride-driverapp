import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../../partner_services/presentation/providers/partner_service_provider.dart';
import '../providers/food_grocery_delivery_home_provider.dart';
import '../../../partner_services/presentation/providers/partner_availability_provider.dart';
import '../../domain/models/active_delivery_summary.dart';
import '../../../home/presentation/widgets/bottom_nav_bar.dart';

class FoodGroceryDeliveryHomeScreen extends ConsumerWidget {
  const FoodGroceryDeliveryHomeScreen({
    super.key,
    required this.serviceType,
    this.onChangeService,
    this.onContinueDelivery,
    this.onSimulateIncomingRequest,
    this.onNavigationSelected,
  }) : assert(
          serviceType == PartnerServiceType.foodDelivery ||
              serviceType == PartnerServiceType.groceryDelivery,
          'Delivery Home requires Food or Grocery service type.',
        );

  final PartnerServiceType serviceType;
  final VoidCallback? onChangeService;
  final VoidCallback? onContinueDelivery;
  final ValueChanged<int>? onNavigationSelected;
  final VoidCallback? onSimulateIncomingRequest;

  bool get _isFoodDelivery {
    return serviceType == PartnerServiceType.foodDelivery;
  }

  IconData get _serviceIcon {
    return _isFoodDelivery
        ? Icons.restaurant_rounded
        : Icons.shopping_basket_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final homeState = ref.watch(
      foodGroceryDeliveryHomeProvider(serviceType),
    );

    final homeNotifier = ref.read(
      foodGroceryDeliveryHomeProvider(serviceType).notifier,
    );

    final partnerServiceState = ref.watch(
      partnerServiceProvider,
    );

    final availabilityState = ref.watch(
      partnerAvailabilityProvider,
    );

    final availabilityNotifier = ref.read(
      partnerAvailabilityProvider.notifier,
    );

    final isServiceOnline = availabilityState.isServiceOnline(
      serviceType,
    );

    final showIndividualAvailability =
        availabilityState.showIndividualAvailabilityControls;

    final backgroundColor =
        isDark ? AppColors.backgroundDarker : AppColors.backgroundLight;

    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(
                  alpha: isDark ? 0.18 : 0.15,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _serviceIcon,
                size: 23,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceType.displayName,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'GOZOLT Go Partner',
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
        actions: [
          if (onChangeService != null)
            IconButton(
              onPressed: homeState.hasActiveDelivery && !kDebugMode
                  ? null
                  : onChangeService,
              tooltip: homeState.hasActiveDelivery && !kDebugMode
                  ? 'Complete your active delivery first'
                  : 'Change service',
              icon: Icon(
                Icons.grid_view_rounded,
                color: homeState.hasActiveDelivery
                    ? AppColors.textMuted
                    : primaryTextColor,
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            28,
          ),
          children: [
            if (availabilityState.errorMessage != null) ...[
              _ErrorBanner(
                message: availabilityState.errorMessage!,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
            ],
            if (homeState.errorMessage != null) ...[
              _ErrorBanner(
                message: homeState.errorMessage!,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
            ],
            if (showIndividualAvailability) ...[
              _AvailabilityCard(
                isDark: isDark,
                isOnline: isServiceOnline,
                isUpdating: availabilityState.isUpdating ||
                    homeState.isUpdatingAvailability,
                onChanged: (value) async {
                  final success = await availabilityNotifier.setServiceOnline(
                    service: serviceType,
                    value: value,
                    approvedServices: partnerServiceState.approvedServices,
                  );

                  if (!success) {
                    return;
                  }

                  // Keeps the existing delivery-home provider synchronized until
                  // availability is supplied by the backend API.
                  homeNotifier.setOnline(value);
                },
              ),
              const SizedBox(height: 16),
            ],
            _SectionHeading(
              title: 'Current delivery',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            if (homeState.hasActiveDelivery)
              _ActiveDeliveryCard(
                isDark: isDark,
                delivery: homeState.activeDelivery!,
                onContinue: onContinueDelivery,
              )
            else ...[
              _NoActiveDeliveryCard(
                isDark: isDark,
                isOnline: isServiceOnline,
                serviceType: serviceType,
              ),
              if (isServiceOnline && onSimulateIncomingRequest != null) ...[
                const SizedBox(height: 12),

                // TODO(FOOD_GROCERY_SOCKET):
                // Remove this temporary button when delivery offers are opened
                // automatically from WebSocket events
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onSimulateIncomingRequest,
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                      size: 20,
                    ),
                    label: const Text(
                      'Simulate incoming request',
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
              ],
            ],
            const SizedBox(height: 20),
            _SectionHeading(
              title: 'Today’s summary',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _TodaySummaryGrid(
              isDark: isDark,
              completedDeliveries: homeState.todaySummary.completedDeliveries,
              deliveryEarnings: homeState.todaySummary.deliveryEarnings,
              pendingEarnings: homeState.todaySummary.pendingEarnings,
              cashCollected: homeState.todaySummary.cashCollected,
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            return;
          }

          if (onNavigationSelected != null) {
            onNavigationSelected!(index);
            return;
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'This delivery section will be available soon.',
                ),
              ),
            );
        },
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.isDark,
    required this.isOnline,
    required this.isUpdating,
    required this.onChanged,
  });

  final bool isDark;
  final bool isOnline;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    final statusColor = isOnline ? AppColors.success : secondaryTextColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(
            alpha: isOnline ? 0.45 : 0.22,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: isUpdating
                ? Padding(
                    padding: const EdgeInsets.all(15),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: statusColor,
                    ),
                  )
                : Icon(
                    isOnline
                        ? Icons.wifi_tethering_rounded
                        : Icons.power_settings_new_rounded,
                    color: statusColor,
                    size: 27,
                  ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'You’re online' : 'You’re offline',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline
                      ? 'You can receive eligible delivery requests.'
                      : 'Go online to receive delivery requests.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: secondaryTextColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isOnline,
            onChanged: isUpdating ? null : onChanged,
            activeTrackColor: AppColors.success,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.isDark,
  });

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _NoActiveDeliveryCard extends StatelessWidget {
  const _NoActiveDeliveryCard({
    required this.isDark,
    required this.isOnline,
    required this.serviceType,
  });

  final bool isDark;
  final bool isOnline;
  final PartnerServiceType serviceType;

  @override
  Widget build(BuildContext context) {
    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(
                alpha: isDark ? 0.16 : 0.13,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              serviceType == PartnerServiceType.foodDelivery
                  ? Icons.delivery_dining_rounded
                  : Icons.local_shipping_outlined,
              color: AppColors.primaryGold,
              size: 31,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            'No active delivery',
            style: AppTextStyles.titleMedium.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isOnline
                ? 'You’re ready. A new delivery request will appear here.'
                : 'Go online when you’re ready to start receiving requests.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: secondaryTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveDeliveryCard extends StatelessWidget {
  const _ActiveDeliveryCard({
    required this.isDark,
    required this.delivery,
    required this.onContinue,
  });

  final bool isDark;
  final ActiveDeliverySummary delivery;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.delivery_dining_rounded,
                color: AppColors.primaryGold,
                size: 27,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  delivery.businessName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  delivery.businessTypeLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DeliveryDetailRow(
            label: 'Order',
            value: delivery.orderId,
            isDark: isDark,
          ),
          const SizedBox(height: 9),
          _DeliveryDetailRow(
            label: 'Current stage',
            value: delivery.stage.displayName,
            isDark: isDark,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: const Color(0xFF04213C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Continue delivery',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (onContinue == null) ...[
            const SizedBox(height: 8),
            Text(
              'Delivery continuation will be connected in FG-GP-03.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryDetailRow extends StatelessWidget {
  const _DeliveryDetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TodaySummaryGrid extends StatelessWidget {
  const _TodaySummaryGrid({
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                isDark: isDark,
                icon: Icons.check_circle_outline_rounded,
                label: 'Completed',
                value: '$completedDeliveries',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
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
              child: _SummaryCard(
                isDark: isDark,
                icon: Icons.schedule_rounded,
                label: 'Pending earnings',
                value: '€${pendingEarnings.toStringAsFixed(2)}',
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                isDark: isDark,
                icon: Icons.account_balance_wallet_outlined,
                label: 'Cash collected',
                value: '€${cashCollected.toStringAsFixed(2)}',
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.isDark,
  });

  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 21,
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
