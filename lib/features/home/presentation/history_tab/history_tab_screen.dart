import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../ride/data/models/ride_history_item.dart';
import '../../../ride/presentation/providers/ride_history_provider.dart';
import '../../../ride/presentation/screens/trip_details_screen.dart';

class HistoryTabScreen extends ConsumerStatefulWidget {
  const HistoryTabScreen({super.key});

  @override
  ConsumerState<HistoryTabScreen> createState() => _HistoryTabScreenState();
}

class _HistoryTabScreenState extends ConsumerState<HistoryTabScreen> {
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(rideHistoryProvider.notifier).fetchRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rides = ref.watch(rideHistoryProvider);

    // Apply filter
    final filteredRides = _activeFilter == 'all'
        ? rides
        : rides.where((r) => r.status == _activeFilter).toList();

    // Calculate total earnings from filtered completed rides
    double totalEarnings = 0;
    for (final ride in filteredRides) {
      if (ride.fare != null && ride.status == 'COMPLETED') {
        totalEarnings += ride.fare!;
        totalEarnings += ride.tipAmount ?? 0;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'My Rides',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.backgroundPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Earnings pill ────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '\u20AC ${totalEarnings.toStringAsFixed(2)}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.backgroundPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Filter chips ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isActive: _activeFilter == 'all',
                    onTap: () => setState(() => _activeFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Completed',
                    isActive: _activeFilter == 'COMPLETED',
                    onTap: () => setState(() => _activeFilter = 'COMPLETED'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Cancelled',
                    isActive: _activeFilter == 'CANCELLED',
                    onTap: () => setState(() => _activeFilter = 'CANCELLED'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Ride list ────────────────────────────────────────
            Expanded(
              child: filteredRides.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _activeFilter == 'all'
                                ? 'No rides yet'
                                : 'No ${_activeFilter.toLowerCase()} rides',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredRides.length,
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _RideCard(
                          ride: filteredRides[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TripDetailsScreen(
                                    rideId: filteredRides[index].id),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive
                ? AppColors.backgroundPrimary
                : AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Ride card ──────────────────────────────────────────────────────────────────

class _RideCard extends StatelessWidget {
  final RideHistoryItem ride;
  final VoidCallback onTap;

  const _RideCard({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeStr = ride.completedAt != null
        ? DateFormat('hh:mm a').format(ride.completedAt!)
        : DateFormat('hh:mm a').format(ride.createdAt);
    final dateStr = ride.completedAt != null
        ? DateFormat('dd MMM yyyy').format(ride.completedAt!)
        : DateFormat('dd MMM yyyy').format(ride.createdAt);

    final isCash = ride.paymentMethod.toLowerCase() == 'cash';
    final methodLabel = isCash ? 'Cash' : 'Card';
    final methodColor =
        isCash ? const Color(0xFF4CAF50) : const Color(0xFF2196F3);
    final methodIcon = isCash ? Icons.money : Icons.credit_card;

    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left: payment method badge + time ───────────
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: methodColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(methodIcon, color: methodColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          methodLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: methodColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeStr,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // ── Center: addresses ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride.pickupAddress,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.backgroundPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Container(
                        width: 2,
                        height: 12,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride.dropoffAddress,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.backgroundPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateStr,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ── Right: fare + tip + chevron ──────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (ride.status == 'CANCELLED')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Cancelled',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    )
                  else if (ride.fare != null)
                    Text(
                      '\u20AC ${ride.fare!.toStringAsFixed(2)}',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.backgroundPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (ride.tipAmount != null && ride.tipAmount! > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+\u20AC${ride.tipAmount!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


