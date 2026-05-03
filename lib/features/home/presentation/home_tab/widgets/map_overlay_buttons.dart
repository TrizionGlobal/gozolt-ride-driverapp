import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class MapOverlayButtons extends StatelessWidget {
  final VoidCallback onMyLocationTap;

  const MapOverlayButtons({
    super.key,
    required this.onMyLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // My Location button
        _CircleButton(
          onTap: onMyLocationTap,
          icon: Icons.my_location_rounded,
          iconColor: AppColors.backgroundPrimary,
          backgroundColor: AppColors.white,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _CircleButton({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}
