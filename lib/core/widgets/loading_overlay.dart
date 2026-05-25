import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundPrimary.withOpacity(0.7),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGold,
        ),
      ),
    );
  }
}

