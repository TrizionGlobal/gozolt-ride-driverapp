import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/registration_screen.dart';
import '../../features/auth/presentation/registration_status_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/forgot_password/forgot_password_screen.dart';
import '../../features/auth/presentation/forgot_password/forgot_password_otp_screen.dart';
import '../../features/auth/presentation/forgot_password/reset_password_screen.dart';
import '../../features/auth/presentation/forgot_password/reset_success_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/models/auth_state.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/notifications/notification_screen.dart';
import '../theme/app_colors.dart';
import '../providers/storage_provider.dart';
import 'route_names.dart';
import 'startup_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final startupNotifier = ref.watch(startupProvider);

  return GoRouter(
    restorationScopeId: 'router',
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: startupNotifier,
    redirect: (context, state) {
      final isInitialized = startupNotifier.value;
      final isGoingToSplash = state.uri.path == RouteNames.splash;

      if (!isInitialized && !isGoingToSplash) {
        // If not initialized and trying to go somewhere else (like when OS restores app),
        // intercept and go to splash, remembering where they wanted to go.
        return '${RouteNames.splash}?from=${state.uri.path}';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.otp,
        name: 'otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: RouteNames.registrationStatus,
        name: 'registrationStatus',
        builder: (context, state) {
          bool isFleet = false;
          String? phone;
          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            isFleet = extra['isFleet'] as bool? ?? false;
            phone = extra['phone'] as String?;
          } else if (state.extra is bool) {
            isFleet = state.extra as bool;
          }
          return RegistrationStatusScreen(isFleet: isFleet, phone: phone);
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordOtp,
        name: 'forgotPasswordOtp',
        builder: (context, state) {
          final driverId = state.extra as String? ?? '';
          return ForgotPasswordOtpScreen(driverId: driverId);
        },
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: 'resetPassword',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            driverId: extra['driverId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: RouteNames.resetSuccess,
        name: 'resetSuccess',
        builder: (context, state) => const ResetSuccessScreen(),
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
