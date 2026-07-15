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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Apply filter
    final filteredRides = _activeFilter == 'all'
        ? rides
        : rides.where((r) {
            final status = r.status.toUpperCase();
            final cancelledBy = r.cancelledBy?.toUpperCase();
            print('RIDE ID: ${r.id}, STATUS: ${r.status}, CANCELLED BY: ${r.cancelledBy}');
            if (_activeFilter == 'USER_CANCELLED') {
              return status == 'CANCELLED' && cancelledBy == 'USER';
            }
            if (_activeFilter == 'DRIVER_CANCELLED') {
              return status == 'CANCELLED' && cancelledBy == 'DRIVER';
            }
            return status == _activeFilter;
          }).toList();

    // Calculate total earnings from all completed rides (fixed)
    double totalEarnings = 0;
    double totalTips = 0;
    for (final ride in rides) {
      if (ride.status.toUpperCase() == 'COMPLETED') {
        if (ride.fare != null) totalEarnings += ride.fare!;
        totalEarnings += ride.tipAmount ?? 0;
        totalTips += ride.tipAmount ?? 0;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Title bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'My Rides',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: isDark ? Colors.white : AppColors.backgroundPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ── Premium Earnings & Stats Dashboard ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Tips',
                          value: '€ ${totalTips.toStringAsFixed(2)}',
                          icon: Icons.volunteer_activism_rounded,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Completed',
                          value: '${rides.where((r) => r.status.toUpperCase() == 'COMPLETED').length}',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'User Cancelled',
                          value: '${rides.where((r) => r.status.toUpperCase() == 'CANCELLED' && r.cancelledBy?.toUpperCase() == 'USER').length}',
                          icon: Icons.person_off_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Driver Cancelled',
                          value: '${rides.where((r) => r.status.toUpperCase() == 'CANCELLED' && r.cancelledBy?.toUpperCase() == 'DRIVER').length}',
                          icon: Icons.directions_car_rounded,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Filter chips ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isActive: _activeFilter == 'all',
                      onTap: () => setState(() => _activeFilter = 'all'),
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: 'Completed',
                      isActive: _activeFilter == 'COMPLETED',
                      onTap: () => setState(() => _activeFilter = 'COMPLETED'),
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: 'User Cancelled',
                      isActive: _activeFilter == 'USER_CANCELLED',
                      onTap: () => setState(() => _activeFilter = 'USER_CANCELLED'),
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: 'Driver Cancelled',
                      isActive: _activeFilter == 'DRIVER_CANCELLED',
                      onTap: () => setState(() => _activeFilter = 'DRIVER_CANCELLED'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Ride list ────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryGold,
                onRefresh: () async {
                  await ref.read(rideHistoryProvider.notifier).fetchRides();
                },
                child: filteredRides.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                size: 64,
                                color: isDark ? Colors.white10 : Colors.grey.shade200,
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
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      itemCount: filteredRides.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RideCard(
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
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryGold
              : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
          border: isActive
              ? null
              : Border.all(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.transparent,
                  width: 1,
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive
                ? AppColors.backgroundPrimary
                : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Row: Time, Date & Payment Method ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$dateStr • $timeStr',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                            const SizedBox(width: 4),
                            Text(
                              methodLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: methodColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Middle Section: Route Timeline ──────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visual timeline nodes
                      Column(
                        children: [
                          const SizedBox(height: 3),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.error, width: 2.5),
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 20,
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Addresses Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.pickupAddress,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ride.dropoffAddress,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Divider
                  Container(
                    height: 1,
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  ),
                  const SizedBox(height: 10),

                  // ── Bottom Row: Details Button & Fare ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'View details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_right_rounded,
                            size: 16,
                            color: AppColors.primaryGold,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (ride.tipAmount != null && ride.tipAmount! > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+€${ride.tipAmount!.toStringAsFixed(2)} Tip',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (ride.status.toUpperCase() == 'CANCELLED')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ride.cancelledBy?.toUpperCase() == 'USER'
                                    ? 'User Cancelled'
                                    : ride.cancelledBy?.toUpperCase() == 'DRIVER'
                                        ? 'Driver Cancelled'
                                        : 'Cancelled',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            )
                          else if (ride.fare != null)
                            Text(
                              '€ ${ride.fare!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



