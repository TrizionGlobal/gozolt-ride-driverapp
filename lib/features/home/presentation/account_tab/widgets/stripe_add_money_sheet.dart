import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';
import '../providers/account_providers.dart';

class StripeAddMoneySheet extends StatefulWidget {
  final WidgetRef ref;
  final double amount;
  final VoidCallback onSuccess;

  const StripeAddMoneySheet({
    super.key,
    required this.ref,
    required this.amount,
    required this.onSuccess,
  });

  @override
  State<StripeAddMoneySheet> createState() => _StripeAddMoneySheetState();
}

class _StripeAddMoneySheetState extends State<StripeAddMoneySheet> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCardComplete = false;
  String _selectedCardType = 'Credit'; // 'Credit' or 'Debit'
  Key _cardFieldKey = UniqueKey();
  final _nameController = TextEditingController();
  String? _error;
  String? _clientSecret;

  @override
  void initState() {
    super.initState();
    _fetchIntent();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchIntent() async {
    try {
      final repository = widget.ref.read(driverRepositoryProvider);
      final result = await repository.createWalletPaymentIntent(widget.amount);
      if (!mounted) return;

      switch (result) {
        case ApiSuccess(:final data):
          setState(() {
            _clientSecret = data['clientSecret'];
            _isLoading = false;
          });
          break;
        case ApiFailure(:final exception):
          setState(() {
            _error = exception.message;
            _isLoading = false;
          });
          break;
      }
    } catch (e) {
      if (kDebugMode) print('[Stripe] Fetch intent error: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to connect to secure server.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveCard() async {
    if (!_isCardComplete || _clientSecret == null) return;
    
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: _clientSecret!,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
            ),
          ),
        ),
      );

      // Confirm with Backend to credit driver wallet
      final success = await widget.ref.read(walletBalanceProvider.notifier).addMoney(
            widget.amount,
            paymentIntentId: paymentIntent.id,
          );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        widget.onSuccess();
      } else {
        setState(() {
          _error = 'Payment successful, but failed to credit wallet balance. Please contact support.';
          _isSaving = false;
        });
      }
    } on StripeException catch (e) {
      if (mounted) {
        if (e.error.code != FailureCode.Canceled) {
          setState(() => _error = e.error.localizedMessage ?? 'Payment failed.');
        }
        setState(() => _isSaving = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred.';
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Complete Payment',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '€${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
              ),
            ),
            
            const SizedBox(height: 24),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
              )
            else ...[
              SizedBox(
                height: 42,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeSelector(
                        title: 'Credit Card',
                        icon: Icons.credit_card,
                        isSelected: _selectedCardType == 'Credit',
                        onTap: () {
                          if (_selectedCardType != 'Credit') {
                            setState(() {
                              _selectedCardType = 'Credit';
                              _cardFieldKey = UniqueKey();
                              _isCardComplete = false;
                            });
                          }
                        },
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeSelector(
                        title: 'Debit Card',
                        icon: Icons.account_balance_wallet_outlined,
                        isSelected: _selectedCardType == 'Debit',
                        onTap: () {
                          if (_selectedCardType != 'Debit') {
                            setState(() {
                              _selectedCardType = 'Debit';
                              _cardFieldKey = UniqueKey();
                              _isCardComplete = false;
                            });
                          }
                        },
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? AppColors.backgroundSecondary : const Color(0xFFF9FAFB),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARDHOLDER NAME',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1.2),
                        borderRadius: BorderRadius.circular(8),
                        color: isDark ? AppColors.surfaceInput : Colors.white,
                      ),
                      child: Center(
                        child: TextField(
                          controller: _nameController,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: 'Name on card',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'CARD NUMBER & DETAILS',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1.2),
                        borderRadius: BorderRadius.circular(8),
                        color: isDark ? AppColors.surfaceInput : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: CardField(
                          key: _cardFieldKey,
                          onCardChanged: (card) {
                            setState(() {
                              _isCardComplete = card?.complete ?? false;
                            });
                          },
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSaving || !_isCardComplete) ? null : _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text(
                          'Pay Now',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Powered by Stripe',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppColors.primaryGold.withOpacity(0.15) : AppColors.primaryGold.withOpacity(0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : (isDark ? Colors.white10 : Colors.grey[300]!),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primaryGold : (isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primaryGold : (isDark ? Colors.grey[300] : Colors.grey[800]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
