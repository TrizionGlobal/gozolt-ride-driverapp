import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReportIssueDialog extends StatefulWidget {
  final String rideId;

  const ReportIssueDialog({super.key, required this.rideId});

  @override
  State<ReportIssueDialog> createState() => _ReportIssueDialogState();
}

class _ReportIssueDialogState extends State<ReportIssueDialog> {
  String? _selectedIssue;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  static const _issueCategories = [
    'Safety Concern',
    'Payment Issue',
    'Route Problem',
    'Vehicle Damage',
    'Rider Behavior',
    'App Issue',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedIssue == null) return;
    setState(() => _isSubmitting = true);
    // Dev bypass: simulate server call
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue reported successfully. Our team will review it.'),
          backgroundColor: AppColors.surfaceDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Report an Issue',
              style: AppTextStyles.titleLarge.copyWith(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select the type of issue',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            // Issue category chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: _issueCategories
                  .map(
                    (issue) => ChoiceChip(
                      label: Text(
                        issue,
                        style: TextStyle(
                          fontSize: 11,
                          color: _selectedIssue == issue
                              ? AppColors.backgroundDark
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      selected: _selectedIssue == issue,
                      onSelected: (selected) =>
                          setState(() => _selectedIssue = selected ? issue : null),
                      selectedColor: AppColors.primaryGold,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Describe the issue (optional)',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            // Submit
            SizedBox(
              width: 160,
              height: 40,
              child: ElevatedButton(
                onPressed: _selectedIssue != null && !_isSubmitting
                    ? _submit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.backgroundDark,
                  disabledBackgroundColor:
                      AppColors.primaryGold.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Cancel
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

