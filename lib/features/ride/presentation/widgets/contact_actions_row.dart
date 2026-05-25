import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../screens/chat_screen.dart';

class ContactActionsRow extends StatelessWidget {
  final VoidCallback? onMessageTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onCancelTap;
  final String? phoneNumber;
  final String? rideId;
  final String? riderName;

  const ContactActionsRow({
    super.key,
    this.onMessageTap,
    this.onCallTap,
    this.onCancelTap,
    this.phoneNumber,
    this.rideId,
    this.riderName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Send a Message
        Expanded(
          child: GestureDetector(
            onTap: onMessageTap ??
                () {
                  if (rideId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          rideId: rideId!,
                          riderName: riderName ?? 'Rider',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Messaging not available'),
                        backgroundColor: AppColors.surfaceDark,
                      ),
                    );
                  }
                },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textMuted.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Send a Message',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.backgroundPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Call button
        GestureDetector(
          onTap: onCallTap ??
              () async {
                if (phoneNumber != null && phoneNumber!.isNotEmpty) {
                  final uri = Uri.parse('tel:$phoneNumber');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open phone dialer'),
                          backgroundColor: AppColors.surfaceDark,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number not available'),
                      backgroundColor: AppColors.surfaceDark,
                    ),
                  );
                }
              },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_rounded,
              color: AppColors.backgroundPrimary,
              size: 18,
            ),
          ),
        ),
        // Cancel button (optional)
        if (onCancelTap != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCancelTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

