import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gozolt_logo.dart';
import '../../auth/domain/models/auth_state.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../driver/presentation/providers/driver_provider.dart';
import '../../../core/routing/startup_provider.dart';
import '../../../core/services/app_version_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize notification service
    try {
      ref.read(notificationServiceProvider).initialize();
    } catch (e) {
      debugPrint('SplashScreen: Notification init error: $e');
    }

    // Hard fail-safe: Force navigation after 6 seconds no matter what
    Future.delayed(const Duration(seconds: 6)).then((_) async {
      if (mounted && !_navigated) {
        debugPrint('SplashScreen: Hard fail-safe triggered');
        final hasTokens = await ref.read(secureStorageProvider).getAccessToken() != null;
        if (hasTokens) {
          _navigate(RouteNames.home);
        } else {
          _navigate(RouteNames.onboarding);
        }
      }
    });

    // Normal flow
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted || _navigated) return;

    // Mark as initialized so GoRouter knows it can proceed to other routes
    ref.read(startupProvider).markInitialized();

    // --- Version Check ---
    final versionService = ref.read(appVersionServiceProvider);
    final config = await versionService.fetchAppVersionConfig();
    
    if (config != null) {
      final requiresUpdate = await versionService.isUpdateRequired(config.minimumVersion);
      if (requiresUpdate) {
        if (mounted && !_navigated) {
          setState(() => _navigated = true);
          context.go('/force-update', extra: {
            'iosStoreUrl': config.iosStoreUrl,
            'androidStoreUrl': config.androidStoreUrl,
          });
        }
        return;
      }
    }
    // ----------------------

    await _performAuthCheck();
    if (!mounted || _navigated) return;

    final storage = ref.read(secureStorageProvider);
    bool hasTokens = false;
    bool hasSeenOnboarding = false;
    try {
      hasTokens = await storage.getAccessToken() != null;
      hasSeenOnboarding = await storage.hasSeenOnboarding();
    } catch (_) {
      await storage.clearAll();
    }
    
    final intendedRoute = GoRouterState.of(context).uri.queryParameters['from'];

    if (hasTokens) {
      debugPrint('SplashScreen: Found tokens, navigating to home');
      _navigate(intendedRoute ?? RouteNames.home);
    } else if (hasSeenOnboarding) {
      debugPrint('SplashScreen: Has seen onboarding, navigating to welcome');
      _navigate(RouteNames.welcome);
    } else {
      debugPrint('SplashScreen: No tokens, navigating to onboarding');
      _navigate(RouteNames.onboarding);
    }
  }

  Future<void> _performAuthCheck() async {
    try {
      debugPrint('SplashScreen: Checking auth status...');
      await ref.read(authProvider.notifier).checkAuthStatus();
      
      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        final storage = ref.read(secureStorageProvider);
        final token = await storage.getAccessToken();

        if (token != null && token != 'dev_access_token') {
          try {
            ref.read(socketServiceProvider).connect(token);
            ref.read(driverProfileProvider.notifier).fetchProfile();
          } catch (e) {
            debugPrint('SplashScreen: Socket/Profile error: $e');
          }
        }
      }
      debugPrint('SplashScreen: Auth check complete');
    } catch (e) {
      debugPrint('SplashScreen: PerformAuthCheck failed: $e');
    }
  }

  void _navigate(String route) {
    if (_navigated || !mounted) return;
    setState(() => _navigated = true);

    // If we're going to the exact same place we currently are (e.g., splash to splash),
    // we should go to home instead to avoid a freeze.
    if (route == RouteNames.splash) {
      route = RouteNames.home;
    }

    // We use context.go to ensure the route stack is replaced
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SafeArea(
        child: Center(
          child: _SplashContent(),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Image.asset(
      isDark
          ? 'assets/images/gozolt_logo_with_text.png'
          : 'assets/images/light_gozolt_logo_with_text.png',
      width: 250,
      fit: BoxFit.contain,
    );
  }
}
