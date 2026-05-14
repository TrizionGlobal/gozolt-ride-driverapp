import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../driver/presentation/providers/earnings_provider.dart';

class EarningsPill extends ConsumerStatefulWidget {
  const EarningsPill({super.key});

  @override
  ConsumerState<EarningsPill> createState() => _EarningsPillState();
}

class _EarningsPillState extends ConsumerState<EarningsPill> {
  final _overlayController = OverlayPortalController();
  final _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final earnings = ref.watch(todayEarningsProvider);

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 8),
            child: Align(
              alignment: Alignment.topCenter,
              child: _EarningsBreakdown(
                earnings: earnings,
                onDismiss: () => _overlayController.hide(),
              ),
            ),
          );
        },
        child: GestureDetector(
          onTap: () {
            if (_overlayController.isShowing) {
              _overlayController.hide();
            } else {
              _overlayController.show();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '€ ${earnings.totalEarnings.toStringAsFixed(2)}',
              style: AppTextStyles.titleMedium.copyWith(
                color: const Color(0xFF1B2838),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EarningsBreakdown extends StatelessWidget {
  final dynamic earnings;
  final VoidCallback onDismiss;

  const _EarningsBreakdown({
    required this.earnings,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => onDismiss(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 260,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large total amount in gold
              Text(
                '€${earnings.totalEarnings.toStringAsFixed(2)}',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              // 3-column grid in bordered container
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricColumn(
                          value: '${earnings.tripCount}',
                          label: 'Trips',
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                      Expanded(
                        child: _MetricColumn(
                          value: '€${earnings.cardEarnings.toStringAsFixed(0)}',
                          label: 'Card Trip',
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                      Expanded(
                        child: _MetricColumn(
                          value: '€${earnings.cashEarnings.toStringAsFixed(2)}',
                          label: 'Cash Trip',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tips info
              if (earnings.tipEarnings > 0) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.volunteer_activism_rounded,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tips',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${earnings.tipCount}',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '+€${earnings.tipEarnings.toStringAsFixed(2)}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String value;
  final String label;

  const _MetricColumn({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

