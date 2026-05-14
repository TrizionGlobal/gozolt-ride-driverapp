import 'dart:math' as math;
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
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Go Offline button
        GestureDetector(
          onTap: widget.onGoOffline,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.power_settings_new_rounded,
              color: Color(0xFFE53935),
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Finding Rides indicator with wavy animation inside
        Expanded(
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(29),
              border: Border.all(
                color: AppColors.primaryGold,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                  ),
                  // Wavy gold-green gradient animation
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _WavePainter(
                          progress: _waveController.value,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                  // Content overlay
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_tethering_rounded,
                          color: AppColors.primaryGold,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Finding Rides...',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Theme.of(context).textTheme.titleMedium?.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;

  _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final waveShift = progress * 2 * math.pi;

    // Draw two wave layers for depth
    _drawWave(
      canvas,
      size,
      shift: waveShift,
      amplitude: 8,
      frequency: 1.5,
      baseY: size.height * 0.55,
      colors: [
        const Color(0xFFD4A843).withOpacity(0.25),
        const Color(0xFF4CAF50).withOpacity(0.15),
      ],
    );

    _drawWave(
      canvas,
      size,
      shift: waveShift + math.pi * 0.8,
      amplitude: 6,
      frequency: 2.0,
      baseY: size.height * 0.5,
      colors: [
        const Color(0xFF4CAF50).withOpacity(0.2),
        const Color(0xFFD4A843).withOpacity(0.12),
      ],
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double shift,
    required double amplitude,
    required double frequency,
    required double baseY,
    required List<Color> colors,
  }) {
    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = baseY +
          amplitude * math.sin((x / size.width) * frequency * 2 * math.pi + shift);
      if (x == 0) {
        path.lineTo(0, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: colors,
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

