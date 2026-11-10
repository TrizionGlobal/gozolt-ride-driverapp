import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/delivery_job.dart';
import '../providers/food_grocery_delivery_session_provider.dart';

class DeliveryJobDetailsScreen extends ConsumerWidget {
  const DeliveryJobDetailsScreen({
    super.key,
    required this.serviceType,
    required this.onBackToHome,
    required this.onNavigateToPickup,
  });

  final PartnerServiceType serviceType;
  final VoidCallback onBackToHome;
  final VoidCallback onNavigateToPickup;

  Future<void> _callPhone(
    BuildContext context,
    String phone,
  ) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      final launched = await launchUrl(uri);

      if (!launched && context.mounted) {
        _showContactError(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showContactError(context);
      }
    }
  }

  void _showContactError(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open the phone application.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final session = ref.watch(
      foodGroceryDeliverySessionProvider(serviceType),
    );

    final job = session.activeJob;

    if (job == null) {
      return _MissingDeliveryView(
        isDark: isDark,
        onReturn: onBackToHome,
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarker : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDarker : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          onPressed: onBackToHome,
          tooltip: 'Back to delivery home',
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Delivery details',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
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
            _OrderOverviewCard(
              isDark: isDark,
              job: job,
            ),
            const SizedBox(height: 14),
            _PickupDetailsCard(
              isDark: isDark,
              job: job,
              onCall: job.businessPhone == null
                  ? null
                  : () => _callPhone(
                        context,
                        job.businessPhone!,
                      ),
            ),
            const SizedBox(height: 14),
            _CustomerDetailsCard(
              isDark: isDark,
              job: job,
              onCall: job.customerPhone == null
                  ? null
                  : () => _callPhone(
                        context,
                        job.customerPhone!,
                      ),
            ),
            const SizedBox(height: 14),
            _PackagePaymentCard(
              isDark: isDark,
              job: job,
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
                    ? AppColors.textMuted.withValues(
                        alpha: 0.25,
                      )
                    : AppColors.textMutedLight.withValues(
                        alpha: 0.25,
                      ),
              ),
            ),
          ),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onNavigateToPickup,
              icon: const Icon(
                Icons.navigation_rounded,
                size: 20,
              ),
              label: Text(job.pickupActionLabel),
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
    );
  }
}

class _OrderOverviewCard extends StatelessWidget {
  const _OrderOverviewCard({
    required this.isDark,
    required this.job,
  });

  final bool isDark;
  final DeliveryJob job;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      isDark: isDark,
      title: 'Order',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(
                    alpha: isDark ? 0.18 : 0.14,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  job.isFoodDelivery
                      ? Icons.restaurant_rounded
                      : Icons.shopping_basket_rounded,
                  color: AppColors.primaryGold,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.deliveryTypeLabel,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.stage.displayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _DetailRow(
            isDark: isDark,
            label: 'Order reference',
            value: job.orderId,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            isDark: isDark,
            label: 'Your estimated earning',
            value: '€${job.estimatedEarning.toStringAsFixed(2)}',
            valueColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _PickupDetailsCard extends StatelessWidget {
  const _PickupDetailsCard({
    required this.isDark,
    required this.job,
    required this.onCall,
  });

  final bool isDark;
  final DeliveryJob job;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      isDark: isDark,
      title: 'Pickup',
      icon: Icons.storefront_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            isDark: isDark,
            label: job.businessTypeLabel,
            value: job.businessName,
          ),
          const SizedBox(height: 11),
          _AddressBlock(
            isDark: isDark,
            icon: Icons.location_on_outlined,
            label: 'Pickup address',
            value: job.pickupAddress,
          ),
          if (onCall != null) ...[
            const SizedBox(height: 14),
            _ContactButton(
              label: 'Call ${job.businessTypeLabel.toLowerCase()}',
              icon: Icons.call_outlined,
              isDark: isDark,
              onPressed: onCall!,
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomerDetailsCard extends StatelessWidget {
  const _CustomerDetailsCard({
    required this.isDark,
    required this.job,
    required this.onCall,
  });

  final bool isDark;
  final DeliveryJob job;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      isDark: isDark,
      title: 'Customer',
      icon: Icons.person_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            isDark: isDark,
            label: 'Customer',
            value: job.customerName,
          ),
          const SizedBox(height: 11),
          _AddressBlock(
            isDark: isDark,
            icon: Icons.home_outlined,
            label: 'Delivery address',
            value: job.deliveryAddress,
          ),
          if (job.deliveryInstructions != null &&
              job.deliveryInstructions!.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            _InstructionBox(
              isDark: isDark,
              title: 'Delivery instructions',
              message: job.deliveryInstructions!,
            ),
          ],
          if (onCall != null) ...[
            const SizedBox(height: 14),
            _ContactButton(
              label: 'Call customer',
              icon: Icons.call_outlined,
              isDark: isDark,
              onPressed: onCall!,
            ),
          ],
        ],
      ),
    );
  }
}

class _PackagePaymentCard extends StatelessWidget {
  const _PackagePaymentCard({
    required this.isDark,
    required this.job,
  });

  final bool isDark;
  final DeliveryJob job;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      isDark: isDark,
      title: 'Package and payment',
      icon: Icons.inventory_2_outlined,
      child: Column(
        children: [
          _DetailRow(
            isDark: isDark,
            label: 'Packages',
            value: job.packageLabel,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            isDark: isDark,
            label: 'Payment method',
            value: job.paymentMethod.displayName,
            valueColor: job.paymentMethod.requiresCashCollection
                ? AppColors.warning
                : AppColors.info,
          ),
          if (job.paymentMethod.requiresCashCollection) ...[
            const SizedBox(height: 10),
            _DetailRow(
              isDark: isDark,
              label: 'Cash to collect',
              value: '€${job.cashAmountToCollect!.toStringAsFixed(2)}',
              valueColor: AppColors.warning,
            ),
          ],
          if (job.specialHandlingNote != null &&
              job.specialHandlingNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            _InstructionBox(
              isDark: isDark,
              title: 'Handling note',
              message: job.specialHandlingNote!,
            ),
          ],
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(17),
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
                style: AppTextStyles.labelLarge.copyWith(
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
  });

  final bool isDark;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryGold,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionBox extends StatelessWidget {
  const _InstructionBox({
    required this.isDark,
    required this.title,
    required this.message,
  });

  final bool isDark;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(
          alpha: isDark ? 0.10 : 0.08,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 19,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          side: const BorderSide(
            color: AppColors.primaryGold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MissingDeliveryView extends StatelessWidget {
  const _MissingDeliveryView({
    required this.isDark,
    required this.onReturn,
  });

  final bool isDark;
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
                  color: AppColors.warning.withValues(
                    alpha: 0.13,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 39,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No active delivery',
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
                'The active delivery details are not available.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
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
