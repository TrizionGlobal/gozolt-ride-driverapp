import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: detail == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              )
            : Column(
                children: [
                  // ── Gold Header (Covers status bar cleanly) ─────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16, 12 + statusBarHeight, 16, 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFD4A843), Color(0xFFF5C518)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
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
                                  color: AppColors.backgroundPrimary.withOpacity(0.15),
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
                            const Text(
                              'Trip Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.backgroundPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '€ ${((detail.totalFare ?? 0) + (detail.tipAmount ?? 0)).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: AppColors.backgroundPrimary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Ride ID: ${detail.id.length > 8 ? detail.id.substring(0, 8) : detail.id}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.backgroundPrimary.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Scrollable Content ────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Duration + Distance + Timeline Card
                          _DurationDistanceRow(
                            detail: detail,
                            onTimelineTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RideTimelineScreen(detail: detail),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Route/Addresses Timeline
                          _AddressesCard(detail: detail),
                          const SizedBox(height: 16),

                          // Payment Details
                          _PaymentDetailsCard(detail: detail),
                          const SizedBox(height: 16),

                          // Invoice Earning Card
                          _EarningCard(detail: detail),
                        ],
                      ),
                    ),
                  ),

                  // ── Sub Total Bar ─────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      16 + MediaQuery.of(context).padding.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, -4),
                              ),
                            ],
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sub Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          '€ ${((detail.totalFare ?? 0) + (detail.tipAmount ?? 0)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTimelineTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.timer_rounded, color: AppColors.primaryGold, size: 20),
            const SizedBox(width: 8),
            Text(
              '${detail.durationMinutes ?? 0} min',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: 20),
            const Icon(Icons.straighten_rounded, color: AppColors.primaryGold, size: 20),
            const SizedBox(width: 8),
            Text(
              '${(detail.distanceKm ?? 0).toStringAsFixed(1)} km',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'Timeline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: AppColors.primaryGold,
                  size: 16,
                ),
              ],
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = detail.startedAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(detail.startedAt!)
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error, width: 2.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Address',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white38 : Colors.black38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.pickupAddress,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 1.5,
              height: 20,
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          // Dropoff
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination Address',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white38 : Colors.black38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.dropoffAddress,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                ),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                  ),
                ),
              ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCash = detail.paymentMethod.toLowerCase() == 'cash';
    final isPaid = detail.paymentStatus.toUpperCase() == 'PAID';
    final methodColor = isCash ? const Color(0xFF4CAF50) : const Color(0xFF2196F3);
    final methodIcon = isCash ? Icons.money : Icons.credit_card;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Method',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: methodColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(methodIcon, color: methodColor, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      isCash ? 'Cash' : 'Card',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: methodColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPaid ? AppColors.success : AppColors.warning).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                      color: isPaid ? AppColors.success : AppColors.warning,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPaid ? 'Paid' : 'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPaid ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Earning',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          _FareRow('Base Price', detail.baseFare),
          const SizedBox(height: 10),
          _FareRow('Distance Price', detail.distanceFare),
          if (detail.waitTimeFee != null && detail.waitTimeFee! > 0) ...[
            const SizedBox(height: 10),
            _FareRow('Wait Time Fee', detail.waitTimeFee),
          ],
          if (detail.tipAmount != null && detail.tipAmount! > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volunteer_activism_rounded,
                        color: Color(0xFF4CAF50), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Tip',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Text(
                  '€ ${detail.tipAmount!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                '€ ${((detail.totalFare ?? 0) + (detail.tipAmount ?? 0)).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w900,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          '€ ${(value ?? 0).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
