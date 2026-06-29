import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/providers/storage_provider.dart';
import '../../../../driver/presentation/providers/driver_status_provider.dart';
import 'selfie_verification_screen.dart';
import 'status_confirmation_dialog.dart';

class GoOnlineButton extends ConsumerWidget {
  const GoOnlineButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(driverStatusProvider);

    if (status.isOffline) {
      return _OfflineButton(
        onTap: () => _showConfirmation(context, ref, goingOnline: true),
      );
    }

    return _OnlineSection(
      onGoOffline: () => _showConfirmation(context, ref, goingOnline: false),
    );
  }

  void _showConfirmation(
    BuildContext context,
    WidgetRef ref, {
    required bool goingOnline,
  }) {
    if (goingOnline) {
      // Show selfie verification first, then confirmation dialog
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SelfieVerificationScreen(
          onVerified: () {
      if (context.mounted) {
        showDialog(
                context: context,
                builder: (_) => StatusConfirmationDialog(
                  goingOnline: true,
                  onConfirm: () async {
                    try {
                      final storage = ref.read(secureStorageProvider);
                      final token = await storage.getAccessToken();
                      await ref.read(driverStatusProvider.notifier).goOnline(token: token);
                    } catch (e) {
                      if (context.mounted) {
                        final message = e.toString().toLowerCase();
                        final displayMsg = message.contains('selfie') ||
                                message.contains('pending') ||
                                message.contains('review')
                            ? 'Your selfie is being reviewed. Please wait for admin approval.'
                            : 'Unable to go online. Please try again later.';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(displayMsg),
                            backgroundColor: const Color(0xFFE53935),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              );
      }
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => StatusConfirmationDialog(
          goingOnline: false,
          onConfirm: () async {
            await ref.read(driverStatusProvider.notifier).goOffline();
          },
        ),
      );
    }
  }
}

/// Full-width gold "Go Online" button shown when driver is offline.
class _OfflineButton extends StatelessWidget {
  final VoidCallback onTap;

  const _OfflineButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primaryGold,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_tethering_rounded,
              color: AppColors.backgroundPrimary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Go Online',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.backgroundPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Go Offline button on left + static animated "Finding Rides" indicator.
class _OnlineSection extends StatefulWidget {
  final VoidCallback onGoOffline;

  const _OnlineSection({required this.onGoOffline});

  @override
  State<_OnlineSection> createState() => _OnlineSectionState();
}

class _OnlineSectionState extends State<_OnlineSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24).withOpacity(0.85) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(isDark ? 0.4 : 0.6),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            children: [
              // Radar Pulsing Icon
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse rings
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: List.generate(2, (index) {
                              final delay = index * 0.5;
                              var progress = _pulseController.value - delay;
                              if (progress < 0) progress += 1.0;
                              return Transform.scale(
                                scale: 1.0 + (progress * 1.5),
                                child: Opacity(
                                  opacity: (1.0 - progress).clamp(0.0, 1.0) * 0.6,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primaryGold,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      // Center Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.radar_rounded,
                          color: AppColors.primaryGold,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Text Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finding Rides...',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'You are online',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Go Offline Button
              GestureDetector(
                onTap: widget.onGoOffline,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.power_settings_new_rounded,
                        color: Color(0xFFE53935),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Offline',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: const Color(0xFFE53935),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

