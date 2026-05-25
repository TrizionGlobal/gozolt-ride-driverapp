import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/ride_detail.dart';

class RideTimelineScreen extends StatelessWidget {
  final RideDetail detail;

  const RideTimelineScreen({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final events = _buildEvents();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
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
                        color: AppColors.backgroundDark.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                       color: AppColors.backgroundDark,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Details',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.backgroundDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // ── Timeline list ──────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
        description: 'A new ride request was received',
        dateTime: detail.requestedAt!,
        icon: Icons.add_circle_rounded,
        color: AppColors.info,
      ));
    }

    if (detail.acceptedAt != null) {
      events.add(_TimelineEvent(
        title: 'Accepted',
        description: 'You accepted the ride request',
        dateTime: detail.acceptedAt!,
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
      ));
    }

    if (detail.arrivedAt != null) {
      events.add(_TimelineEvent(
        title: 'Arrived at Pickup',
        description: 'You arrived at the pickup location',
        dateTime: detail.arrivedAt!,
        icon: Icons.location_on_rounded,
        color: AppColors.primaryGold,
      ));
    }

    if (detail.startedAt != null) {
      events.add(_TimelineEvent(
        title: 'Ride Started',
        description: 'The ride has started',
        dateTime: detail.startedAt!,
        icon: Icons.play_circle_rounded,
        color: AppColors.info,
      ));
    }

    // Add stop events
    for (int i = 0; i < detail.stops.length; i++) {
      final stop = detail.stops[i];
      events.add(_TimelineEvent(
        title: 'Stop ${i + 1}',
        description: stop.address,
        dateTime: detail.startedAt ?? DateTime.now(),
        icon: Icons.flag_rounded,
        color: AppColors.warning,
      ));
    }

    if (detail.completedAt != null) {
      events.add(_TimelineEvent(
        title: 'Ride Completed',
        description: 'The ride was completed successfully',
        dateTime: detail.completedAt!,
        icon: Icons.done_all_rounded,
        color: AppColors.success,
      ));
    }

    // Payment status
    final isPaid = detail.paymentStatus.toUpperCase() == 'PAID';
    events.add(_TimelineEvent(
      title: isPaid ? 'Payment Received' : 'Payment Pending',
      description: isPaid
          ? 'Payment of \u20AC${(detail.totalFare ?? 0).toStringAsFixed(2)} received via ${detail.paymentMethod}'
          : 'Awaiting payment confirmation',
      dateTime: detail.completedAt ?? DateTime.now(),
      icon: isPaid ? Icons.payments_outlined : Icons.pending_rounded,
      color: isPaid ? AppColors.success : AppColors.warning,
    ));

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
    final dateStr = DateFormat('dd MMM yyyy').format(event.dateTime);
    final timeStr = DateFormat('hh:mm a').format(event.dateTime);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline indicator ───────────────────────────
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(event.icon, color: event.color, size: 18),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // ── Event content ────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$dateStr  \u2022  $timeStr',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
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

