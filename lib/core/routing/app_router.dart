import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/models/auth_state.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/notifications/notification_screen.dart';
import '../theme/app_colors.dart';
import 'route_names.dart';

/// Notifies GoRouter to re-evaluate redirects when auth state changes,
/// without recreating the entire router (which would reset to initialLocation).
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    _subscription = ref.listen(authProvider, (_, _) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = _AuthChangeNotifier(ref);
  ref.onDispose(() => authChangeNotifier.dispose());

  return GoRouter(
    restorationScopeId: 'router',
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.uri.path;
      final isOnSplash = location == RouteNames.splash;
      final isOnLogin = location == RouteNames.login;
      final isOnOnboarding = location == RouteNames.onboarding;

      // Don't redirect during splash - it handles its own navigation
      if (isOnSplash) return null;

      // If authenticated and on login/onboarding, redirect to home
      if (authState is AuthAuthenticated &&
          (isOnLogin || isOnOnboarding)) {
        return RouteNames.home;
      }

      // If unauthenticated and trying to access protected routes
      if (authState is AuthUnauthenticated &&
          !isOnLogin &&
          !isOnOnboarding) {
        return RouteNames.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Center(
          child: Text(
            'Route not found: ${state.uri.path}',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    },
  );
});
