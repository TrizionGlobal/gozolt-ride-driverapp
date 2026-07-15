import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../providers/account_providers.dart';
import 'payout_details_screen.dart';

import '../../../../driver/data/models/driver_profile.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';
import '../../../../driver/data/models/driver_payout_log.dart';

class TipWalletScreen extends ConsumerWidget {
  const TipWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(walletBalanceProvider);
    final withdrawalsAsync = ref.watch(driverWithdrawalsProvider);
    final driverProfileAsync = ref.watch(driverProfileProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Gold header (covers status bar completely) ──────────────────
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
                      color: AppColors.backgroundPrimary.withOpacity(0.2),
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
                  'Tip Wallet',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: balanceAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error loading wallet: $err',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (balance) => Column(
                children: [
                  // Balance Card (smaller size)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryGold, Color(0xFFB8860B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tips Available for Payout',
                          style: const TextStyle(
                              color: AppColors.backgroundPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '€${balance.tipBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.backgroundPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Wallet Details and History
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          if (balance.tipBalance >= 5.0)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: ElevatedButton(
                                onPressed: () {
                                  _showWithdrawBottomSheet(context, ref,
                                      balance.tipBalance, driverProfileAsync);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGold,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Withdraw Tips',
                                    style: TextStyle(
                                        color: AppColors.backgroundPrimary,
                                        fontWeight: FontWeight.bold)),
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'Minimum withdrawal amount is €5.00',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Tips',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceCard
                                        : AppColors.surfaceCardLight,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Theme.of(context)
                                                .dividerTheme
                                                .color ??
                                            Colors.transparent),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildDetailTile(
                                          context,
                                          'Total Tips (All-time)',
                                          '€${balance.totalTips.toStringAsFixed(2)}',
                                          Colors.green),
                                      Divider(
                                          height: 16,
                                          thickness: 0.5,
                                          color: isDark
                                              ? Colors.white10
                                              : Colors.black12),
                                      _buildDetailTile(
                                        context,
                                        'Tip Balance',
                                        '€${balance.tipBalance.toStringAsFixed(2)}',
                                        AppColors.primaryGold,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),
                                Text(
                                  'Tip Withdrawal History',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Dynamic Withdrawal History list
                                withdrawalsAsync.when(
                                  data: (allWithdrawals) {
                                    final withdrawals = allWithdrawals
                                        .where((w) =>
                                            w.notes
                                                ?.toLowerCase()
                                                .contains('tip') ??
                                            false)
                                        .toList();

                                    if (withdrawals.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 24.0),
                                        child: Center(
                                          child: Text(
                                            'No recent tip withdrawals',
                                            style: TextStyle(
                                              color: isDark
                                                  ? AppColors.textMuted
                                                  : Colors.black54,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: withdrawals.length,
                                      itemBuilder: (context, index) {
                                        final log = withdrawals[index];
                                        return _buildTransactionTile(
                                            context, log);
                                      },
                                    );
                                  },
                                  loading: () => const Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primaryGold)),
                                  ),
                                  error: (error, stack) => Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Center(
                                      child: Text('Failed to load history',
                                          style: TextStyle(
                                              color: Colors.red.shade400)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(
      BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withOpacity(0.12),
        child: Icon(Icons.info_outline_rounded, color: color, size: 16),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: isDark ? AppColors.white : AppColors.textPrimaryLight,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, DriverPayoutLog log) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCard : AppColors.surfaceCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).dividerTheme.color ?? Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (log.notes?.isEmpty ?? true)
                            ? 'Supplier Payout'
                            : log.notes!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Text(
                      '+€${log.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, h:mm a')
                      .format(log.createdAt.toLocal()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                if (log.totalFare != null ||
                    log.deductions > 0 ||
                    log.totalRides != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black12 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (log.totalRides != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Rides Completed',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54)),
                              Text('${log.totalRides}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        if (log.totalFare != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Fares',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54)),
                              Text('€${log.totalFare!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        if (log.deductions > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Supplier Commission',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54)),
                              Text('-€${log.deductions.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawBottomSheet(BuildContext context, WidgetRef ref,
      double amount, AsyncValue<DriverProfile?> profileAsync) {
    final profile = profileAsync.valueOrNull;
    if (profile == null) return;

    final hasBankDetails = profile.payoutBankName != null &&
        profile.payoutBankName!.isNotEmpty &&
        profile.payoutAccountNumber != null &&
        profile.payoutAccountNumber!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Withdraw Tips', style: AppTextStyles.titleLarge),
              const SizedBox(height: 16),
              if (!hasBankDetails) ...[
                const Text(
                    'Please add your bank account details in the Bank Account Details section to withdraw.',
                    style: TextStyle(color: Colors.red)),
                const SizedBox(height: 24),
              ] else ...[
                Text(
                    'You are about to withdraw €${amount.toStringAsFixed(2)} to your saved account:',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance,
                          color: AppColors.primaryGold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.payoutBankName!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            Text(
                                'Ending in ${profile.payoutAccountNumber!.substring(profile.payoutAccountNumber!.length > 4 ? profile.payoutAccountNumber!.length - 4 : 0)}',
                                style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final success = await ref
                          .read(walletBalanceProvider.notifier)
                          .withdrawTips(amount);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Withdrawal successful!'),
                                backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Withdrawal failed.'),
                                backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Confirm Withdrawal',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }
}
