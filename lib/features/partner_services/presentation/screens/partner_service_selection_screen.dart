import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/partner_service_type.dart';
import '../providers/partner_service_provider.dart';
import '../providers/partner_availability_provider.dart';

class PartnerServiceSelectionScreen extends ConsumerWidget {
  const PartnerServiceSelectionScreen({
    super.key,
    this.onServiceSelected,
  });

  final ValueChanged<PartnerServiceType>? onServiceSelected;

  void _selectService(
    BuildContext context,
    WidgetRef ref,
    PartnerServiceType service,
  ) {
    final selected =
        ref.read(partnerServiceProvider.notifier).selectService(service);

    if (!selected) {
      final message = ref
              .read(
                partnerServiceProvider,
              )
              .errorMessage ??
          'This service is not available.';

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      return;
    }

    onServiceSelected?.call(service);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final serviceState = ref.watch(
      partnerServiceProvider,
    );

    final availabilityState = ref.watch(
      partnerAvailabilityProvider,
    );

    final backgroundColor =
        isDark ? AppColors.backgroundDarker : AppColors.backgroundLight;

    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                8,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _AllServicesAvailabilityToggle(
                      isOnline: availabilityState.allServicesOnline,
                      isUpdating: availabilityState.isUpdating,
                      onChanged: (value) async {
                        final success = await ref
                            .read(
                              partnerAvailabilityProvider.notifier,
                            )
                            .setAllServicesOnline(
                              value: value,
                              approvedServices: serviceState.approvedServices,
                            );

                        if (!context.mounted || success) {
                          return;
                        }

                        final message = ref
                                .read(
                                  partnerAvailabilityProvider,
                                )
                                .errorMessage ??
                            'Unable to update availability.';

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: AppColors.error,
                            ),
                          );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      size: 40,
                      color: Color(0xFF04213C),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Choose a service',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select how you want to earn today',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  22,
                  16,
                  28,
                ),
                children: [
                  _PartnerServiceCard(
                    service: PartnerServiceType.cabBooking,
                    icon: Icons.local_taxi_rounded,
                    approved: serviceState.isApproved(
                      PartnerServiceType.cabBooking,
                    ),
                    isDark: isDark,
                    onTap: () {
                      _selectService(
                        context,
                        ref,
                        PartnerServiceType.cabBooking,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _PartnerServiceCard(
                    service: PartnerServiceType.foodDelivery,
                    icon: Icons.restaurant_rounded,
                    approved: serviceState.isApproved(
                      PartnerServiceType.foodDelivery,
                    ),
                    isDark: isDark,
                    onTap: () {
                      _selectService(
                        context,
                        ref,
                        PartnerServiceType.foodDelivery,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _PartnerServiceCard(
                    service: PartnerServiceType.groceryDelivery,
                    icon: Icons.shopping_basket_rounded,
                    approved: serviceState.isApproved(
                      PartnerServiceType.groceryDelivery,
                    ),
                    isDark: isDark,
                    onTap: () {
                      _selectService(
                        context,
                        ref,
                        PartnerServiceType.groceryDelivery,
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 17,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Only approved services can be selected',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllServicesAvailabilityToggle extends StatelessWidget {
  const _AllServicesAvailabilityToggle({
    required this.isOnline,
    required this.isUpdating,
    required this.onChanged,
  });

  final bool isOnline;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        7,
        8,
        7,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOnline
              ? AppColors.success.withValues(alpha: 0.55)
              : secondaryTextColor.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.success : secondaryTextColor,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOnline ? 'Online' : 'Offline',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isOnline ? AppColors.success : primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'All services',
                style: AppTextStyles.labelSmall.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 7),
          if (isUpdating)
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGold,
                ),
              ),
            )
          else
            Transform.scale(
              scale: 0.78,
              child: Switch.adaptive(
                value: isOnline,
                onChanged: onChanged,
                activeTrackColor: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }
}

class _PartnerServiceCard extends StatelessWidget {
  const _PartnerServiceCard({
    required this.service,
    required this.icon,
    required this.approved,
    required this.isDark,
    required this.onTap,
  });

  final PartnerServiceType service;
  final IconData icon;
  final bool approved;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final primaryTextColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    final borderColor = approved
        ? AppColors.primaryGold.withValues(
            alpha: 0.65,
          )
        : secondaryTextColor.withValues(
            alpha: 0.25,
          );

    return Opacity(
      opacity: approved ? 1 : 0.58,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: approved ? 1.3 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: approved
                        ? AppColors.primaryGold.withValues(
                            alpha: isDark ? 0.18 : 0.15,
                          )
                        : secondaryTextColor.withValues(
                            alpha: 0.10,
                          ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color:
                        approved ? AppColors.primaryGold : secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.displayName,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        service.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryTextColor,
                          height: 1.35,
                        ),
                      ),
                      if (!approved) ...[
                        const SizedBox(height: 7),
                        Text(
                          'Not approved yet',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  approved
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.lock_outline_rounded,
                  size: approved ? 18 : 20,
                  color: approved ? AppColors.primaryGold : secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
