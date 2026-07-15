import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ride_detail.dart';

class RideTimelineScreen extends StatelessWidget {
  final RideDetail detail;

  const RideTimelineScreen({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final events = _buildEvents();
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // ── Gold Header (Matching Trip Details header style) ─────────────
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
              child: Row(
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
                    'Trip Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.backgroundPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Timeline List ──────────────────────────────────
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isLast = index == events.length - 1;
                  return _TimelineItem(
                    event: event,
                    isLast: isLast,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_TimelineEvent> _buildEvents() {
    final events = <_TimelineEvent>[];

    if (detail.requestedAt != null) {
      events.add(_TimelineEvent(
        title: 'New Ride Requested',
        description: 'A new ride request was received from passenger',
        dateTime: detail.requestedAt!,
        icon: Icons.add_circle_outline_rounded,
        color: AppColors.info,
      ));
    }

    if (detail.acceptedAt != null) {
      events.add(_TimelineEvent(
        title: 'Ride Accepted',
        description: 'You accepted the ride request',
        dateTime: detail.acceptedAt!,
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success,
      ));
    }

    if (detail.arrivedAt != null) {
      events.add(_TimelineEvent(
        title: 'Arrived at Pickup',
        description: 'You arrived at the pickup location',
        dateTime: detail.arrivedAt!,
        icon: Icons.location_on_outlined,
        color: AppColors.primaryGold,
      ));
    }

    if (detail.startedAt != null) {
      events.add(_TimelineEvent(
        title: 'Ride Started',
        description: 'The passenger boarded and the ride started',
        dateTime: detail.startedAt!,
        icon: Icons.play_circle_outline_rounded,
        color: AppColors.info,
      ));
    }

    // Add stop events
    for (int i = 0; i < detail.stops.length; i++) {
      final stop = detail.stops[i];
      events.add(_TimelineEvent(
        title: 'Reached Stop ${i + 1}',
        description: stop.address,
        dateTime: detail.startedAt ?? DateTime.now(),
        icon: Icons.outlined_flag_rounded,
        color: AppColors.warning,
      ));
    }

    if (detail.status == 'CANCELLED') {
      events.add(_TimelineEvent(
        title: 'Ride Cancelled',
        description: detail.cancelledBy == 'USER' 
            ? 'The passenger cancelled the ride' 
            : detail.cancelledBy == 'DRIVER'
                ? 'You cancelled the ride'
                : 'The ride was cancelled',
        dateTime: detail.completedAt ?? DateTime.now(),
        icon: Icons.cancel_outlined,
        color: AppColors.error,
      ));
    } else {
      if (detail.completedAt != null) {
        events.add(_TimelineEvent(
          title: 'Ride Completed',
          description: 'The ride was completed successfully at destination',
          dateTime: detail.completedAt!,
          icon: Icons.done_all_rounded,
          color: AppColors.success,
        ));
      }

      // Payment status (Only for completed or non-cancelled rides)
      final String pStatus = detail.paymentStatus.toUpperCase();
      final isCash = detail.paymentMethod.toLowerCase() == 'cash';
      final isPaid = pStatus == 'PAID' || pStatus == 'COMPLETED' || pStatus == 'SUCCESS' || pStatus == 'AUTHORIZED' || (detail.status.toUpperCase() == 'COMPLETED' && isCash);
      events.add(_TimelineEvent(
        title: isPaid ? 'Payment Received' : 'Payment Pending',
        description: isPaid
            ? 'Payment of €${(detail.totalFare ?? 0).toStringAsFixed(2)} received via ${detail.paymentMethod}'
            : 'Awaiting payment confirmation from passenger',
        dateTime: detail.completedAt ?? DateTime.now(),
        icon: isPaid ? Icons.account_balance_wallet_outlined : Icons.pending_actions_rounded,
        color: isPaid ? AppColors.success : AppColors.warning,
      ));
    }

    return events;
  }
}

class _TimelineEvent {
  final String title;
  final String description;
  final DateTime dateTime;
  final IconData icon;
  final Color color;

  const _TimelineEvent({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.icon,
    required this.color,
  });
}

class _TimelineItem extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast;

  const _TimelineItem({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('dd MMM yyyy').format(event.dateTime);
    final timeStr = DateFormat('hh:mm a').format(event.dateTime);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline Node & Line ─────────────────────────
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // Glowing circular ring around the icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: event.color.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(event.icon, color: event.color, size: 18),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // ── Event Content Card ───────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$dateStr  •  $timeStr',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
