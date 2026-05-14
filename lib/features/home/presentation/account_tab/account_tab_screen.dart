import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'screens/terms_screen.dart';

class AccountTabScreen extends ConsumerWidget {
  const AccountTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(driverProfileProvider);
    final profile = profileAsync.valueOrNull;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ── Back button ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => ref.read(homeTabIndexProvider.notifier).state = 0,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.surfaceDark 
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Profile info: avatar + name + email + rating ──
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryGold,
                backgroundImage: profile?.avatarUrl != null &&
                        profile!.avatarUrl!.isNotEmpty
                    ? NetworkImage(
                        profile.avatarUrl!.startsWith('http')
                            ? profile.avatarUrl!
                            : '${ApiConstants.baseUrl.replaceAll('/v1', '')}${profile.avatarUrl!}',
                      )
                    : null,
                child: profile?.avatarUrl == null
                    ? Text(
                        profile != null
                            ? '${profile.firstName.isNotEmpty ? profile.firstName[0] : ''}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}'
                            : 'D',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.backgroundPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                profile?.fullName ?? 'Driver',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (profile?.email != null) ...[
                const SizedBox(height: 4),
                Text(
                  profile!.email!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final rating = profile?.rating ?? 0.0;
                  return Icon(
                    index < rating.round()
                        ? Icons.star
                        : Icons.star_border_rounded,
                    color: AppColors.primaryGold,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 24),

              // ── Menu items ────────────────────────────────────────
              _MenuTile(
                icon: Icons.directions_car_rounded,
                label: 'My Rides',
                onTap: () {
                  ref.read(homeTabIndexProvider.notifier).state = 2;
                },
              ),
              _MenuTile(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              _MenuTile(
                icon: Icons.help_outline_rounded,
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
              _MenuTile(
                icon: Icons.description_rounded,
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
              _MenuTile(
                icon: Icons.shield_rounded,
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
              _MenuTile(
                icon: Icons.block_rounded,
                label: 'Request Deactivation',
                iconColor: AppColors.error,
                onTap: () => _showDeactivationDialog(context),
              ),
              _MenuTile(
                icon: Icons.brightness_6_rounded,
                label: 'Appearance',
                trailing: Text(
                  ref.watch(themeModeProvider) == ThemeMode.dark ? 'Dark' : 'Light',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryGold),
                ),
                onTap: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),

              const SizedBox(height: 32),

              // ── Logout button ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context, ref),
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.surfaceDark 
            : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Are you sure you want to Log Out?',
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'No',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showDeactivationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.surfaceDark 
            : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Account Deactivation',
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
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
                    ? AppColors.backgroundDarker 
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'GoZolt Support',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Theme.of(context).textTheme.titleSmall?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'support@gozolt.com',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+356 2131 0000',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// ── Menu tile ──────────────────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? trailing;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.surfaceDark 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primaryGold).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primaryGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Theme.of(context).textTheme.titleSmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing ?? Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
