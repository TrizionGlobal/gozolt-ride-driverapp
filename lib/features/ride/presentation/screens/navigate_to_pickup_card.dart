import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../driver/presentation/providers/location_provider.dart';
import '../../data/models/ride_status.dart';
import '../providers/ride_session_provider.dart';
import '../widgets/address_row.dart';
import '../widgets/contact_actions_row.dart';
import '../widgets/gold_action_button.dart';
import '../widgets/navigation_button.dart';
import '../widgets/rider_info_row.dart';
import '../widgets/ride_eta_badge.dart';
import 'cancellation_dialog.dart';
import 'otp_verification_dialog.dart';

class NavigateToPickupCard extends ConsumerStatefulWidget {
  const NavigateToPickupCard({super.key});

  @override
  ConsumerState<NavigateToPickupCard> createState() =>
      _NavigateToPickupCardState();
}

class _NavigateToPickupCardState extends ConsumerState<NavigateToPickupCard> {
  Timer? _waitTimer;
  int _waitSeconds = 300; // 5 minutes (must match backend requirement)
  bool _canNoShow = false;

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  void _startWaitTimer() {
    if (_waitTimer != null) return;
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _waitSeconds--;
        if (_waitSeconds <= 0) {
          _canNoShow = true;
          timer.cancel();
        }
      });
    });
  }

  String get _timerText {
    final min = _waitSeconds ~/ 60;
    final sec = _waitSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideSessionProvider);
    if (ride == null) return const SizedBox.shrink();

    // Start timer when driver has arrived
    if (ride.status == RideStatus.driverArrived && _waitTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startWaitTimer();
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Navigation button
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 12),
          child: NavigationButton(
            destinationLat: ride.pickupLat,
            destinationLng: ride.pickupLng,
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
              // Rider info with live ETA badge
              Row(
                children: [
                  Expanded(
                    child: RiderInfoRow(rider: ride.rider),
                  ),
                  const SizedBox(width: 8),
                  _LiveEtaBadge(
                    targetLat: ride.pickupLat,
                    targetLng: ride.pickupLng,
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
              // Intermediate stops preview
              ...ride.stops.map((stop) => Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AddressRow(
                      dotColor: AppColors.primaryGold,
                      address: stop.address,
                    ),
                  )),
              // Dropoff address (shown for multi-stop rides)
              if (ride.hasStops) ...[
                const SizedBox(height: 10),
                AddressRow(
                  dotColor: const Color(0xFF4CAF50),
                  address: ride.dropoffAddress,
                ),
              ],
              const SizedBox(height: 16),
              // Contact actions
              ContactActionsRow(
                phoneNumber: ride.rider.phone,
                rideId: ride.id,
                riderName: ride.rider.fullName,
                onCancelTap: () => _showCancellationDialog(context, ref),
              ),
              const SizedBox(height: 16),
              // Action button based on status
              if (ride.status == RideStatus.driverEnRoute)
                GoldActionButton(
                  label: 'Mark as Arrived',
                  onTap: () => ref
                      .read(rideSessionProvider.notifier)
                      .markAsArriving(),
                )
              else if (ride.status == RideStatus.driverArrived)
                Column(
                  children: [
                    // Waiting timer
                    if (!_canNoShow) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 18,
                              color: AppColors.primaryGold,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Waiting time: $_timerText',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _canNoShow
                                ? () => _showNoShowDialog(context, ref)
                                : null,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: _canNoShow
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFFE53935)
                                          .withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _canNoShow ? 'No Show' : 'Wait...',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: _canNoShow
                                        ? const Color(0xFFE53935)
                                        : const Color(0xFFE53935)
                                            .withOpacity(0.3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GoldActionButton(
                            label: 'Verify OTP',
                            onTap: () => _showOtpDialog(context, ref),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCancellationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => CancellationDialog(
        onSubmit: (reason) async {
          await ref.read(rideSessionProvider.notifier).cancelRide(reason);
        },
      ),
    );
  }

  void _showNoShowDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Report No Show?',
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'The rider did not show up at the pickup location. A cancellation fee may apply to the rider.',
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
              'Wait',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(rideSessionProvider.notifier).reportNoShow();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showOtpDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpVerificationDialog(
        onVerify: (otp) async {
          return ref.read(rideSessionProvider.notifier).startRide(otp);
        },
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


