import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final unreadCount =
        notificationsAsync.valueOrNull?.where((n) => !n.isRead).length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationListProvider.notifier).markAllAsRead(),
              child: Text(
                'Read all',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Failed to load notifications',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        data: (notifications) => notifications.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      ref
                          .read(notificationListProvider.notifier)
                          .dismiss(notification.id);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: const Color(0xFFE53935).withOpacity(0.2),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    child: _NotificationCard(
                      notification: notification,
                      onTap: () {
                        if (!notification.isRead) {
                          ref
                              .read(notificationListProvider.notifier)
                              .markAsRead(notification.id);
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No notifications yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Your ride alerts and updates will appear here',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final DriverNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surfaceDark.withOpacity(0.5)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: notification.isRead
              ? null
              : Border.all(
                  color: _typeColor(notification.type).withOpacity(0.3),
                  width: 1,
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _typeColor(notification.type).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _typeIcon(notification.type),
                color: _typeColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.white,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _typeColor(notification.type),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(notification.timestamp),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
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

  Color _typeColor(String type) {
    return switch (type.toUpperCase()) {
      'SCHEDULED_REMINDER' || 'REMINDER' => AppColors.primaryGold,
      'EARNING' || 'PAYMENT' => const Color(0xFF4CAF50),
      'RIDE_ALERT' || 'RIDE' => const Color(0xFF2196F3),
      _ => AppColors.textSecondary,
    };
  }

  IconData _typeIcon(String type) {
    return switch (type.toUpperCase()) {
      'SCHEDULED_REMINDER' || 'REMINDER' => Icons.schedule_rounded,
      'EARNING' || 'PAYMENT' => Icons.account_balance_wallet_rounded,
      'RIDE_ALERT' || 'RIDE' => Icons.directions_car_rounded,
      _ => Icons.info_outline_rounded,
    };
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
