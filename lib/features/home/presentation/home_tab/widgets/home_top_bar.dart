import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';
import '../../../../driver/presentation/providers/driver_status_provider.dart';
import '../../notifications/notification_provider.dart';
import '../../home_shell.dart';
import 'earnings_pill.dart';
import 'sos_emergency_screen.dart';

class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(driverProfileProvider);
    final driverStatus = ref.watch(driverStatusProvider);
    final isOnline = driverStatus.isOnline;
    final unreadCount =
        ref.watch(notificationListProvider).valueOrNull?.where((n) => !n.isRead).length ?? 0;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Online: SOS button | Offline: Profile avatar
            if (isOnline)
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const SosEmergencyScreen(),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Color(0xFFE53935),
                    size: 22,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  ref.read(homeTabIndexProvider.notifier).state = 3;
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppColors.white.withOpacity(0.3) 
                          : AppColors.backgroundPrimary.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profileAsync.when(
                      data: (profile) {
                        if (profile.avatarUrl != null) {
                          return Image.network(
                            profile.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => _defaultAvatar(context),
                          );
                        }
                        return _defaultAvatar(context);
                      },
                      loading: () => _defaultAvatar(context),
                      error: (err, stack) => _defaultAvatar(context),
                    ),
                  ),
                ),
              ),
            // Earnings pill
            const EarningsPill(),
            // Notification bell with unread badge
            GestureDetector(
              onTap: () => context.push(RouteNames.notifications),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      size: 22,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

  Widget _defaultAvatar(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.surfaceDark 
          : Colors.grey.shade200,
      child: Icon(
        Icons.person_rounded,
        color: Theme.of(context).textTheme.bodySmall?.color,
        size: 24,
      ),
    );
  }
}


