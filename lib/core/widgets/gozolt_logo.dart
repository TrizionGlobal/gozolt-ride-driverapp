import 'package:flutter/material.dart';
import '../constants/asset_paths.dart';
import '../theme/app_colors.dart';

class GozoltLogo extends StatelessWidget {
  final double size;

  const GozoltLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetPaths.gozoltLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(size * 0.15),
          ),
          child: Icon(
            Icons.flash_on,
            size: size * 0.4,
            color: AppColors.brandYellow,
          ),
        );
      },
    );
  }
}
