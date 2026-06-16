import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoPath = isDark ? AssetPaths.gozoltLogoWithText : AssetPaths.lightGozoltLogoWithText;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // ── Logo with text ─────────────────────────────
              Image.asset(
                logoPath,
                width: 240,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 16),

              // ── Tagline ────────────────────────────────────
              Text(
                'Your journey to better earnings starts here',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // ── Log In button (filled gold) ────────────────
              AppButton(
                text: 'Log In',
                width: double.infinity,
                onPressed: () => context.push(RouteNames.login),
              ),

              const SizedBox(height: 14),

              // ── "or" divider ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                      thickness: 0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                      thickness: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Register button (outlined) ─────────────────
              AppButton(
                text: 'Register',
                width: double.infinity,
                isOutlined: true,
                onPressed: () => context.push(RouteNames.register),
              ),

              const Spacer(),

              // ── Footer ────────────────────────────────────
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'All rights reserved \u00a9 ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 11,
                      ),
                    ),
                    TextSpan(
                      text: 'PRIMOOO 2025',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Version 1.0.1',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5) ?? Colors.grey,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
