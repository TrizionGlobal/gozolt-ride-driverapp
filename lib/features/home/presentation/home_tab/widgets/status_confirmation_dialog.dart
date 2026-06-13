import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class StatusConfirmationDialog extends StatelessWidget {
  final bool goingOnline;
  final VoidCallback onConfirm;

  const StatusConfirmationDialog({
    super.key,
    required this.goingOnline,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme colors
    final iconColor = goingOnline ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final iconBgColor = goingOnline ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? iconColor.withOpacity(0.15) : iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                goingOnline ? Icons.wifi_tethering_rounded : Icons.power_settings_new_rounded,
                color: iconColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              goingOnline ? 'Go Online' : 'Go Offline',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Theme.of(context).textTheme.headlineMedium?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              goingOnline
                  ? 'You will start receiving ride requests from nearby users.'
                  : 'You will stop receiving ride requests and end your current shift.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A35) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Confirm Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: goingOnline 
                              ? [const Color(0xFF4CAF50), const Color(0xFF45A049)]
                              : [const Color(0xFFE53935), const Color(0xFFD32F2F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          goingOnline ? 'Go Online' : 'Go Offline',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
