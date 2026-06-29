import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../driver/presentation/providers/driver_provider.dart';
import '../home_shell.dart';
import 'screens/help_center_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ratings_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/payout_details_screen.dart';

class AccountTabScreen extends ConsumerWidget {
  const AccountTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(driverProfileProvider);
    final profile = profileAsync.valueOrNull;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Gold Header with Profile ────────────────
          Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFD4A843), Color(0xFFF5C518)],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.backgroundDark.withOpacity(0.2),
                        backgroundImage: profile?.avatarUrl != null &&
                                profile!.avatarUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(
                                profile.avatarUrl!.startsWith('http')
                                    ? profile.avatarUrl!
                                    : '${ApiConstants.baseUrl.replaceAll('/v1', '')}${profile.avatarUrl!}',
                                errorListener: (err) {},
                              )
                            : null,
                        child: profile?.avatarUrl == null
                            ? Text(
                                profile != null
                                    ? '${profile.firstName.isNotEmpty ? profile.firstName[0] : ''}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}'
                                    : 'D',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.backgroundDark,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.fullName ?? 'Driver',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.backgroundDark,
                              ),
                            ),
                            if (profile?.email != null)
                              Text(
                                profile!.email!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.backgroundDark.withOpacity(0.7),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (index) {
                                final rating = profile?.rating ?? 0.0;
                                return Icon(
                                  index < rating.round()
                                      ? Icons.star
                                      : Icons.star_border_rounded,
                                  color: AppColors.backgroundDark,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.backgroundDark.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: AppColors.backgroundDark,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Menu Items ─────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // Section: Account
                _sectionLabel(context, 'Account'),
                _menuItem(
                  context,
                  icon: Icons.person_outline,
                  label: 'Profile Info',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  icon: Icons.directions_car_outlined,
                  label: 'My Rides',
                  onTap: () {
                    ref.read(homeTabIndexProvider.notifier).state = 2;
                  },
                ),
                _menuItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Earnings & Payouts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WalletScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  icon: Icons.account_balance,
                  label: 'Bank Account Details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PayoutDetailsScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  icon: Icons.star_outline_rounded,
                  label: 'Ratings & Reviews',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RatingsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                _sectionLabel(context, 'Preferences'),
                _toggleItem(
                  context,
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  value: isDark,
                  onChanged: (v) {
                    ref.read(themeModeProvider.notifier).setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                  },
                ),

                const SizedBox(height: 16),
                _sectionLabel(context, 'Support'),
                _menuItem(
                  context,
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                _sectionLabel(context, 'Legal & Data'),
                _menuItem(
                  context,
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  icon: Icons.block_outlined,
                  label: 'Request Deactivation',
                  textColor: AppColors.error,
                  onTap: () => _showDeactivationDialog(context),
                ),

                const SizedBox(height: 24),

                // Log Out Button
                Semantics(
                  label: 'Log out',
                  button: true,
                  child: Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context, ref),
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Log Out', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error, width: 1.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Gozolt Driver v1.0.1',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
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

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
    bool showChevron = true,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceCard : AppColors.surfaceCardLight),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: textColor ?? (Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.textSecondaryLight),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: textColor ?? (Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.textPrimaryLight),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (showChevron) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceCard : AppColors.surfaceCardLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.transparent),
        ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Semantics(
            label: 'Dark mode toggle',
            toggled: value,
            child: Transform.scale(
              scale: 0.7,
              child: Switch.adaptive(
                value: value,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  onChanged(v);
                },
                activeTrackColor: AppColors.primaryGold,
                inactiveTrackColor: Theme.of(context).dividerTheme.color,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: AppTextStyles.headlineSmall),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(RouteNames.welcome);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Log Out',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeactivationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Account Deactivation',
          style: AppTextStyles.headlineSmall,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'To deactivate your account, please contact your supplier directly.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.surfaceDark 
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'GoZolt Support',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'support@gozolt.com.mt',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+356 2131 0000',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: AppColors.primaryGold)),
          ),
        ],
      ),
    );
  }
}
