import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';

class SosEmergencyScreen extends ConsumerWidget {
  const SosEmergencyScreen({super.key});

  Future<void> _makeCall(BuildContext context, String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone dialer not available on this device (Simulator).'),
              backgroundColor: Color(0xFFE53935),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open dialer.'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
      }
    }
  }

  Future<void> _shareToWhatsApp(WidgetRef ref, BuildContext context) async {
    try {
      // Check location permissions first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services disabled');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      
      final position = await Geolocator.getCurrentPosition();
      final profileState = ref.read(driverProfileProvider);
      
      String driverInfo = '';
      if (profileState is AsyncData && profileState.value != null) {
        final profile = profileState.value!;
        driverInfo = 'Driver: ${profile.firstName} ${profile.lastName}\nPhone: ${profile.phone}\n\n';
      }

      final text = '🚨 *Emergency SOS* 🚨\n\n$driverInfo*My Current Location:*\nhttps://maps.google.com/?q=${position.latitude},${position.longitude}';
      
      final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp is not installed on this device'),
              backgroundColor: Color(0xFFE53935),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not share location.'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 24),
          
          // SOS icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Color(0xFFE53935),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Emergency SOS',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Theme.of(context).textTheme.headlineMedium?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Choose an emergency action below',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          
          // Emergency call button (112 for Malta)
          _EmergencyButton(
            icon: Icons.emergency_rounded,
            label: 'Call Emergency (112)',
            color: const Color(0xFFE53935),
            onTap: () => _makeCall(context, '112'),
          ),
          const SizedBox(height: 12),
          
          // Police button (112 for Malta)
          _EmergencyButton(
            icon: Icons.local_police_rounded,
            label: 'Call Police (112)',
            color: const Color(0xFF1976D2),
            onTap: () => _makeCall(context, '112'),
          ),
          const SizedBox(height: 12),
          
          // Share via WhatsApp
          _EmergencyButton(
            icon: Icons.wechat_rounded, // Best fallback for WhatsApp icon in default material icons
            label: 'Share via WhatsApp',
            color: const Color(0xFF25D366),
            onTap: () => _shareToWhatsApp(ref, context),
          ),
          const SizedBox(height: 24),
          
          // Cancel button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A35) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
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
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44, // Significantly smaller button size
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12), // tighter border radius
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20), // smaller icon
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

