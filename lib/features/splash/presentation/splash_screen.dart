import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gozolt_logo.dart';
import '../../auth/domain/models/auth_state.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../driver/presentation/providers/driver_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait for splash duration
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    try {
      // Check auth status with a timeout to prevent hanging
      await ref.read(authProvider.notifier).checkAuthStatus().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Auth check timed out');
        },
      );

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState is AuthAuthenticated) {
        final storage = ref.read(secureStorageProvider);
        final token = await storage.getAccessToken().timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );

        // Clear fake dev tokens and force real login
        if (token == null || token == 'dev_access_token') {
          await storage.clearTokens();
          if (!mounted) return;
          context.go(RouteNames.onboarding);
          return;
        }

        try {
          ref.read(socketServiceProvider).connect(token);
          // Don't await profile fetch - let it happen in background or handle in Home
          ref.read(driverProfileProvider.notifier).fetchProfile();
        } catch (e) {
          debugPrint('Socket/Profile error: $e');
        }

        if (!mounted) return;
        context.go(RouteNames.home);
      } else {
        context.go(RouteNames.onboarding);
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        context.go(RouteNames.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: _SplashContent()),
            const _SplashFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AssetPaths.gozoltLogoWithText,
        width: MediaQuery.of(context).size.width * 0.8,
        height: 400,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const _FallbackBranding();
        },
      ),
    );
  }
}

class _FallbackBranding extends StatelessWidget {
  const _FallbackBranding();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const GozoltLogo(size: 180),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GO',
              style: AppTextStyles.splashTitle.copyWith(
                color: AppColors.brandYellow,
              ),
            ),
            Text(
              'ZOLT',
              style: AppTextStyles.splashTitle.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        Text('GO PARTNER', style: AppTextStyles.splashSubtitle.copyWith(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.brandYellow : AppColors.backgroundPrimary,
        )),
      ],
    );
  }
}

class _SplashFooter extends StatelessWidget {
  const _SplashFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Born in Malta, Loved by Europe" with flags
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.maltaFlag,
              width: 24,
              height: 16,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('🇲🇹', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
            Text(
              'Born in Malta, Loved by Europe',
              style: AppTextStyles.footerText.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              AssetPaths.euFlag,
              width: 24,
              height: 16,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('🇪🇺', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // "Powered By PRIMOOO"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Powered By ', style: AppTextStyles.footerText.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            )),
            Text('PRIMOOO', style: AppTextStyles.footerAccent.copyWith(
              color: AppColors.primaryGold,
            )),
            const SizedBox(width: 8),
            Image.asset(
              AssetPaths.primoooLogo,
              width: 32,
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }
}
