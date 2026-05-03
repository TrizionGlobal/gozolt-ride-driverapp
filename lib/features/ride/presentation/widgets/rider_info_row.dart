import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/rider_info.dart';

class RiderInfoRow extends StatelessWidget {
  final RiderInfo rider;
  final String? badgeText;

  const RiderInfoRow({
    super.key,
    required this.rider,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceDark,
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: rider.avatarUrl != null
                ? Image.network(
                    rider.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
        ),
        const SizedBox(width: 12),
        // Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rider.fullName,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.backgroundPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // ETA badge
        if (badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              badgeText!,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.backgroundPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: AppColors.surfaceDark,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}
