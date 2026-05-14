import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ratings = [
      {'name': 'Ramesh Kumar', 'rating': 5.0, 'comment': 'Excellent driving and very polite!'},
      {'name': 'Sneha Reddy', 'rating': 4.0, 'comment': 'Good ride, reached on time.'},
      {'name': 'Vikram Singh', 'rating': 5.0, 'comment': 'Clean vehicle and smooth ride.'},
      {'name': 'Ananya Roy', 'rating': 3.0, 'comment': 'A bit slow, but safe.'},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.backgroundPrimary,
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
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
                    const Text('4.8', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (i) => const Icon(Icons.star_rounded, color: AppColors.primaryGold)),
                    ),
                    const SizedBox(height: 8),
                    Text('Total 124 Reviews', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          
          // Reviews List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: ratings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final r = ratings[index];
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
                          Text(r['name'] as String, style: AppTextStyles.titleSmall),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.primaryGold, size: 16),
                              const SizedBox(width: 4),
                              Text(r['rating'].toString(), style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(r['comment'] as String, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Text('2 days ago', style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
