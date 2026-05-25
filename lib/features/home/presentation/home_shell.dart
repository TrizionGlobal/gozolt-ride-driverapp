import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/socket_service.dart';
import '../../driver/presentation/providers/driver_provider.dart';
import '../../driver/presentation/providers/driver_status_provider.dart';
import '../../driver/presentation/providers/earnings_provider.dart';
import '../../driver/presentation/providers/location_provider.dart';
import '../../ride/presentation/providers/ride_session_provider.dart';
import 'account_tab/account_tab_screen.dart';
import 'earning_tab/earning_tab_screen.dart';
import 'history_tab/history_tab_screen.dart';
import 'home_tab/home_tab_screen.dart';
import 'widgets/bottom_nav_bar.dart';

final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Fetch initial data
    Future.microtask(() {
      ref.read(driverProfileProvider.notifier).fetchProfile();
      ref.read(todayEarningsProvider.notifier).fetchTodayEarnings();
    });
    // Initialize location tracking service
    ref.read(locationUpdateProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground — reconnect WebSocket if driver is online
      final driverStatus = ref.read(driverStatusProvider);
      final socketService = ref.read(socketServiceProvider);
      if ((driverStatus.isOnline || driverStatus.isOnRide) &&
          !socketService.isConnected) {
        if (kDebugMode) print('[HomeShell] App resumed, reconnecting WebSocket...');
        socketService.reconnect();
      }
      // Refresh today's earnings pill so it stays current
      ref.read(todayEarningsProvider.notifier).fetchTodayEarnings();
    }
  }

  final _screens = const [
    HomeTabScreen(),
    EarningTabScreen(),
    HistoryTabScreen(),
    AccountTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Watch location provider so it rebuilds on status changes
    ref.watch(locationUpdateProvider);
    final currentIndex = ref.watch(homeTabIndexProvider);
    final driverStatus = ref.watch(driverStatusProvider);
    final isOnline = driverStatus.isOnline;
    final ride = ref.watch(rideSessionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: (isOnline || ride != null)
          ? null
          : AppBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(homeTabIndexProvider.notifier).state = index;
              },
            ),
    );
  }
}
