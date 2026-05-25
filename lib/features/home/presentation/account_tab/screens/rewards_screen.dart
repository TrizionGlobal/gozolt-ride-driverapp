import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rewards & Incentives'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.backgroundPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Weekly Goal Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weekly Ride Goal', style: TextStyle(color: Colors.white70)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('€500 Bonus', style: TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('38 / 50 Rides', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.76,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                const Text('Complete 12 more rides to unlock your bonus!', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text('Active Incentives', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          
          _buildIncentiveTile(
            'Peak Hour Bonus',
            'Get extra €20 on every ride between 6 PM - 9 PM',
            Icons.trending_up_rounded,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildIncentiveTile(
            'Long Distance Reward',
            '€50 extra for rides longer than 15km',
            Icons.speed_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildIncentiveTile(
            'High Rating Bonus',
            'Maintain 4.8+ rating this week for €200 bonus',
            Icons.star_rounded,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildIncentiveTile(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
