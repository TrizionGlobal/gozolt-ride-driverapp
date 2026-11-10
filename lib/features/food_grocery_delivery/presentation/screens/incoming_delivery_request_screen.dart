import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/delivery_payment_method.dart';
import '../../domain/models/incoming_delivery_request.dart';
import '../providers/incoming_delivery_request_provider.dart';

/// FG-GP-02 screen for accepting or declining a delivery offer.
class IncomingDeliveryRequestScreen extends ConsumerWidget {
  const IncomingDeliveryRequestScreen({
    super.key,
    required this.serviceType,
    required this.onAccepted,
    required this.onDeclined,
  }) : assert(
          serviceType == PartnerServiceType.foodDelivery ||
              serviceType == PartnerServiceType.groceryDelivery,
          'Incoming requests require Food or Grocery service type.',
        );

  final PartnerServiceType serviceType;
  final VoidCallback onAccepted;
  final VoidCallback onDeclined;

  Future<void> _acceptRequest(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final accepted = await ref
        .read(
          incomingDeliveryRequestProvider(
            serviceType,
          ).notifier,
        )
        .acceptRequest();

    if (!context.mounted) {
      return;
    }

    if (accepted) {
      onAccepted();
      return;
    }

    final message = ref
            .read(
              incomingDeliveryRequestProvider(
                serviceType,
              ),
            )
            .errorMessage ??
        'This delivery is no longer available.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
  }

  void _declineRequest(WidgetRef ref) {
    ref
        .read(
          incomingDeliveryRequestProvider(
            serviceType,
          ).notifier,
        )
        .declineRequest();

    onDeclined();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final requestState = ref.watch(
      incomingDeliveryRequestProvider(serviceType),
    );

    final request = requestState.request;

    if (request == null ||
        requestState.outcome == DeliveryRequestOutcome.expired ||
        requestState.outcome == DeliveryRequestOutcome.unavailable) {
      return _RequestUnavailableScreen(
        isDark: isDark,
        message: requestState.errorMessage ??
            'This delivery is no longer available.',
        onReturn: onDeclined,
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDarker : AppColors.backgroundLight,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor:
              isDark ? AppColors.backgroundDarker : AppColors.backgroundLight,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'New delivery request',
            style: AppTextStyles.titleLarge.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
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
              _CountdownCard(
                isDark: isDark,
                secondsRemaining: requestState.secondsRemaining,
                progress: requestState.countdownProgress,
              ),
              const SizedBox(height: 14),
              _RequestSummaryCard(
                isDark: isDark,
                request: request,
              ),
              const SizedBox(height: 14),
              _RouteDetailsCard(
                isDark: isDark,
                request: request,
              ),
              const SizedBox(height: 14),
              _DecisionDetailsCard(
                isDark: isDark,
                request: request,
              ),
              if (request.paymentMethod.requiresCashCollection) ...[
                const SizedBox(height: 14),
                _CashCollectionNotice(
                  isDark: isDark,
                  amount: request.cashAmountToCollect!,
                ),
              ],
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
              color: isDark
                  ? AppColors.backgroundSecondary
                  : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.textMuted.withValues(
                          alpha: 0.25,
                        )
                      : AppColors.textMutedLight.withValues(
                          alpha: 0.25,
                        ),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: requestState.isResponding
                          ? null
                          : () => _declineRequest(ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Decline',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          requestState.isResponding || !requestState.isAvailable
                              ? null
                              : () => _acceptRequest(
                                    context,
                                    ref,
                                  ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: const Color(0xFF04213C),
                        disabledBackgroundColor:
                            AppColors.primaryGold.withValues(
                          alpha: 0.45,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: requestState.isResponding
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF04213C),
                              ),
                            )
                          : Text(
                              'Accept delivery',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({
    required this.isDark,
    required this.secondsRemaining,
    required this.progress,
  });

  final bool isDark;
  final int secondsRemaining;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final urgent = secondsRemaining <= 10;
    final statusColor = urgent ? AppColors.error : AppColors.primaryGold;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: statusColor,
                size: 22,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  urgent ? 'Request expiring soon' : 'Time to respond',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$secondsRemaining s',
                style: AppTextStyles.titleMedium.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: statusColor.withValues(
                alpha: 0.14,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({
    required this.isDark,
    required this.request,
  });

  final bool isDark;
  final IncomingDeliveryRequest request;

  @override
  Widget build(BuildContext context) {
    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(
                    alpha: isDark ? 0.18 : 0.14,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  request.isFoodDelivery
                      ? Icons.restaurant_rounded
                      : Icons.shopping_basket_rounded,
                  color: AppColors.primaryGold,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.deliveryTypeLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.businessName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      request.businessTypeLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Divider(
            height: 1,
            color: secondaryTextColor.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 13),
          _InformationRow(
            label: 'Order reference',
            value: request.orderId,
            isDark: isDark,
          ),
          const SizedBox(height: 9),
          _InformationRow(
            label: 'Packages',
            value: request.packageLabel,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _RouteDetailsCard extends StatelessWidget {
  const _RouteDetailsCard({
    required this.isDark,
    required this.request,
  });

  final bool isDark;
  final IncomingDeliveryRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          _LocationRow(
            isDark: isDark,
            icon: Icons.storefront_outlined,
            color: AppColors.primaryGold,
            title: 'Pickup',
            location: request.pickupArea,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 2,
                height: 28,
                color: AppColors.textMuted.withValues(
                  alpha: 0.35,
                ),
              ),
            ),
          ),
          _LocationRow(
            isDark: isDark,
            icon: Icons.location_on_outlined,
            color: AppColors.success,
            title: 'Customer drop area',
            location: request.customerDropArea,
          ),
          const SizedBox(height: 15),
          _InformationRow(
            label: 'Distance to pickup',
            value: '${request.distanceToPickupKm.toStringAsFixed(1)} km',
            isDark: isDark,
          ),
          const SizedBox(height: 9),
          _InformationRow(
            label: 'Estimated distance',
            value:
                '${request.estimatedDeliveryDistanceKm.toStringAsFixed(1)} km',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _DecisionDetailsCard extends StatelessWidget {
  const _DecisionDetailsCard({
    required this.isDark,
    required this.request,
  });

  final bool isDark;
  final IncomingDeliveryRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          _InformationRow(
            label: 'Estimated time',
            value: 'Approx. ${request.estimatedMinutes} min',
            isDark: isDark,
          ),
          const SizedBox(height: 11),
          _InformationRow(
            label: 'Your estimated earning',
            value: '€${request.estimatedEarning.toStringAsFixed(2)}',
            valueColor: AppColors.success,
            isDark: isDark,
          ),
          const SizedBox(height: 11),
          _InformationRow(
            label: 'Payment method',
            value: request.paymentMethod.displayName,
            valueColor: request.paymentMethod == DeliveryPaymentMethod.cash
                ? AppColors.warning
                : AppColors.info,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _CashCollectionNotice extends StatelessWidget {
  const _CashCollectionNotice({
    required this.isDark,
    required this.amount,
  });

  final bool isDark;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.warning,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash delivery',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Collect exactly €${amount.toStringAsFixed(2)} '
                  'from the customer at delivery.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                    height: 1.35,
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

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.isDark,
    required this.icon,
    required this.color,
    required this.title,
    required this.location,
  });

  final bool isDark;
  final IconData icon;
  final Color color;
  final String title;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isDark;
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
        Flexible(
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

class _RequestUnavailableScreen extends StatelessWidget {
  const _RequestUnavailableScreen({
    required this.isDark,
    required this.message,
    required this.onReturn,
  });

  final bool isDark;
  final String message;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarker : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_off_outlined,
                  color: AppColors.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Request unavailable',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: const Color(0xFF04213C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Return home',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
