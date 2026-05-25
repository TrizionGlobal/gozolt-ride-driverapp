import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class StatusConfirmationDialog extends StatelessWidget {
  final bool goingOnline;
  final VoidCallback onConfirm;

  const StatusConfirmationDialog({
    super.key,
    required this.goingOnline,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final confirmColor = goingOnline
        ? const Color(0xFF4CAF50) // green
        : const Color(0xFFCC3333); // red

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              goingOnline
                  ? 'Are you sure you want to go Online?'
                  : 'Are you sure you want to go offline?',
              style: AppTextStyles.titleLarge.copyWith(
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Yes button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: AppColors.backgroundDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.backgroundDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // No button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: goingOnline
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : confirmColor,
                  side: BorderSide(
                    color: goingOnline
                        ? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey
                        : confirmColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'No',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: goingOnline
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : confirmColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
