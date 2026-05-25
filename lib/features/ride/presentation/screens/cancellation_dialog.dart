import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CancellationDialog extends StatefulWidget {
  final Future<void> Function(String reason) onSubmit;

  const CancellationDialog({super.key, required this.onSubmit});

  @override
  State<CancellationDialog> createState() => _CancellationDialogState();
}

class _CancellationDialogState extends State<CancellationDialog> {
  static const _reasons = [
    'Rider not at pickup location',
    'Rider requested cancellation',
    'Safety concerns',
    'Vehicle issue / breakdown',
    'Wrong address provided',
    'Waited too long at pickup',
    'Rider behavior concern',
  ];

  String? _selectedReason;
  final _otherController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cancellation Reason',
              style: AppTextStyles.titleLarge.copyWith(
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            // Predefined reasons
            ...List.generate(_reasons.length, (index) {
              final reason = _reasons[index];
              final isSelected = _selectedReason == reason;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedReason = reason;
                  _otherController.clear();
                }),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold
                        : Theme.of(context).cardColor,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGold
                          : AppColors.textMuted.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reason,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.backgroundDark
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            // Others text field
            TextField(
              controller: _otherController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() => _selectedReason = null);
                }
              },
              decoration: InputDecoration(
                hintText: 'Others',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.textMuted.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.textMuted.withOpacity(0.3),
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            // Submit
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _canSubmit && !_isSubmitting
                    ? () async {
                        setState(() => _isSubmitting = true);
                        final reason = _selectedReason ??
                            _otherController.text.trim();
                        await widget.onSubmit(reason);
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.backgroundPrimary,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.backgroundPrimary : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Cancel
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                  side: BorderSide(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit =>
      _selectedReason != null || _otherController.text.trim().isNotEmpty;
}

