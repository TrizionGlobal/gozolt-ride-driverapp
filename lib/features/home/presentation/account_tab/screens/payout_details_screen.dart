import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';

class PayoutDetailsScreen extends ConsumerStatefulWidget {
  const PayoutDetailsScreen({super.key});

  @override
  ConsumerState<PayoutDetailsScreen> createState() => _PayoutDetailsScreenState();
}

class _PayoutDetailsScreenState extends ConsumerState<PayoutDetailsScreen> {
  late TextEditingController _payoutAccountHolderController;
  late TextEditingController _payoutAccountNumberController;
  late TextEditingController _payoutBankNameController;
  late TextEditingController _payoutSwiftCodeController;
  
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(driverProfileProvider).valueOrNull;
    _payoutAccountHolderController = TextEditingController(text: profile?.payoutAccountHolder);
    _payoutAccountNumberController = TextEditingController(text: profile?.payoutAccountNumber); // IBAN
    _payoutBankNameController = TextEditingController(text: profile?.payoutBankName);
    _payoutSwiftCodeController = TextEditingController(text: profile?.payoutSwiftCode);

    // If details are completely empty, start in edit mode
    if ((profile?.payoutAccountNumber ?? '').isEmpty) {
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _payoutAccountHolderController.dispose();
    _payoutAccountNumberController.dispose();
    _payoutBankNameController.dispose();
    _payoutSwiftCodeController.dispose();
    super.dispose();
  }

  Future<void> _savePayoutDetails() async {
    final holder = _payoutAccountHolderController.text.trim();
    final iban = _payoutAccountNumberController.text.trim();
    final bankName = _payoutBankNameController.text.trim();
    final swift = _payoutSwiftCodeController.text.trim();

    if (holder.isEmpty || iban.isEmpty || bankName.isEmpty) {
      _showSnackBar('Please fill in Account Holder, IBAN, and Bank Name', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    
    final updateError = await ref.read(driverProfileProvider.notifier).updateProfile(
      payoutAccountHolder: holder,
      payoutAccountNumber: iban,
      payoutBankName: bankName,
      payoutSwiftCode: swift.isNotEmpty ? swift : null,
    );

    setState(() => _isSaving = false);

    if (updateError != null && mounted) {
      _showSnackBar(updateError, isError: true);
    } else if (mounted) {
      _showSnackBar('Payout details updated successfully');
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor.withOpacity(0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : 'Not provided',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: value.isNotEmpty ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bank Account Details',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryGold),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryGold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Recommended for Malta',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_isEditing) ...[
              _buildTextField('Account Holder Name', _payoutAccountHolderController),
              const SizedBox(height: 16),
              _buildTextField('IBAN', _payoutAccountNumberController),
              const SizedBox(height: 16),
              _buildTextField('Bank Name', _payoutBankNameController),
              const SizedBox(height: 16),
              _buildTextField('BIC/SWIFT Code', _payoutSwiftCodeController, hint: '(optional depending on bank)'),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePayoutDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.backgroundPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.backgroundPrimary,
                          ),
                        )
                      : const Text(
                          'Save Details',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              if ((ref.read(driverProfileProvider).valueOrNull?.payoutAccountNumber ?? '').isNotEmpty)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        // Revert text controllers
                        final profile = ref.read(driverProfileProvider).valueOrNull;
                        _payoutAccountHolderController.text = profile?.payoutAccountHolder ?? '';
                        _payoutAccountNumberController.text = profile?.payoutAccountNumber ?? '';
                        _payoutBankNameController.text = profile?.payoutBankName ?? '';
                        _payoutSwiftCodeController.text = profile?.payoutSwiftCode ?? '';
                        _isEditing = false;
                      });
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                ),
            ] else ...[
              _buildInfoRow('Account Holder Name', _payoutAccountHolderController.text),
              _buildInfoRow('IBAN', _payoutAccountNumberController.text),
              _buildInfoRow('Bank Name', _payoutBankNameController.text),
              _buildInfoRow('BIC/SWIFT Code', _payoutSwiftCodeController.text),
            ],
          ],
        ),
      ),
    );
  }
}
