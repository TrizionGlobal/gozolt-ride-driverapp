import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../driver/presentation/providers/location_provider.dart';
import '../providers/ride_session_provider.dart';
import '../providers/destination_proximity_provider.dart';
import '../widgets/address_row.dart';
import '../widgets/contact_actions_row.dart';
import '../widgets/gold_action_button.dart';
import '../widgets/navigation_button.dart';
import '../widgets/rider_info_row.dart';
import '../widgets/ride_eta_badge.dart';

class ActiveRideCard extends ConsumerStatefulWidget {
  const ActiveRideCard({super.key});

  @override
  ConsumerState<ActiveRideCard> createState() => _ActiveRideCardState();
}

class _ActiveRideCardState extends ConsumerState<ActiveRideCard> {
  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideSessionProvider);
    final isNearDestination = ref.watch(isNearDestinationProvider);
    if (ride == null) return const SizedBox.shrink();

    // Listen for destination change requests
    ref.listen<Map<String, dynamic>?>(destinationChangeRequestProvider,
        (previous, next) {
      if (next != null) {
        _showDestinationChangeDialog(context, next);
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Navigation button — points to current stop or final dropoff
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 12),
          child: NavigationButton(
            destinationLat: ride.currentStop?.lat ?? ride.dropoffLat,
            destinationLng: ride.currentStop?.lng ?? ride.dropoffLng,
          ),
        ),
        // Bottom card
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rider info with live ETA
              Row(
                children: [
                  Expanded(
                    child: RiderInfoRow(rider: ride.rider),
                  ),
                  const SizedBox(width: 8),
                  _LiveEtaBadge(
                    targetLat: ride.currentStop?.lat ?? ride.dropoffLat,
                    targetLng: ride.currentStop?.lng ?? ride.dropoffLng,
                    fallbackKm: ride.distanceKm,
                    fallbackMin: ride.estimatedMinutes,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Pickup address
              AddressRow(
                dotColor: const Color(0xFFE53935),
                address: ride.pickupAddress,
              ),
              // Remaining intermediate stops
              ...ride.remainingStops.map((stop) => Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AddressRow(
                      dotColor: const Color(0xFF4CAF50),
                      address: stop.address,
                    ),
                  )),
              const SizedBox(height: 10),
              // Final dropoff
              AddressRow(
                dotColor: const Color(0xFF4CAF50),
                address: ride.dropoffAddress,
              ),
              const SizedBox(height: 16),
              // Contact actions (no cancel during active ride)
              ContactActionsRow(
                phoneNumber: ride.rider.phone,
                rideId: ride.id,
                riderName: ride.rider.fullName,
              ),
              const SizedBox(height: 16),
              // Buttons: End Ride + Next Stop (or just End Ride)
              if (ride.hasStops && !ride.isOnLastStop)
                Row(
                  children: [
                    // End Ride (outlined dark)
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            _showEndRideConfirmation(context, ref),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isNearDestination ? 'Ride Complete' : 'End Ride',
                              style: AppTextStyles.titleMedium.copyWith(
                               color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Next Stop (gold)
                    Expanded(
                      child: GoldActionButton(
                        label: 'Next Stop',
                        onTap: () =>
                            ref.read(rideSessionProvider.notifier).nextStop(),
                      ),
                    ),
                  ],
                )
              else if (isNearDestination)
                GoldActionButton(
                  label: 'Ride Complete',
                  onTap: () =>
                      _showEndRideConfirmation(context, ref),
                )
              else
                GestureDetector(
                  onTap: () =>
                      _showEndRideConfirmation(context, ref),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'End Ride',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEndRideConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'End this ride?',
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Are you sure you want to end the current ride? This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'No',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(rideSessionProvider.notifier).endRide();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.backgroundDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes, End Ride'),
          ),
        ],
      ),
    );
  }

  double _safeDouble(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  void _showDestinationChangeDialog(
      BuildContext context, Map<String, dynamic> data) {
    final newAddress = data['newDropoffAddress'] as String? ?? 'Unknown';
    final newFare = _safeDouble(data['newEstimatedFare'],
        _safeDouble(data['newFare'], 0.0));
    final ride = ref.read(rideSessionProvider);
    final oldFare = _safeDouble(data['oldEstimatedFare'],
        _safeDouble(data['oldFare'], ride?.fare ?? 0.0));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Destination Change',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The rider wants to change the destination:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Color(0xFF4CAF50), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      newAddress,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\u20AC${oldFare.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                Text(
                  '\u20AC${newFare.toStringAsFixed(2)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(rideSessionProvider.notifier)
                  .respondToDestinationChange(false);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
              side: const BorderSide(color: Color(0xFFE53935)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Decline'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(rideSessionProvider.notifier)
                  .respondToDestinationChange(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.backgroundDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}

/// Live ETA badge that recalculates distance/time from driver's GPS position.
class _LiveEtaBadge extends ConsumerWidget {
  final double targetLat;
  final double targetLng;
  final double fallbackKm;
  final int fallbackMin;

  const _LiveEtaBadge({
    required this.targetLat,
    required this.targetLng,
    required this.fallbackKm,
    required this.fallbackMin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posAsync = ref.watch(locationStreamProvider);
    return posAsync.when(
      data: (position) {
        final km = haversineDistanceKm(
          position.latitude, position.longitude,
          targetLat, targetLng,
        );
        final mins = estimateMinutes(km);
        return RideEtaBadge(distanceKm: km, minutes: mins);
      },
      loading: () => RideEtaBadge(distanceKm: fallbackKm, minutes: fallbackMin),
      error: (err, stack) => RideEtaBadge(distanceKm: fallbackKm, minutes: fallbackMin),
    );
  }
}


