import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../providers/delivery_pickup_status_provider.dart';
import '../providers/food_grocery_delivery_session_provider.dart';

class PickupAtBusinessScreen extends ConsumerWidget {
  const PickupAtBusinessScreen({
    super.key,
    required this.serviceType,
    required this.onBack,
    required this.onVerifyPickup,
  });

  final PartnerServiceType serviceType;
  final VoidCallback onBack;
  final VoidCallback onVerifyPickup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final session = ref.watch(
      foodGroceryDeliverySessionProvider(serviceType),
    );

    final pickupState = ref.watch(
      deliveryPickupStatusProvider(serviceType),
    );

    final job = session.activeJob;

    if (job == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundSecondary : AppColors.backgroundLight,
        appBar: _buildAppBar(
          title: 'Pickup',
        ),
        body: _MissingDeliveryView(
          isDark: isDark,
          onBack: onBack,
        ),
      );
    }

    final businessType = job.businessTypeLabel;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundSecondary : AppColors.backgroundLight,
      appBar: _buildAppBar(
        title: 'Pickup at $businessType',
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
            _PickupStatusCard(
              isDark: isDark,
              isFoodDelivery: job.isFoodDelivery,
              statusLabel: pickupState.statusLabel,
              statusDescription: pickupState.statusDescription,
              isReady: pickupState.isReadyForPickup,
            ),
            const SizedBox(height: 14),
            _InformationCard(
              isDark: isDark,
              title: '$businessType DETAILS',
              icon: job.isFoodDelivery
                  ? Icons.restaurant_outlined
                  : Icons.storefront_outlined,
              children: [
                _InformationRow(
                  isDark: isDark,
                  label: businessType,
                  value: job.businessName,
                ),
                const SizedBox(height: 12),
                _InformationRow(
                  isDark: isDark,
                  label: 'Pickup address',
                  value: job.pickupAddress,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InformationCard(
              isDark: isDark,
              title: 'ORDER INFORMATION',
              icon: Icons.receipt_long_outlined,
              children: [
                _InformationRow(
                  isDark: isDark,
                  label: 'Order reference',
                  value: job.orderId,
                  emphasize: true,
                ),
                const SizedBox(height: 12),
                _InformationRow(
                  isDark: isDark,
                  label: 'Delivery type',
                  value: job.deliveryTypeLabel,
                ),
                const SizedBox(height: 12),
                _InformationRow(
                  isDark: isDark,
                  label: 'Packages',
                  value: job.packageLabel,
                ),
              ],
            ),
            if (job.specialHandlingNote != null &&
                job.specialHandlingNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _InformationCard(
                isDark: isDark,
                title: 'HANDLING INSTRUCTIONS',
                icon: Icons.inventory_2_outlined,
                children: [
                  Text(
                    job.specialHandlingNote!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ],
            if (pickupState.errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  pickupState.errorMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
            child: pickupState.isReadyForPickup
                ? ElevatedButton.icon(
                    onPressed: onVerifyPickup,
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 20,
                    ),
                    label: const Text('Verify pickup'),
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
                  )
                : TextButton.icon(
                    onPressed: pickupState.isRefreshing
                        ? null
                        : () {
                            ref
                                .read(
                                  deliveryPickupStatusProvider(
                                    serviceType,
                                  ).notifier,
                                )
                                .refreshStatus();
                          },
                    icon: pickupState.isRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryGold,
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                          ),
                    label: Text(
                      pickupState.isRefreshing
                          ? 'Checking status'
                          : 'Refresh status',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
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
        onPressed: onBack,
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

class _PickupStatusCard extends StatelessWidget {
  const _PickupStatusCard({
    required this.isDark,
    required this.isFoodDelivery,
    required this.statusLabel,
    required this.statusDescription,
    required this.isReady,
  });

  final bool isDark;
  final bool isFoodDelivery;
  final String statusLabel;
  final String statusDescription;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final statusColor = isReady ? AppColors.success : AppColors.primaryGold;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isReady
                  ? Icons.check_circle_rounded
                  : isFoodDelivery
                      ? Icons.restaurant_rounded
                      : Icons.shopping_basket_rounded,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            statusLabel,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            statusDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          if (!isReady) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                minHeight: 4,
                color: AppColors.primaryGold,
                backgroundColor: Color(0x3304213C),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.children,
  });

  final bool isDark;
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.isDark,
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.emphasize = false,
  });

  final bool isDark;
  final String label;
  final String value;
  final int maxLines;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(
              color: emphasize
                  ? AppColors.primaryGold
                  : isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              height: 1.35,
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
            const Icon(
              Icons.inventory_2_outlined,
              size: 58,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No active delivery found',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Return to the delivery details and try again.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onBack,
              child: const Text('Back to delivery'),
            ),
          ],
        ),
      ),
    );
  }
}
