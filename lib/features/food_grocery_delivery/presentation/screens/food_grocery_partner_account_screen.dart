import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../driver/presentation/providers/driver_provider.dart';
import '../../../home/presentation/account_tab/screens/help_center_screen.dart';
import '../../../home/presentation/account_tab/screens/payout_details_screen.dart';
import '../../../home/presentation/account_tab/screens/privacy_screen.dart';
import '../../../home/presentation/account_tab/screens/profile_screen.dart';
import '../../../home/presentation/account_tab/screens/ratings_screen.dart';
import '../../../home/presentation/account_tab/screens/terms_screen.dart';
import '../../../home/presentation/account_tab/screens/tip_wallet_screen.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../../home/presentation/widgets/bottom_nav_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';

class FoodGroceryPartnerAccountScreen extends ConsumerWidget {
  const FoodGroceryPartnerAccountScreen({
    super.key,
    required this.serviceType,
    required this.onBack,
    required this.onDeliveries,
    required this.onEarnings,
    required this.onNavigationSelected,
  });

  final PartnerServiceType serviceType;
  final VoidCallback onBack;
  final VoidCallback onDeliveries;
  final VoidCallback onEarnings;
  final ValueChanged<int> onNavigationSelected;

  void _openScreen(
    BuildContext context,
    Widget screen,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => screen,
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Log Out',
            style: AppTextStyles.headlineSmall,
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await ref.read(authProvider.notifier).logout();

                if (context.mounted) {
                  context.go(
                    RouteNames.welcome,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final profileAsync = ref.watch(
      driverProfileProvider,
    );

    final profile = profileAsync.valueOrNull;

    final fullName = profile?.fullName.trim();

    final displayName =
        fullName != null && fullName.isNotEmpty ? fullName : 'GOZOLT Partner';

    final firstName = profile?.firstName.trim() ?? '';
    final lastName = profile?.lastName.trim() ?? '';

    final initials = [
      if (firstName.isNotEmpty) firstName[0],
      if (lastName.isNotEmpty) lastName[0],
    ].join();

    final backgroundColor =
        isDark ? AppColors.backgroundDarker : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _ProfileHeader(
            displayName: displayName,
            initials: initials.isEmpty ? 'P' : initials,
            email: profile?.email,
            avatarUrl: profile?.avatarUrl,
            rating: profile?.rating ?? 0,
            onEdit: () {
              _openScreen(
                context,
                const ProfileScreen(),
              );
            },
          ),
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                30,
              ),
              children: [
                _SectionLabel(
                  isDark: isDark,
                  label: 'ACCOUNT',
                ),
                const SizedBox(height: 8),
                _AccountMenuTile(
                  isDark: isDark,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile Info',
                  onTap: () {
                    _openScreen(
                      context,
                      const ProfileScreen(),
                    );
                  },
                ),
                _AccountMenuTile(
                  isDark: isDark,
                  icon: Icons.delivery_dining_outlined,
                  label: 'My Deliveries',
                  onTap: onDeliveries,
                ),
                _AccountMenuTile(
                  isDark: isDark,
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Earnings & Payouts',
                  onTap: onEarnings,
                ),
                _AccountMenuTile(
                  isDark: isDark,
                  icon: Icons.wallet_giftcard_outlined,
                  label: 'Wallet (Tips)',
                  onTap: () {
                    _openScreen(
                      context,
                      const TipWalletScreen(),
                    );
                  },
                ),
                _AccountMenuTile(
                  isDark: isDark,
                  icon: Icons.account_balance_outlined,
                  label: 'Bank Account Details',
                  onTap: () {
                    _openScreen(
                      context,
                      const PayoutDetailsScreen(),
                    );
                  },
                ),
                _AccountMenuTile(
                  isDark: isDark,
                  icon: Icons.star_outline_rounded,
                  label: 'Ratings & Reviews',
                  onTap: () {
                    _openScreen(
                      context,
                      const RatingsScreen(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _SectionLabel(
                  isDark: isDark,
                  label: 'PREFERENCES',
                ),
                const SizedBox(height: 8),
                _ThemeTile(
                  isDark: isDark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                ),
                const SizedBox(height: 16),
                _SectionLabel(
                  isDark: isDark,
                  label: 'SUPPORT',
                ),
                const SizedBox(height: 8),
                _AccountMenuTile(
                  isDark: isDark,
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () {
                    _openScreen(
                      context,
                      const HelpCenterScreen(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _SectionLabel(
                  isDark: isDark,
                  label: 'LEGAL & DATA',
                ),
                const SizedBox(height: 8),
                _AccountMenuTile(
                  isDark: isDark,
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                  onTap: () {
                    _openScreen(
                      context,
                      const TermsScreen(),
                    );
                  },
                ),
                _AccountMenuTile(
                  isDark: isDark,
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () {
                    _openScreen(
                      context,
                      const PrivacyScreen(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(
                        context,
                        ref,
                      );
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(
                        color: AppColors.error,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'GOZOLT Go Partner',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textMutedLight,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: onNavigationSelected,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.initials,
    required this.email,
    required this.avatarUrl,
    required this.rating,
    required this.onEdit,
  });

  final String displayName;
  final String initials;
  final String? email;
  final String? avatarUrl;
  final double rating;
  final VoidCallback onEdit;

  String? get _resolvedAvatarUrl {
    final value = avatarUrl?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('http')) {
      return value;
    }

    return '${ApiConstants.baseUrl.replaceAll('/v1', '')}$value';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedAvatarUrl = _resolvedAvatarUrl;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD4A843),
            Color(0xFFF5C518),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.backgroundDark.withValues(
                  alpha: 0.20,
                ),
                backgroundImage: resolvedAvatarUrl == null
                    ? null
                    : CachedNetworkImageProvider(
                        resolvedAvatarUrl,
                        errorListener: (error) {},
                      ),
                child: resolvedAvatarUrl == null
                    ? Text(
                        initials,
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
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    if (email != null && email!.trim().isNotEmpty)
                      Text(
                        email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.backgroundDark.withValues(
                            alpha: 0.70,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: List<Widget>.generate(
                        5,
                        (index) {
                          return Icon(
                            index < rating.round()
                                ? Icons.star
                                : Icons.star_border_rounded,
                            color: AppColors.backgroundDark,
                            size: 16,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundDark.withValues(
                      alpha: 0.15,
                    ),
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.isDark,
    required this.label,
  });

  final bool isDark;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _AccountMenuTile extends StatelessWidget {
  const _AccountMenuTile({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: AppColors.primaryGold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.isDark,
    required this.onChanged,
  });

  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.dark_mode_outlined,
            size: 22,
            color: AppColors.primaryGold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dark Mode',
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: isDark,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryGold,
          ),
        ],
      ),
    );
  }
}
