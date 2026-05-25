import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../providers/account_providers.dart';

class RatingsScreen extends ConsumerWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(driverRatingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.backgroundPrimary,
      ),
      body: ratingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading reviews: $err',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (data) {
          if (data.reviews.isEmpty) {
            return Column(
              children: [
                _buildSummaryHeader(data.averageRating, 0),
                const Expanded(
                  child: Center(
                    child: Text(
                      'No reviews received yet.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildSummaryHeader(data.averageRating, data.totalReviews),
              
              // Reviews List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: data.reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final r = data.reviews[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(r.reviewerName, style: AppTextStyles.titleSmall),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppColors.primaryGold, size: 16),
                                  const SizedBox(width: 4),
                                  Text(r.rating.toString(), style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (r.comment != null && r.comment!.isNotEmpty) ...[
                            Text(r.comment!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            DateFormat('dd MMM yyyy, hh:mm a').format(r.createdAt),
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(double avgRating, int count) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    color: i < avgRating.round() ? AppColors.primaryGold : Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Total $count Reviews', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
