import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RideInfoBoxes extends StatelessWidget {
  final double price;
  final double rating;
  final double distanceKm;

  const RideInfoBoxes({
    super.key,
    required this.price,
    required this.rating,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _InfoBox(
          value: '€${price.toStringAsFixed(2)}',
          label: 'Price',
          valueColor: AppColors.primaryGold,
        ),
        const SizedBox(width: 12),
        _InfoBox(
          value: rating.toStringAsFixed(1),
          label: 'Rating',
          valueColor: AppColors.backgroundPrimary,
        ),
        const SizedBox(width: 12),
        _InfoBox(
          value: '${distanceKm.toStringAsFixed(1)} km',
          label: 'Distance',
          valueColor: AppColors.backgroundPrimary,
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _InfoBox({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textMuted.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

