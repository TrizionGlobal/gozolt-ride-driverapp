import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class NavigationButton extends StatelessWidget {
  final double? destinationLat;
  final double? destinationLng;

  const NavigationButton({
    super.key,
    this.destinationLat,
    this.destinationLng,
  });

  Future<void> _openNavigation(BuildContext context) async {
    if (destinationLat == null || destinationLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Destination not available'),
          backgroundColor: AppColors.surfaceDark,
        ),
      );
      return;
    }

    final lat = destinationLat!;
    final lng = destinationLng!;

    // Try Google Maps first, then Apple Maps on iOS
    final googleMapsUrl = Uri.parse(
      'google.navigation:q=$lat,$lng&mode=d',
    );
    final webGoogleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (Platform.isIOS && await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
      } else {
        await launchUrl(webGoogleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(webGoogleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _openNavigation(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryGold,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.navigation_rounded,
                color: AppColors.backgroundPrimary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Navigation',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.backgroundPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

