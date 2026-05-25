import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/ride_session_provider.dart';
import 'report_issue_dialog.dart';

class CollectAmountScreen extends ConsumerStatefulWidget {
  const CollectAmountScreen({super.key});

  @override
  ConsumerState<CollectAmountScreen> createState() =>
      _CollectAmountScreenState();
}

class _CollectAmountScreenState extends ConsumerState<CollectAmountScreen> {
  bool _showProfile = false;

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideSessionProvider);
    final summary = ref.watch(rideSummaryProvider);
    if (ride == null || summary == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // "Ride Summary" button + title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => ref
                        .read(rideSessionProvider.notifier)
                        .dismissCollectAmount(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryGold),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_rounded,
                              color: AppColors.primaryGold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Ride Summary',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Collect Amount',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 24),
              // Dark card with fare + rider info (at top)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.backgroundPrimary 
                    : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Euro icon + amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryGold.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.euro_rounded,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          summary.totalFare.toStringAsFixed(2),
                          style: AppTextStyles.displayMedium.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.backgroundPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      height: 1,
                    ),
                    const SizedBox(height: 20),
                    // Rider avatar + name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: AppColors.primaryGold
                                  .withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: ride.rider.avatarUrl != null
                                ? Image.network(
                                    ride.rider.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Icon(
                                      Icons.person_rounded,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                      size: 22,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    color: Colors.grey,
                                    size: 22,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          ride.rider.fullName,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.backgroundPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // View Profile toggle
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showProfile = !_showProfile),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Profile',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _showProfile
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    // Expandable rider profile details
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _ProfileRow(
                              icon: Icons.person_rounded,
                              label: 'Name',
                              value: ride.rider.fullName,
                            ),
                            const SizedBox(height: 8),
                            _ProfileRow(
                              icon: Icons.star_rounded,
                              label: 'Rating',
                              value:
                                  '${ride.rider.rating.toStringAsFixed(1)} / 5.0',
                              valueColor: AppColors.primaryGold,
                            ),
                            const SizedBox(height: 8),
                            _ProfileRow(
                              icon: Icons.location_city_rounded,
                              label: 'Location',
                              value: ride.rider.city ?? 'Not available',
                            ),
                          ],
                        ),
                      ),
                      crossFadeState: _showProfile
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                    if (summary.tipAmount > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.volunteer_activism_rounded,
                                color: Color(0xFF4CAF50), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '+€${summary.tipAmount.toStringAsFixed(2)} Tip!',
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
              const Spacer(),
              // Report an Issue (red outlined)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ReportIssueDialog(rideId: ride.id),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Report an Issue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Received Cash button (gold with check icon)
              GestureDetector(
                onTap: () => ref
                    .read(rideSessionProvider.notifier)
                    .dismissCollectAmount(),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.backgroundDark, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Received Cash',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.backgroundDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


