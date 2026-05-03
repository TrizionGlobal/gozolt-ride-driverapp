import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../driver/presentation/providers/location_provider.dart';
import '../providers/destination_proximity_provider.dart';
import '../providers/ride_session_provider.dart';

class RideMetricsBubbles extends ConsumerWidget {
  const RideMetricsBubbles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = ref.watch(rideSessionProvider);
    if (ride == null) return const SizedBox.shrink();

    final positionAsync = ref.watch(locationStreamProvider);
    final speedKmh = positionAsync.when(
      data: (p) => (p.speed * 3.6).clamp(0.0, 999.0),
      loading: () => 0.0,
      error: (_, _) => 0.0,
    );

    // Use real-time remaining distance from destination proximity provider
    final remainingMeters = ref.watch(destinationDistanceProvider);
    final remainingKm = remainingMeters != null ? remainingMeters / 1000 : ride.distanceKm;

    // Calculate remaining time: use current speed if > 5 km/h, else assume 30 km/h
    final effectiveSpeed = speedKmh > 5 ? speedKmh : 30.0;
    final remainingMin = (remainingKm / effectiveSpeed * 60).round().clamp(0, 999);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _MetricBubble(
          value: remainingKm.toStringAsFixed(1),
          unit: 'km',
          icon: Icons.straighten_rounded,
        ),
        const SizedBox(width: 12),
        _MetricBubble(
          value: '$remainingMin',
          unit: 'min',
          icon: Icons.timer_rounded,
        ),
        const SizedBox(width: 12),
        _MetricBubble(
          value: speedKmh.toStringAsFixed(0),
          unit: 'km/h',
          icon: Icons.speed_rounded,
        ),
      ],
    );
  }
}

class _MetricBubble extends StatelessWidget {
  final String value;
  final String unit;
  final IconData icon;

  const _MetricBubble({
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 14),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          Text(
            unit,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
