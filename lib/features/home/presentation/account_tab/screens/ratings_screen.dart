import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../providers/account_providers.dart';
import '../../../../driver/data/models/driver_ratings_response.dart';

class RatingsScreen extends ConsumerWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(driverRatingsProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Gold Header (covers status bar completely) ──────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 16 + statusBarHeight, 16, 24),
            decoration: const BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundPrimary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.backgroundPrimary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ratings & Reviews',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ── Content Area ────────────────────────────────────────────────
          Expanded(
            child: ratingsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading reviews: $err',
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              data: (data) {
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Summary Header Card
                    SliverToBoxAdapter(
                      child: _buildSummaryCard(context, data.averageRating, data.totalReviews, data.reviews),
                    ),

                    // Section Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              'Passenger Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${data.reviews.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Reviews List
                    if (data.reviews.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'No reviews received yet.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final r = data.reviews[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildReviewCard(context, r),
                              );
                            },
                            childCount: data.reviews.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double avgRating, int totalReviews, List<DriverReviewItem> reviews) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate rating distribution dynamically
    int count5 = 0;
    int count4 = 0;
    int count3 = 0;
    int count2 = 0;
    int count1 = 0;
    for (final r in reviews) {
      if (r.rating == 5) count5++;
      else if (r.rating == 4) count4++;
      else if (r.rating == 3) count3++;
      else if (r.rating == 2) count2++;
      else if (r.rating == 1) count1++;
    }

    double pct5 = totalReviews > 0 ? count5 / totalReviews : 0.0;
    double pct4 = totalReviews > 0 ? count4 / totalReviews : 0.0;
    double pct3 = totalReviews > 0 ? count3 / totalReviews : 0.0;
    double pct2 = totalReviews > 0 ? count2 / totalReviews : 0.0;
    double pct1 = totalReviews > 0 ? count1 / totalReviews : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Side: Large Rating Number & Stars
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.backgroundPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: index < avgRating.round()
                          ? AppColors.primaryGold
                          : (isDark ? Colors.white10 : Colors.grey.shade200),
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on $totalReviews ${totalReviews == 1 ? "review" : "reviews"}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Vertical Divider
          Container(
            height: 90,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),

          // Right Side: Progress Bars
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildDistributionRow(context, '5', pct5),
                const SizedBox(height: 4),
                _buildDistributionRow(context, '4', pct4),
                const SizedBox(height: 4),
                _buildDistributionRow(context, '3', pct3),
                const SizedBox(height: 4),
                _buildDistributionRow(context, '2', pct2),
                const SizedBox(height: 4),
                _buildDistributionRow(context, '1', pct1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(BuildContext context, String starLabel, double percentage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        SizedBox(
          width: 10,
          child: Text(
            starLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.star_rounded,
          color: AppColors.primaryGold,
          size: 11,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, DriverReviewItem r) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = r.reviewerName.isNotEmpty ? r.reviewerName[0].toUpperCase() : 'P';
    final avatarColor = _getAvatarColor(initial);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer Circle Avatar with Initial
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withOpacity(0.15),
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: avatarColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Review Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.reviewerName,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Rating Stars
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star_rounded,
                          color: index < r.rating
                              ? AppColors.primaryGold
                              : (isDark ? Colors.white10 : Colors.grey.shade200),
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (r.comment != null && r.comment!.trim().isNotEmpty) ...[
                  Text(
                    r.comment!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  Text(
                    'Left a ${r.rating}-star rating without comment',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white30 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(r.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String letter) {
    final int code = letter.isNotEmpty ? letter.codeUnitAt(0) : 65;
    final List<Color> colors = [
      Colors.indigo.shade400,
      Colors.teal.shade400,
      Colors.blue.shade400,
      Colors.pink.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.green.shade400,
      Colors.cyan.shade400,
      Colors.deepOrange.shade400,
    ];
    return colors[code % colors.length];
  }
}

