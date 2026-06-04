import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../providers/account_providers.dart';
import '../widgets/stripe_add_money_sheet.dart';


class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(walletBalanceProvider);
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
                  'My Wallet',
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        const Text(
                          'Available Balance',
                          style: TextStyle(color: AppColors.backgroundPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '€${balance.availableBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.backgroundPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildActionButton(context, Icons.add_rounded, 'Add Money', () => _showAddMoneyDialog(context, ref)),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              context,
                              Icons.account_balance_wallet_rounded,
                              'Withdraw',
                              () => _showWithdrawDialog(context, ref, balance.availableBalance, balance.payoutDestination),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Transactions (compact and theme-based)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wallet Details',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                _buildDetailTile(context, 'Total Earnings (All-time)', '€${balance.totalEarnings.toStringAsFixed(2)}', Colors.green),
                                Divider(height: 8, thickness: 0.5, color: isDark ? Colors.white10 : Colors.black12),
                                _buildDetailTile(context, 'Total Paid Out', '€${balance.totalPaidOut.toStringAsFixed(2)}', Colors.blue),
                                Divider(height: 8, thickness: 0.5, color: isDark ? Colors.white10 : Colors.black12),
                                _buildDetailTile(context, 'Pending Penalties', '€${balance.pendingPenalties.toStringAsFixed(2)}', Colors.red),
                                Divider(height: 8, thickness: 0.5, color: isDark ? Colors.white10 : Colors.black12),
                                _buildDetailTile(context, 'Available Wallet Balance', '€${balance.availableBalance.toStringAsFixed(2)}', AppColors.primaryGold),
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

  Widget _buildDetailTile(BuildContext context, String label, String value, Color color) {
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

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.backgroundPrimary, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMoneySheet(ref: ref),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref, double availableBalance, String? payoutDestination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WithdrawSheet(ref: ref, availableBalance: availableBalance, payoutDestination: payoutDestination),
    );
  }
}

class _AddMoneySheet extends StatefulWidget {
  final WidgetRef ref;

  const _AddMoneySheet({required this.ref});

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _success = false;

  void _selectAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(2);
      _error = null;
    });
  }

  Future<void> _processPayment() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }

    Navigator.pop(context); // Close the amount selection sheet
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StripeAddMoneySheet(
        ref: widget.ref,
        amount: amount,
        onSuccess: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                backgroundColor: Theme.of(context).cardTheme.color ?? (isDark ? AppColors.surfaceDark : Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 72),
                      const SizedBox(height: 20),
                      Text('Payment Successful', style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(
                        '€${amount.toStringAsFixed(2)} has been added to your wallet',
                        style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.add_rounded, color: AppColors.primaryGold, size: 28),
              const SizedBox(width: 8),
              Text('Add Money to Wallet', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '€ ',
              hintText: '0.00',
              labelText: 'Enter Amount',
              labelStyle: const TextStyle(fontSize: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _amountChip(10),
              _amountChip(20),
              _amountChip(50),
              _amountChip(100),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Pay with Stripe', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountChip(double amount) {
    return ActionChip(
      label: Text('+€${amount.toInt()}'),
      onPressed: () => _selectAmount(amount),
      backgroundColor: AppColors.primaryGold.withOpacity(0.1),
      labelStyle: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
    );
  }
}

class _WithdrawSheet extends StatefulWidget {
  final WidgetRef ref;
  final double availableBalance;
  final String? payoutDestination;

  const _WithdrawSheet({required this.ref, required this.availableBalance, this.payoutDestination});

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _success = false;

  void _selectAmount(double amount) {
    if (amount > widget.availableBalance) {
      amount = widget.availableBalance;
    }
    setState(() {
      _amountController.text = amount.toStringAsFixed(2);
      _error = null;
    });
  }

  Future<void> _processWithdraw() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }
    if (amount > widget.availableBalance) {
      setState(() => _error = 'Cannot withdraw more than your available balance');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Simulate transfer delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final success = await widget.ref.read(walletBalanceProvider.notifier).withdraw(amount);
    
    if (!mounted) return;

    if (success) {
      if (mounted) Navigator.pop(context); // Close the bottom sheet
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Theme.of(context).cardTheme.color ?? (isDark ? AppColors.surfaceDark : Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 72),
                    const SizedBox(height: 20),
                    Text('Withdrawal Successful', style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      '€${double.parse(amountText).toStringAsFixed(2)} has been sent to your bank account',
                      style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Withdrawal request failed. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryGold, size: 28),
              const SizedBox(width: 8),
              Text('Withdraw Funds', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Available: €${widget.availableBalance.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryGold),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '€ ',
              hintText: '0.00',
              labelText: 'Withdrawal Amount',
              labelStyle: const TextStyle(fontSize: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _amountChip(20),
              _amountChip(50),
              _amountChip(100),
              ActionChip(
                label: const Text('All Available'),
                onPressed: () => _selectAmount(widget.availableBalance),
                backgroundColor: AppColors.primaryGold.withOpacity(0.1),
                labelStyle: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppColors.primaryGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payout Destination',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        widget.payoutDestination ?? 'No Bank Account Linked',
                        style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Initiate Payout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountChip(double amount) {
    return ActionChip(
      label: Text('€${amount.toInt()}'),
      onPressed: () => _selectAmount(amount),
      backgroundColor: AppColors.primaryGold.withOpacity(0.1),
      labelStyle: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
    );
  }
}
