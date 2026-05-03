import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RideEtaBadge extends StatelessWidget {
  final double distanceKm;
  final int minutes;

  const RideEtaBadge({
    super.key,
    required this.distanceKm,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryGold,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${distanceKm.toStringAsFixed(0)} km / $minutes Mins',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.backgroundPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
