import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/ride_session_provider.dart';

class CountdownTimer extends ConsumerWidget {
  const CountdownTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = ref.watch(rideRequestCountdownProvider);
    final maxSeconds = ref.watch(rideRequestMaxCountdownProvider);

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: maxSeconds > 0 ? seconds / maxSeconds : 0,
            strokeWidth: 3,
            backgroundColor: AppColors.textMuted.withValues(alpha: 0.2),
            color: seconds <= 5
                ? const Color(0xFFE53935)
                : AppColors.primaryGold,
          ),
          Text(
            '$seconds',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.backgroundPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
