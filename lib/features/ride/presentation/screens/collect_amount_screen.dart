import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/ride_status.dart';
import '../providers/ride_session_provider.dart';
import 'report_issue_dialog.dart';

class CollectAmountScreen extends ConsumerStatefulWidget {
  const CollectAmountScreen({super.key});

  @override
  ConsumerState<CollectAmountScreen> createState() =>
      _CollectAmountScreenState();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CollectAmountScreenState extends ConsumerState<CollectAmountScreen> {
  bool _showProfile = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideSessionProvider);
    if (ride == null) return const SizedBox.shrink();

    final isCompleted = ride.status == RideStatus.completed;
    final summary = ref.watch(isCompleted ? rideSummaryProvider : farePreviewProvider);
    if (summary == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.backgroundSecondary : Colors.white;
    final textCol = isDark ? AppColors.white : AppColors.textPrimaryLight;
    
    final isCard = summary.paymentMethod.toLowerCase() == 'card';
    final headerTitle = isCompleted 
        ? 'Payment Confirmed' 
        : (isCard ? 'Confirm Payment' : 'Collect Cash');
        
    final statusTitle = isCompleted
        ? '✓ Payment Confirmed'
        : (isCard ? 'Confirm Card Payment' : 'Collect Cash From Passenger');

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    headerTitle,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: textCol,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 24),

              // Status Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.15)
                      : (isCard ? AppColors.info.withOpacity(0.15) : AppColors.warning.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.success.withOpacity(0.3)
                        : (isCard ? AppColors.info.withOpacity(0.3) : AppColors.warning.withOpacity(0.3)),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : (isCard ? Icons.credit_card : Icons.payments_rounded),
                      color: isCompleted ? AppColors.success : (isCard ? AppColors.info : AppColors.warning),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        statusTitle,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isCompleted ? AppColors.success : (isCard ? AppColors.info : AppColors.warning),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fare Card
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Euro Symbol + Large Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '€',
                                  style: AppTextStyles.headlineLarge.copyWith(
                                    color: AppColors.primaryGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  summary.totalFare.toStringAsFixed(2),
                                  style: AppTextStyles.displayMedium.copyWith(
                                    color: textCol,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Divider(
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                              height: 1,
                            ),
                            const SizedBox(height: 20),

                            // Breakdown rows
                            _FareBreakdownRow(
                              label: 'Base Fare',
                              amount: summary.baseFare,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            _FareBreakdownRow(
                              label: 'Distance Fare',
                              amount: summary.distanceFare,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            if (summary.waitTimeFee > 0) ...[
                              const SizedBox(height: 12),
                              _FareBreakdownRow(
                                label: 'Wait Time Fee',
                                amount: summary.waitTimeFee,
                                isDark: isDark,
                              ),
                            ],
                            if (summary.bookingFee > 0) ...[
                              const SizedBox(height: 12),
                              _FareBreakdownRow(
                                label: 'Booking Fee',
                                amount: summary.bookingFee,
                                isDark: isDark,
                              ),
                            ],
                            if (summary.tipAmount > 0) ...[
                              const SizedBox(height: 12),
                              _FareBreakdownRow(
                                label: 'Tip',
                                amount: summary.tipAmount,
                                isDark: isDark,
                                amountColor: AppColors.success,
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Rider Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                                    border: Border.all(
                                      color: AppColors.primaryGold.withOpacity(0.3),
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
                                              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                              size: 24,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person_rounded,
                                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                            size: 24,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ride.rider.fullName,
                                        style: AppTextStyles.titleMedium.copyWith(
                                          color: textCol,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: AppColors.primaryGold, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            ride.rider.rating.toStringAsFixed(1),
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: textCol,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _showProfile
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primaryGold,
                                    size: 28,
                                  ),
                                  onPressed: () =>
                                      setState(() => _showProfile = !_showProfile),
                                ),
                              ],
                            ),
                            // Expandable profile details
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.backgroundDarker
                                      : AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    _ProfileRow(
                                      icon: Icons.person_rounded,
                                      label: 'First Name',
                                      value: ride.rider.firstName,
                                    ),
                                    if (ride.rider.lastName.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      _ProfileRow(
                                        icon: Icons.person_rounded,
                                        label: 'Last Name',
                                        value: ride.rider.lastName,
                                      ),
                                    ],
                                    if (ride.rider.phone.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      _ProfileRow(
                                        icon: Icons.phone_rounded,
                                        label: 'Phone',
                                        value: ride.rider.phone,
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    _ProfileRow(
                                      icon: Icons.location_city_rounded,
                                      label: 'Location',
                                      value: ride.rider.city ?? 'Malta',
                                    ),
                                  ],
                                ),
                              ),
                              crossFadeState: _showProfile
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCompleted) ...[
                    // Report Issue Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ReportIssueDialog(rideId: ride.id),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          'Report an Issue',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Confirm Payment / Finish Ride Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              try {
                                if (isCompleted) {
                                  ref.read(rideSessionProvider.notifier).finishRide();
                                } else {
                                  await ref
                                      .read(rideSessionProvider.notifier)
                                      .confirmPaymentAndComplete();
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? AppColors.success : (isCard ? AppColors.info : AppColors.primaryGold),
                        foregroundColor: isCompleted ? Colors.white : (isCard ? Colors.white : AppColors.backgroundDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCompleted ? Colors.white : (isCard ? Colors.white : AppColors.backgroundDark),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isCompleted
                                      ? Icons.done_all_rounded
                                      : (isCard ? Icons.credit_card : Icons.check_circle_rounded),
                                  color: isCompleted ? Colors.white : (isCard ? Colors.white : AppColors.backgroundDark),
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isCompleted ? 'Finish Ride' : (isCard ? 'Payment completed' : 'Cash collected'),
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: isCompleted ? Colors.white : (isCard ? Colors.white : AppColors.backgroundDark),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FareBreakdownRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDark;
  final Color? amountColor;

  const _FareBreakdownRow({
    required this.label,
    required this.amount,
    required this.isDark,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '€${amount.toStringAsFixed(2)}',
          style: AppTextStyles.bodyLarge.copyWith(
            color: amountColor ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
