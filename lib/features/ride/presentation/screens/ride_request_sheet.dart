import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/ride_session_provider.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/ride_info_boxes.dart';
import '../widgets/rider_info_row.dart';

class RideRequestSheet extends ConsumerWidget {
  const RideRequestSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = ref.watch(rideSessionProvider);
    if (ride == null) return const SizedBox.shrink();

    final topPadding = MediaQuery.of(context).padding.top + 16;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rider info + countdown
          Row(
            children: [
              Expanded(
                child: RiderInfoRow(
                  rider: ride.rider,
                  badgeText: '${ride.estimatedMinutes} Mins',
                ),
              ),
              const SizedBox(width: 12),
              const CountdownTimer(),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Addresses with connecting line
          _AddressListWithLine(
            pickupAddress: ride.pickupAddress,
            dropoffAddress: ride.dropoffAddress,
            stops: ride.stops.map((s) => s.address).toList(),
          ),
          const SizedBox(height: 16),
          // Other Details
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Other Details',
              style: AppTextStyles.titleSmall.copyWith(
                color: Theme.of(context).textTheme.titleSmall?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Info boxes
          RideInfoBoxes(
            price: ride.fare,
            rating: ride.rider.rating,
            distanceKm: ride.distanceKm,
          ),
          const SizedBox(height: 20),
          // Accept + Skip buttons
          Row(
            children: [
              // Skip (left)
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(rideSessionProvider.notifier).skipRide(),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFE53935),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Skip',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: const Color(0xFFE53935),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Accept (right)
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    final accepted = await ref.read(rideSessionProvider.notifier).acceptRide();
                    if (!accepted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This ride request is no longer available'),
                          backgroundColor: Color(0xFFE53935),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Text(
                        'Accept',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.backgroundPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressListWithLine extends StatelessWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final List<String> stops;

  const _AddressListWithLine({
    required this.pickupAddress,
    required this.dropoffAddress,
    this.stops = const [],
  });

  @override
  Widget build(BuildContext context) {
    final allAddresses = [
      pickupAddress,
      ...stops,
      dropoffAddress,
    ];
    final dotColors = [
      const Color(0xFFE53935), // pickup - red
      ...stops.map((_) => AppColors.primaryGold), // stops - gold
      const Color(0xFF4CAF50), // dropoff - green
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dots + connecting line column
          SizedBox(
            width: 10,
            child: Column(
              children: [
                for (int i = 0; i < allAddresses.length; i++) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColors[i],
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i < allAddresses.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: const Color(0xFFBDBDBD),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Address texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < allAddresses.length; i++) ...[
                  Text(
                    allAddresses[i],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (i < allAddresses.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
