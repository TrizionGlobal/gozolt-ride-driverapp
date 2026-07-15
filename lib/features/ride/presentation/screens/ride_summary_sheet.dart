import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/ride_session_provider.dart';
import '../widgets/gold_action_button.dart';
import '../widgets/star_rating_input.dart';

class RideSummarySheet extends ConsumerStatefulWidget {
  const RideSummarySheet({super.key});

  @override
  ConsumerState<RideSummarySheet> createState() => _RideSummarySheetState();
}

class _RideSummarySheetState extends ConsumerState<RideSummarySheet> {
  int _rating = 0;
  bool _hasRated = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) return;
    setState(() => _hasRated = true);
    final ride = ref.read(rideSessionProvider);
    if (ride == null) return;
    await ref.read(rideSessionProvider.notifier).rateRider(
          _rating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideSessionProvider);
    final summary = ref.watch(rideSummaryProvider);
    if (summary == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.backgroundPrimary 
          : Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Rider avatar + name
          if (ride != null) ...[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.5),
                  width: 2.5,
                ),
              ),
              child: ClipOval(
                child: ride.rider.avatarUrl != null
                    ? Image.network(
                        ride.rider.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.textSecondary,
                          size: 30,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ride.rider.fullName,
              style: AppTextStyles.titleMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Title
          Text(
            'Ride Completed',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          // Green badge if CARD payment
          if (summary.paymentMethod.toLowerCase() == 'card') ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Received',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          // Fare breakdown
          _FareRow(label: 'Base Fare', amount: summary.baseFare),
          _FareRow(label: 'Distance Fare', amount: summary.distanceFare),
          if (summary.waitTimeFee > 0)
            _FareRow(label: 'Wait Time Fee', amount: summary.waitTimeFee),
          if (summary.bookingFee > 0)
            _FareRow(label: 'Booking Fee', amount: summary.bookingFee),
          Builder(
            builder: (context) {
              final subtotal = summary.baseFare + summary.distanceFare + summary.timeFare + summary.waitTimeFee + summary.bookingFee;
              final minFareAdjustment = summary.totalFare - subtotal;
              if (minFareAdjustment > 0.01) {
                return _FareRow(label: 'Minimum Fare Adj.', amount: minFareAdjustment);
              }
              return const SizedBox.shrink();
            },
          ),
          if (summary.surgeMultiplier > 1.0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Surge',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${summary.surgeMultiplier.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (summary.tipAmount > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                height: 1,
                color: AppColors.primaryGold.withOpacity(0.2),
              ),
            ),
            _FareRow(label: 'Tip', amount: summary.tipAmount),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: AppColors.primaryGold.withOpacity(0.2),
            ),
          ),
          _FareRow(
            label: 'Total',
            amount: summary.totalFare,
            isBold: true,
          ),
          const SizedBox(height: 16),
          // Driver earnings
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Your Earnings: €${(summary.driverEarnings + summary.tipAmount).toStringAsFixed(2)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (summary.tipAmount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Includes €${summary.tipAmount.toStringAsFixed(2)} tip',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Distance + Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${summary.distanceKm.toStringAsFixed(1)} km',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${summary.durationMinutes} min',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                summary.paymentMethod.toLowerCase() == 'cash' ? 'Cash' : 'Credit/Debit Card',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              color: AppColors.primaryGold.withOpacity(0.2),
            ),
          ),
          // Rate the rider
          if (_hasRated)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Thanks for your feedback!',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else ...[
            Text(
              'Rate the Rider',
              style: AppTextStyles.titleMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            StarRatingInput(
              onRatingChanged: (r) => setState(() => _rating = r),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'Add a comment (optional)',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.backgroundDark,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Submit Rating',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
          // Done button
          GoldActionButton(
            label: 'Finish Ride',
            onTap: () =>
                ref.read(rideSessionProvider.notifier).finishRide(),
          ),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;

  const _FareRow({
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
          Text(
            '€${amount.toStringAsFixed(2)}',
            style: isBold
                ? AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}


