import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/ride_detail.dart';
import '../providers/ride_detail_provider.dart';
import 'ride_timeline_screen.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  final String rideId;

  const TripDetailsScreen({super.key, required this.rideId});

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(rideDetailProvider.notifier).fetchRideDetail(widget.rideId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(rideDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: detail == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              )
            : Column(
                children: [
                  // ── Gold header ───────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundPrimary
                                      .withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.backgroundPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Trip Details',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.backgroundPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\u20AC ${((detail.totalFare ?? 0) + (detail.tipAmount ?? 0)).toStringAsFixed(2)}',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.backgroundPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Scrollable content ────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        children: [
                          // Duration + Distance row
                          _DurationDistanceRow(
                            detail: detail,
                            onTimelineTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RideTimelineScreen(detail: detail),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Addresses
                          _AddressesCard(detail: detail),
                          const SizedBox(height: 16),

                          // Payment Details
                          _PaymentDetailsCard(detail: detail),
                          const SizedBox(height: 16),

                          // Your Earning
                          _EarningCard(detail: detail),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // ── Sub Total bar ─────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sub Total',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.backgroundPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '\u20AC ${((detail.totalFare ?? 0) + (detail.tipAmount ?? 0)).toStringAsFixed(2)}',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.backgroundPrimary,
                            fontWeight: FontWeight.w800,
                          ),
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

// ── Duration + Distance row ──────────────────────────────────────────────────

class _DurationDistanceRow extends StatelessWidget {
  final RideDetail detail;
  final VoidCallback onTimelineTap;

  const _DurationDistanceRow({
    required this.detail,
    required this.onTimelineTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTimelineTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.timer_rounded, color: AppColors.primaryGold, size: 22),
            const SizedBox(width: 8),
            Text(
              '${detail.durationMinutes ?? 0} min',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.backgroundPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 20),
            const Icon(Icons.straighten_rounded, color: AppColors.primaryGold, size: 22),
            const SizedBox(width: 8),
            Text(
              '${(detail.distanceKm ?? 0).toStringAsFixed(1)} km',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.backgroundPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Addresses card ───────────────────────────────────────────────────────────

class _AddressesCard extends StatelessWidget {
  final RideDetail detail;
  const _AddressesCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final dateStr = detail.startedAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(detail.startedAt!)
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail.pickupAddress,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 2,
              height: 20,
              color: Colors.grey.shade300,
            ),
          ),
          // Dropoff
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail.dropoffAddress,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              dateStr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Payment Details card ─────────────────────────────────────────────────────

class _PaymentDetailsCard extends StatelessWidget {
  final RideDetail detail;
  const _PaymentDetailsCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final isCash = detail.paymentMethod.toLowerCase() == 'cash';
    final isPaid = detail.paymentStatus.toUpperCase() == 'PAID';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.backgroundPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Via',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isCash ? Icons.money : Icons.credit_card_rounded,
                    color: isCash ? AppColors.success : AppColors.info,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCash ? 'Cash' : 'Card',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.backgroundPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPaid ? AppColors.success : AppColors.warning)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid ? 'Paid' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? AppColors.success : AppColors.warning,
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

// ── Your Earning card ────────────────────────────────────────────────────────

class _EarningCard extends StatelessWidget {
  final RideDetail detail;
  const _EarningCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Earning',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.backgroundPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _FareRow('Base Price', detail.baseFare),
          const SizedBox(height: 8),
          _FareRow('Distance Price', detail.distanceFare),
          const SizedBox(height: 8),
          _FareRow('Time Price', detail.timeFare),
          if (detail.waitTimeFee != null && detail.waitTimeFee! > 0) ...[
            const SizedBox(height: 8),
            _FareRow('Wait Time Fee', detail.waitTimeFee),
          ],
          if (detail.tipAmount != null && detail.tipAmount! > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volunteer_activism_rounded,
                        color: Color(0xFF4CAF50), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Tip',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\u20AC ${detail.tipAmount!.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.backgroundPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\u20AC ${((detail.totalFare ?? 0) + (detail.tipAmount ?? 0)).toStringAsFixed(2)}',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final double? value;
  const _FareRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        Text(
          '\u20AC ${(value ?? 0).toStringAsFixed(2)}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.backgroundPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
